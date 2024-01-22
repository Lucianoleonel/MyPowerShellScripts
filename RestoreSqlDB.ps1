[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $BackupFilePath
    ,
    [Parameter(Mandatory = $true)]
    [string]
    $Database = "AxDB"
)
# Configuración
$serverInstance = "localhost"  # Reemplaza con tu nombre de instancia

Restore-SqlDatabase -ServerInstance $serverInstance -Database $Database -BackupFile $BackupFilePath
