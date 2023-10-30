param (
    [Parameter(Mandatory=$true)]
    [string]$urlDescarga,

    [Parameter(Mandatory=$true)]
    [string]$rutaDestino
)

Import-Module -Name d365fo.tools

# Guarda la marca de tiempo de inicio
$inicio = Get-Date
Write-Host "Inicio: $inicio"

# Descargar el archivo desde la URL proporcionada
# Invoke-WebRequest -Uri $urlDescarga -OutFile $rutaDestino

# Calcula la diferencia de tiempo
$horaActual = Get-Date
$tiempoTranscurrido = $horaActual - $inicio
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Tiempo transcurrido, Descargado el bacpac: $tiempoTranscurrido"

# Quitar la marca "unblock" del archivo descargado
Unblock-File -Path $rutaDestino

# Invoke-D365InstallAzCopy

# Primero borro la carpeta
$rutaSqlPackage = "C:\Temp\d365fo.tools\SqlPackage"
if (Test-Path $rutaSqlPackage -PathType Container) {
    Remove-Item -Path $rutaSqlPackage -Recurse -Force -ErrorAction SilentlyContinue
}
# Descarga e instalación de SqlPackage
# Version number: 162.1.167
# Build number: 162.1.167
# Release date: October 19, 2023
Invoke-D365InstallSqlPackage -SkipExtractFromPage -Url "https://go.microsoft.com/fwlink/?linkid=2249738" -ErrorAction SilentlyContinue

# Calcula la diferencia de tiempo
$horaActual = Get-Date
$tiempoTranscurrido = $horaActual - $inicio
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Tiempo transcurrido, instalado el SqlPackage: $tiempoTranscurrido"

$NombreBacpac = [System.IO.Path]::GetFileNameWithoutExtension($rutaDestino)
$RutaBacpac = $rutaDestino
Import-D365Bacpac -ImportModeTier1 -BacpacFile $RutaBacpac -NewDatabaseName $NombreBacpac
Write-Host -ForegroundColor Green $RutaBacpac
Write-Host -ForegroundColor Green $NombreBacpac

# Calcula la diferencia de tiempo
$horaActual = Get-Date
$tiempoTranscurrido = $horaActual - $inicio
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Tiempo transcurrido, instalado el SqlPackage: $tiempoTranscurrido"


# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
Write-Host "Tiempo total transcurrido: $tiempoTranscurrido"
