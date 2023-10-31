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

# PARA PROBAR MAS ADELANTE
$toolsList = dotnet tool list -g
if ($toolsList -match "SqlPackage") {
    Write-Host "SqlPackage está instalado. Usando 'dotnet tool update -g SqlPackage' para instalarlo."
    dotnet tool update -g microsoft.sqlpackage
} else {
    $SqlPackagePath = 'C:\Temp\d365fo.tools\SqlPackage'
    Write-Host "SqlPackage no está instalado. Usando 'dotnet tool install SqlPackage -g $SqlPackagePath' para instalarlo."
    dotnet tool install microsoft.sqlpackage -g $SqlPackagePath
}

$NombreBacpac = [System.IO.Path]::GetFileNameWithoutExtension($rutaDestino)
$RutaBacpac = $rutaDestino
Write-Host -ForegroundColor Yellow "Importando $NombreBacpac bacpac descargado"
# Import-D365Bacpac -ImportModeTier1 -BacpacFile $RutaBacpac -NewDatabaseName $NombreBacpac
ImprimirTiempoTranscurrido("Bacpac importado")

if ($includeSwitch) {
    Write-Host -ForegroundColor Yellow "Deteniendo los servicios de D365"
    Stop-D365Environment

    [int]$AxDB_Original= (Get-D365Database -Name AXDB_ORIGINAL | Measure-Object).Count
    if ($AxDB_Original -gt 0) {
        Remove-D365Database -DatabaseName AxDB_original
    }

    Switch-D365ActiveDatabase -SourceDatabaseName $NombreBacpac
    Write-Host -ForegroundColor Yellow "Iniciando los servicios de D365"
    Start-D365Environment -Aos -Batch
    Write-Host -ForegroundColor Yellow "Sincronizando database"
    Invoke-D365DbSync
    ImprimirTiempoTranscurrido("DB sincronizada")
}

# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
$tiempoTranscurrido = $fin - $inicio
Write-Host -ForegroundColor Magenta "Tiempo total transcurrido: $tiempoTranscurrido"
