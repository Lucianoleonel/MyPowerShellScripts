[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateNotNullOrEmpty()]$path
)

$mypath = $MyInvocation.MyCommand.Path
$workinFolder = Split-Path $mypath -Parent

# Get-ChildItem -Path $path -Recurse -Force -Directory -Include 'bin', 'obj' | Remove-Item -Recurse -Confirm:$false -Force

& $workinFolder\DeleteSubFolders.ps1 $path 'bin'
& $workinFolder\DeleteSubFolders.ps1 $path 'obj'