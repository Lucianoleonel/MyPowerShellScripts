# Obtener la clave en formato de SecureString
$clave = Read-Host -Prompt "Ingrese la clave" -AsSecureString

# Convertir el SecureString en texto cifrado
$claveCifrada = $clave | ConvertFrom-SecureString

# Guardar el texto cifrado en un archivo RDP
# $archivoRDP = "C:\Ruta\Archivo.rdp"
# Set-Content -Path $archivoRDP -Value "password 51:$claveCifrada"
Write-Host $claveCifrada
