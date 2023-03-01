[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateNotNullOrEmpty()]$path,
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateNotNullOrEmpty]$folder
)

Get-ChildItem -Path $path -Recurse -Force -Directory -Include $folder | Remove-Item -Recurse -Confirm:$false -Force