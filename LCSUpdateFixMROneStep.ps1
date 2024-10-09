
# 1. Define las rutas para los directorios y el archivo
$basePath = "$ENV:SERVICEDRIVE\DeployablePackages\"  # Ruta base de las carpetas
$latestFolder = Get-ChildItem -Path $basePath -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$scriptsPath = Join-Path $latestFolder.FullName "MROneBox\Scripts\Update"
$filePath = Join-Path $scriptsPath "AutoRunDVT.ps1"
$backupFilePath = Join-Path $scriptsPath "AutoRunDVT_backup.ps1"

# 2. Verifica si el archivo existe
if (Test-Path $filePath) {
    
    # 3. Haz una copia del archivo original
    Copy-Item -Path $filePath -Destination $backupFilePath -Force
    Write-Host "Copia de seguridad creada en $backupFilePath"
    
    # 4. Limpia el contenido del archivo original
    Set-Content -Path $filePath -Value ""
    Write-Host "Contenido de AutoRunDVT.ps1 eliminado."
    
    # 5. Verifica que el archivo esté vacío
    $fileContent = Get-Content -Path $filePath
    if ($fileContent -eq "") {
        Write-Host "Verificación exitosa: AutoRunDVT.ps1 está vacío."
    } else {
        Write-Host "Error: El archivo AutoRunDVT.ps1 no está vacío."
    }

} else {
    Write-Host "Error: El archivo AutoRunDVT.ps1 no fue encontrado."
}