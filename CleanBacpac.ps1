param (
    [Parameter(Mandatory = $true)]
    [string]$rutaBacpac
)

# Guarda la marca de tiempo de inicio
$inicio = Get-Date
Write-Host "Inicio: $inicio"

# Limpio tablas para agilizar el import
$CarpetaBacpac = [System.IO.Path]::GetDirectoryName($rutaBacpac)
$NombreSinExtensionBacpac = [System.IO.Path]::GetFileNameWithoutExtension($rutaBacpac)
$RutaBacpacCleaned = Join-Path $CarpetaBacpac -ChildPath "$NombreSinExtensionBacpac.cleaned.bacpac"
[string[]] $tablesToClear = "DOCUHISTORY","EVENTCUD","SYSEXCEPTIONTABLE","DMFSTAGINGLOGDETAILS","SYSENCRYPTIONLOG", "DEVAXCMMRTSLOGTABLE", "FBMPRICEDISCTABLEINTERFACE", "AXXDOCEINVOICELOG"
$tablesToClear += "dbo.AXXTAXFILE*"
[string[]] $tablesToClear = "DOCUHISTORY","EVENTCUD","SYSEXCEPTIONTABLE","DMFSTAGINGLOGDETAILS","SYSENCRYPTIONLOG", "DEVAXCMMRTSLOGTABLE", "FBMPRICEDISCTABLEINTERFACE", "AXXDOCEINVOICELOG", "dbo.AXXTAXFILE*"
Clear-D365BacpacTableData -Path $rutaBacpac -Table "DOCUHISTORY","EVENTCUD","SYSEXCEPTIONTABLE","DMFSTAGINGLOGDETAILS","SYSENCRYPTIONLOG" -OutputPath $RutaBacpacCleaned

# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
$tiempoTranscurrido = $fin - $inicio
Write-Host -ForegroundColor Magenta "Tiempo total transcurrido: $tiempoTranscurrido"
