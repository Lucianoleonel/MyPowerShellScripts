[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$BackupFilePath
    ,
    [Parameter(Mandatory = $true)]
    [string]$Database = "AxDB"
    ,
    [switch]$RelocateFile = $false
    ,
    [string]$FilepathData
    ,
    [string]$FilepathLog
    ,
    [string]$LogicalDataName
    ,
    [string]$LogicalLogName
)

if ($RelocateFile) {
    if (-not $FilepathData) {
        throw "El parámetro $FilepathData es obligatorio cuando $RelocateFile está activado."
    }
    if (-not $FilepathLog) {
        throw "El parámetro $FilepathLog es obligatorio cuando $RelocateFile está activado."
    }
    if (-not $LogicalDataName) {
        throw "El parámetro $LogicalDataName es obligatorio cuando $RelocateFile está activado."
    }
    if (-not $LogicalLogName) {
        throw "El parámetro $LogicalLogName es obligatorio cuando $RelocateFile está activado."
    }
}

# Import-Module -Name SQLPS
Import-Module -Name SqlServer

# Configuración
$serverInstance = "localhost"  # Reemplaza con tu nombre de instancia

# Obtener el nombre del archivo .bak sin la extensión
$newFileName = [System.IO.Path]::GetFileNameWithoutExtension($BackupFilePath)

# Crear objetos RelocateFile para los archivos de datos y registro
$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($LogicalDataName, "$FilepathData\$newFileName.mdf")
$RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($LogicalLogName, "$FilepathLog\${newFileName}_log.ldf")

Restore-SqlDatabase -ServerInstance $serverInstance -Database $Database -BackupFile $BackupFilePath -RelocateFile @($RelocateData, $RelocateLog)
