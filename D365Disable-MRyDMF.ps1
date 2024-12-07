Import-Module -Name d365fo.tools

#region Disable services
Write-Host "Setting web browser homepage to the local environment"
Get-D365Url | Set-D365StartPage
Write-Host "Setting Management Reporter to manual startup to reduce churn and Event Log messages"
Stop-D365Environment -FinancialReporter
Get-D365Environment -FinancialReporter | Set-Service -StartupType Disabled
Write-Host "Setting DMF manual startup to reduce churn and Event Log messages"
Stop-D365Environment -DMF
Get-D365Environment -DMF | Set-Service -StartupType Disabled
Write-Host "Setting Windows Defender rules to speed up compilation time"
Add-D365WindowsDefenderRules -Silent
#endregion
