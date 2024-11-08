[CmdletBinding()]
param (
    [string]
    $ExtraDescription
    ,
    [string]
    $Database = "AxDB"
    ,
    [string]
    $TargetPath = "J:\MSSQL_BACKUP"
)

$backupfile = "$TargetPath\$Database-$env:computername-$(Get-Date -format "yyyyMMdd-HHmm")"
if ([string]::IsNullOrEmpty($ExtraDescription) ){
    $backupfile += ".bak"
}
else {
    $ExtraDescription = $ExtraDescription.Replace(" ", "");
    $backupfile += "_$ExtraDescription.bak"
}
Write-Host -ForegroundColor Green $backupfile
Backup-SqlDatabase -ServerInstance "localhost" -Database $Database -BackupFile $backupfile -CompressionOption On
