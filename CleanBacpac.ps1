param (
    [Parameter(Mandatory = $true)]
    [string]$rutaBacpac
)

# Guarda la marca de tiempo de inicio
$inicio = Get-Date
Write-Host "Inicio: $inicio"
Write-Host -ForegroundColor Yellow "Limpiando el bacpac $rutaBacpac"

# Lista de tablas a limpiar
[string[]] $tableList = @("DOCUHISTORY", "EVENTCUD", "DMFSTAGINGLOGDETAILS", "SYSEXCEPTIONTABLE", "SYSENCRYPTIONLOG", "SMMTransLog")
$tableList += @("BATCH", "BATCHCONSTRAINTS", "BATCHCONSTRAINTSHISTORY", "BATCHHISTORY", "BATCHJOB", "BATCHJOBALERTS", "BATCHJOBHISTORY")
$tableList += @("DEVAXCMMRTSLOGTABLE", "FBMPRICEDISCTABLEINTERFACE", "AXXDOCEINVOICELOG", 'AxxTaxFile*', '*Staging')
# Lista de tablas a excluir de la limpieza
[string[]] $tablesToExclude = @("dbo.AXXTAXFILEPARAMETERS", "dbo.OTRAS_TABLAS")
$tablesToClear = Get-D365BacpacTable -Path $rutaBacpac -Table $tableList
$tablesToClear = $tablesToClear | Where-Object { $_.Name -notin $tablesToExclude }

if ($tablesToClear.Length -gt 0) {
    Write-Host -ForegroundColor Yellow "Tablas a limpiar"
    $tablesToClear
    $sumOriginalSize = ($tablesToClear | Measure-Object OriginalSize -Sum).Sum / 1GB
    $sumOriginalSizeGB = "Total Original Size {0:N2} GB" -f $sumOriginalSize
    Write-Host -ForegroundColor Green $sumOriginalSizeGB
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