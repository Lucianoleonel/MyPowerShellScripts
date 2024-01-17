param (
    [Parameter(Mandatory = $true)]
    [string]$rutaBacpac
)

# Guarda la marca de tiempo de inicio
$inicio = Get-Date
Write-Host "Inicio: $inicio"
Write-Host -ForegroundColor Yellow "Limpiando el bacpac $rutaBacpac"

# Lista de tablas a limpiar
[string[]] $tableList = "DOCUHISTORY","EVENTCUD","SYSEXCEPTIONTABLE","DMFSTAGINGLOGDETAILS","SYSENCRYPTIONLOG", "DEVAXCMMRTSLOGTABLE", "FBMPRICEDISCTABLEINTERFACE", "AXXDOCEINVOICELOG", 'AxxTaxFile*', '*Staging', "SMMTransLog"
# Lista de tablas a excluir de la limpieza
[string[]] $tablesToExclude = "dbo.AXXTAXFILEPARAMETERS", "dbo.AXXTAXFILEPARAMETERS"
$tablesToClear = Get-D365BacpacTable -Path $rutaBacpac -Table $tableList
$tablesToClear = $tablesToClear | Where-Object { $_.Name -notin $tablesToExclude }

if ($tablesToClear.Length -gt 0) {
    Write-Host -ForegroundColor Yellow "Tablas a limpiar"
    $tablesToClear
    $tablesToClear = $tablesToClear | Select-Object -ExpandProperty Name
        
    Write-Host -ForegroundColor Yellow "Executando limpieza"
    Clear-D365BacpacTableData -Path $rutaBacpac -Table $tablesToClear -ClearFromSource
}
if ($tablesToClear.Length -eq 0) {
    Write-Host -ForegroundColor Yellow "No se encontraron tablas para limpiar, posiblemente el bacpac está limpio"
}

# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
$tiempoTranscurrido = $fin - $inicio
Write-Host -ForegroundColor Green "Tiempo limpieza bacpac transcurrido: $tiempoTranscurrido"