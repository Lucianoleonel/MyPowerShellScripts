[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateNotNullOrEmpty()]$path
)

# Get-ChildItem -Path $path -Recurse -Force -Directory -Include 'bin', 'obj' | Remove-Item -Recurse -Confirm:$false -Force
.\DeleteSubFolders.ps1 $path 'bin'
.\DeleteSubFolders.ps1 $path 'obj'