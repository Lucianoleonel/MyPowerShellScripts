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
# Lista de tablas a limpiar
[string[]] $tableList = "DOCUHISTORY","EVENTCUD","SYSEXCEPTIONTABLE","DMFSTAGINGLOGDETAILS","SYSENCRYPTIONLOG", "DEVAXCMMRTSLOGTABLE", "FBMPRICEDISCTABLEINTERFACE", "AXXDOCEINVOICELOG", 'AxxTaxFile*', '*Staging' 
# Lista de tablas a excluir de la limpieza
[string[]] $tablesToExclude = "dbo.AXXTAXFILEPARAMETERS", "dbo.AXXTAXFILEPARAMETERS"
$tablesToClear = Get-D365BacpacTable -Path $rutaBacpac -Table $tableList 
    | Where-Object { $_.Name -notin $tablesToExclude }
    | Select-Object -ExpandProperty Name

Write-Host -ForegroundColor Yellow "Tablas a limpiar"
$tablesToClear | ForEach-Object {
    Write-Host "    "$_
}
Write-Host -ForegroundColor Yellow "Executando limpieza"
if (Test-Path $RutaBacpacCleaned -PathType Any) {
    Remove-Item -Path $RutaBacpacCleaned
}
Clear-D365BacpacTableData -Path $rutaBacpac -Table $tablesToClear -OutputPath $RutaBacpacCleaned

# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
$tiempoTranscurrido = $fin - $inicio
Write-Host -ForegroundColor Green "Tiempo limpieza bacpac transcurrido: $tiempoTranscurrido"
