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
# Import-Module -Name SQLPS
Import-Module -Name SqlServer

# Configuración
$serverInstance = "localhost"  # Reemplaza con tu nombre de instancia

Restore-SqlDatabase -ServerInstance $serverInstance -Database $Database -BackupFile $BackupFilePath
