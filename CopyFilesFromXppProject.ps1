param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$true)]
    [string]$AosModelPath,

    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
)

# Cargar el archivo XML
[xml]$xmlContent = Get-Content -Path $ProjectPath

# Extraer todos los valores del atributo "Include" de los nodos "Content"
$includes = $xmlContent.Project.ItemGroup.Content | ForEach-Object { $_.Include }

# Procesar cada valor "Include"
foreach ($include in $includes) {
    # Separar en carpeta y nombre de archivo
    $parts = $include -split '\\'
    $folderName = $parts[0]
    $fileName = $parts[1] + '.xml'

    # Crear la ruta completa del archivo fuente
    $sourceFilePath = Join-Path -Path $AosModelPath -ChildPath $include
    $sourceFilePath += '.xml'

    # Verificar si el archivo existe
    if (Test-Path -Path $sourceFilePath) {
        # Crear la ruta de destino
        $destinationFolderPath = Join-Path -Path $DestinationPath -ChildPath $folderName
        $destinationFilePath = Join-Path -Path $destinationFolderPath -ChildPath $fileName

        # Verificar si la carpeta de destino existe, si no, crearla
        if (-not (Test-Path -Path $destinationFolderPath)) {
            New-Item -ItemType Directory -Path $destinationFolderPath -Force
        }

        # Copiar el archivo al destino
        Copy-Item -Path $sourceFilePath -Destination $destinationFilePath -Force
        Write-Host "Archivo '$fileName' copiado exitosamente a '$destinationFolderPath'."
    } else {
        Write-Warning "El archivo '$sourceFilePath' no existe y no se copiará."
    }
}

Write-Host "Proceso completado."
