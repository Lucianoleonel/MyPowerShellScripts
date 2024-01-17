# Nombre del módulo a verificar
$nombreModulo = "d365fo.tools"

# Obtener información sobre la versión instalada
$moduloInstalado = Get-Module -ListAvailable | Where-Object { $_.Name -eq $nombreModulo }

# Obtener información sobre la versión más reciente disponible
$versionMasReciente = (Find-Module -Name $nombreModulo).Version

if ($null -eq $moduloInstalado) {
    Write-Host -ForegroundColor Yellow "El módulo '$nombreModulo' no está instalado. Se instalará la versión más reciente."
    Install-Module -Name $nombreModulo
} elseif ($moduloInstalado.Version[0] -lt $versionMasReciente) {
    $version = $moduloInstalado.Version[0]
    Write-Host -ForegroundColor Yellow "El módulo '$nombreModulo' está instalado con la versión ($version), pero hay una versión más reciente disponible ($versionMasReciente). Se ejecuta actualización."
    Update-Module -name $nombreModulo -Force
} else {
    Write-Host -ForegroundColor Cyan "El módulo '$nombreModulo' está actualizado a la versión más reciente ($versionMasReciente)."
}
