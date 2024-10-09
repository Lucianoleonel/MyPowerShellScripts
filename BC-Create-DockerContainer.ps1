#Requires -RunAsAdministrator

param (
    [Parameter(Mandatory=$true)]
    [string]
    $containerName
    ,
    [ValidateSet('mx', 'nl', 'it', 'in', 'is', 'no', 'us', 'w1', 'se', 'nz', 'ru', 'gb', 'ca', 'ch', 'be', 'at', 'au', 'cz', 'fi', 'fr', 'es', 'de', 'dk')]
    $country = 'w1'
    ,
    [string]
    $numericVersionBC
    ,
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [System.IO.FileInfo]
    $licenseFile
    ,
    [int]
    $memoryLimit
)

Import-Module BcContainerHelper

$password = 'P@ssw0rd'
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential 'admin', $securePassword
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'OnPrem' -country $country `
    $(if (-not [string]::IsNullOrEmpty($numericVersionBC)) { -version $numericVersionBC }) `
    -select 'Latest'

New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -updateHosts `
    $(if ($licenseFile -ne $null) { -licenseFile $licenseFile } ) `
    $(if ($memoryLimit -gt 0) { -memoryLimit "${memoryLimit}G" } ) 