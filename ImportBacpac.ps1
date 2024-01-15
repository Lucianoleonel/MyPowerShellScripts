param (
    [Parameter(Mandatory = $true)]
    [string]$rutaBacpac
    ,
    # [Parameter(Mandatory=$true)]
    [string]$urlDescargarBacpac
    ,
    [switch]$includeSwitch = $false
    ,
    [switch]$includeInstallSqlPackage = $false
    ,
    [switch]$skipBuildModels = $false
    ,
    [switch]$reinstallCsu = $false
    ,
    [switch]$skipCheckGitRepoUpdated = $false
)

function ImprimirTiempoTranscurrido {
    param (
        [string]$mensaje
    )
    
    # Calcula la diferencia de tiempo
    $horaActual = Get-Date
    $tiempoTranscurrido = $horaActual - $inicio
    # Imprime las marcas de tiempo y el tiempo transcurrido
    Write-Host -ForegroundColor Green "$mensaje, Tiempo transcurrido : $tiempoTranscurrido"
}

if (!$skipCheckGitRepoUpdated) {
    .\CheckGitRepoUpdated.ps1 . # el . representa el directorio actual
}

# Guarda la marca de tiempo de inicio
$inicio = Get-Date
Write-Host "Inicio: $inicio"

.\InstallOrUpdateD365foTools.ps1

Import-Module -Name d365fo.tools

# TODO Descartar este bloque para descargar. Luego implementaremos AzCopy
# Verificar si $urlDescarga o $rutaBacpac están vacíos
if ([string]::IsNullOrEmpty($urlDescarga) -eq $false) {
    # Descargar el archivo desde la URL proporcionada
    Write-Host -ForegroundColor Yellow "Descargando bacpac"
    Invoke-WebRequest -Uri $urlDescarga -OutFile $rutaBacpac
    ImprimirTiempoTranscurrido("Descargado el bacpac")
}

# Quitar la marca "unblock" del archivo descargado
Unblock-File -Path $rutaBacpac

# Descarga e instalación de SqlPackage
if ($includeInstallSqlPackage) {
    # Descarga e instalación de SqlPackage
    # Version number: 162.1.167
    # Build number: 162.1.167
    # Release date: October 19, 2023
    Write-Host -ForegroundColor Yellow "Instalando SqlPackage"
    $SqlPackagePath = 'C:\Temp\d365fo.tools\SqlPackage'
    Invoke-D365InstallSqlPackage -Path $SqlPackagePath -SkipExtractFromPage -Url "https://go.microsoft.com/fwlink/?linkid=2249738"
    ImprimirTiempoTranscurrido("Instalado el SqlPackage")
}

# Limpio tablas para agilizar el import
$rutaBacpacCleaned = .\CleanBacpac.ps1 -rutaBacpac $rutaBacpac
# Obtengo el nuevo path del bacpac limpio y extraigo el nombre de importación
$ImportedDatabaseName = [System.IO.Path]::GetFileNameWithoutExtension($rutaBacpac)
# Ejecuto la importación

try {
    if (-not (Test-Path -Path $rutaBacpacCleaned -PathType Leaf)) {
        throw [System.IO.FileNotFoundException] $rutaBacpacCleaned
    }
    Write-Host -ForegroundColor Yellow "Iniciando la importación de la base $ImportedDatabaseName con el archivo $rutaBacpacCleaned"
    $importResult = Import-D365Bacpac -ImportModeTier1 -BacpacFile "$rutaBacpacCleaned" -NewDatabaseName $ImportedDatabaseName
    $importResult

    if ($includeSwitch) {
        Write-Host -ForegroundColor Yellow "Deteniendo los servicios de D365"
        Stop-D365Environment

        [int]$AxDB_Original = (Get-D365Database -Name AXDB_ORIGINAL | Measure-Object).Count
        if ($AxDB_Original -gt 0) {
            Remove-D365Database -DatabaseName AxDB_original
        }

        Switch-D365ActiveDatabase -SourceDatabaseName $NombreBacpac
        if (!$skipBuildModels) {
            Write-Host -ForegroundColor Yellow "Compilando los módulos DevAx* FamiliaBercomat"
            Invoke-D365ProcessModule -Module "DevAx*" -ExecuteCompile
            Invoke-D365ProcessModule -Module "FamiliaBercomat" -ExecuteCompile
        }
        Write-Host -ForegroundColor Yellow "Iniciando los servicios de D365 Aos y Batch"
        Start-D365Environment -Aos -Batch
        Write-Host -ForegroundColor Yellow "Sincronizando database"
        Invoke-D365DbSync
        ImprimirTiempoTranscurrido("DB sincronizada")
    }

    if ($reinstallCsu) {
        [System.Environment]::MachineName
        ..\CommerceStoreScaleUnitSetupInstaller\InstallScaleUnit.ps1 ..\CommerceStoreScaleUnitSetupInstaller\ConfigFiles\
    }
}
catch {
    Write-Host -ForegroundColor Red "Error desde la limpieza en adelante: $_.Exception.Message"
}

# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
$tiempoTranscurrido = $fin - $inicio
Write-Host -ForegroundColor Magenta "Tiempo total transcurrido: $tiempoTranscurrido"
