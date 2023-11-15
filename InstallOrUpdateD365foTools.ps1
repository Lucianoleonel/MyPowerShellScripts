param (
    [switch]$updateModule = $true
)
# Nombre del módulo a verificar
$nombreModulo = "d365fo.tools"

# Obtener información sobre la versión instalada
$moduloInstalado = Get-Module -ListAvailable | Where-Object { $_.Name -eq $nombreModulo }

# Obtener información sobre la versión más reciente disponible
$versionMasReciente = (Find-Module -Name $nombreModulo).Version

if ($moduloInstalado -eq $null) {
    Write-Host "El módulo '$nombreModulo' no está instalado. Se puede instalar la versión más reciente."
    Install-Module -Name d365fo.tools -Scope CurrentUser
} elseif ($moduloInstalado.Version[0] -lt $versionMasReciente) {
    $version = $moduloInstalado.Version[0]
    Write-Host "El módulo '$nombreModulo' está instalado con la versión ($version), pero hay una versión más reciente disponible ($versionMasReciente). Se ejecuta actualización."
    if ($updateModule) {
        Update-Module -name d365fo.tools -Force
    }
} else {
    Write-Host "El módulo '$nombreModulo' está actualizado a la versión más reciente ($versionMasReciente)."
}
