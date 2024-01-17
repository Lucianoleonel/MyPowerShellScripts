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
$tablesToClear = Get-D365BacpacTable -Path $rutaBacpac -Table $tableList | 
    Where-Object { $_.Name -notin $tablesToExclude } | 
    Select-Object -ExpandProperty Name

Write-Host -ForegroundColor Yellow "Tablas a limpiar"
$tablesToClear | ForEach-Object {
    Write-Host "`t$_"
}

Write-Host -ForegroundColor Yellow "Executando limpieza"
Clear-D365BacpacTableData -Path $rutaBacpac -Table $tablesToClear -ClearFromSource

# Guarda la marca de tiempo de finalización
$fin = Get-Date
# Imprime las marcas de tiempo y el tiempo transcurrido
Write-Host "Inicio: $inicio"
Write-Host "Final: $fin"
$tiempoTranscurrido = $fin - $inicio
Write-Host -ForegroundColor Green "Tiempo limpieza bacpac transcurrido: $tiempoTranscurrido"