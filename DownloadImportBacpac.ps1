param (
    [Parameter(Mandatory=$true)]
    [string]$rutaDestino
    ,
    # [Parameter(Mandatory=$true)]
    [string]$urlDescarga
    ,
    [bool]$includeSwitch = $false
    ,
    [bool]$includeInstallSqlPackage = $false
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

# Guarda la marca de tiempo de inicio
$inicio = Get-Date
Write-Host "Inicio: $inicio"

Import-Module -Name d365fo.tools

# Verificar si $urlDescarga o $rutaDestino están vacíos
if ([string]::IsNullOrEmpty($urlDescarga) -eq $false) {
    # Descargar el archivo desde la URL proporcionada
    Write-Host -ForegroundColor Yellow "Descargando bacpac"
    Invoke-WebRequest -Uri $urlDescarga -OutFile $rutaDestino
    ImprimirTiempoTranscurrido("Descargado el bacpac")
}

# Quitar la marca "unblock" del archivo descargado
Unblock-File -Path $rutaDestino

# Invoke-D365InstallAzCopy

# Primero borro la carpeta
if ($includeInstallSqlPackage) {
    $rutaSqlPackage = "C:\Temp\d365fo.tools\SqlPackage"
    if (Test-Path $rutaSqlPackage -PathType Container) {
        Write-Host -ForegroundColor Yellow "Borrando SqlPackage encontrado"
        Remove-Item -Path $rutaSqlPackage -Recurse -Force -ErrorAction SilentlyContinue
    }
    # Descarga e instalación de SqlPackage
    # Version number: 162.1.167
    # Build number: 162.1.167
    # Release date: October 19, 2023
    Write-Host -ForegroundColor Yellow "Instalando SqlPackage"
    Invoke-D365InstallSqlPackage -SkipExtractFromPage -Url "https://go.microsoft.com/fwlink/?linkid=2249738" -ErrorAction SilentlyContinue
    ImprimirTiempoTranscurrido("Instalado el SqlPackage")
}

# PARA PROBAR MAS ADELANTE
# $toolsList = dotnet tool list -g
# if ($toolsList -match "SqlPackage") {
#     Write-Host "SqlPackage está instalado. Usando 'dotnet tool update -g SqlPackage' para instalarlo."
#     dotnet tool update -g microsoft.sqlpackage
# } else {
#     Write-Host "SqlPackage no está instalado. Usando 'dotnet tool install -g SqlPackage' para instalarlo."
#     dotnet tool install -g microsoft.sqlpackage
# }

$NombreBacpac = [System.IO.Path]::GetFileNameWithoutExtension($rutaDestino)
$RutaBacpac = $rutaDestino
Write-Host -ForegroundColor Yellow "Importando $NombreBacpac bacpac descargado"
Import-D365Bacpac -ImportModeTier1 -BacpacFile $RutaBacpac -NewDatabaseName $NombreBacpac
ImprimirTiempoTranscurrido("Bacpac importado")

Write-Host -ForegroundColor Yellow "Deteniendo los servicios de D365"
Stop-D365Environment

if ((Get-D365Database -Name AXDB_ORIGINAL).Count -gt 0)
{
    Remove-D365Database -DatabaseName AxDB_original
}

Switch-D365ActiveDatabase -SourceDatabaseName $NombreBacpac
Write-Host -ForegroundColor Yellow "Iniciando los servicios de D365"
Start-D365Environment -Aos -Batch
Write-Host -ForegroundColor Yellow "Sincronizando database"
Invoke-D365DbSync
ImprimirTiempoTranscurrido("DB sincronizada")

# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
$tiempoTranscurrido = $fin - $inicio
Write-Host -ForegroundColor Magenta "Tiempo total transcurrido: $tiempoTranscurrido"
