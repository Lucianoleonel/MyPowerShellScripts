[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateNotNullOrEmpty()]$path,
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateNotNullOrEmpty]$folderToRemove
)

Get-ChildItem -Path $path -Recurse -Force -Directory -Include $folderToRemove | Remove-Item -Recurse -Confirm:$false -Force