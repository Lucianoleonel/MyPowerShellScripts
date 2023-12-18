# Definir variables
$extractedFolderPath = Read-Host -Prompt "Por favor, ingrese la ruta donde se encuentra el archivo (por ejemplo, C:\Axxon\FR.10.0.38)"
$runbookID = "$env:COMPUTERNAME-runbook"
$defaultTopologyPath = $extractedFolderPath + "\DefaultTopologyData.xml"
$AXUpdateInstaller = $extractedFolderPath + "\AXUpdateInstaller.exe"

# Preguntar si el archivo existe
if (Test-Path $extractedFolderPath -PathType Container) {
    Write-Host "La carpeta existe en la ruta especificada."

    
    if (Test-Path $defaultTopologyPath -PathType Leaf) {
        
        Set-Location $extractedFolderPath
        # Obtener la lista de servicios usando el comando AXUpdateInstaller.exe list
        $servicesList = & $AXUpdateInstaller list | Select-String "Version:"

        # Obtener solo los nombres de los servicios
        $serviceNames = $servicesList -replace '\s+Version:.*$', '' -replace '^\s+', ''

        #Actualiza el archivo DefaultTopology
        [xml]$xml = Get-Content $defaultTopologyPath
        $serviceModelList = $xml.SelectSingleNode("//ServiceModelList")
        $serviceModelList.RemoveAll()

        $serviceNames | ForEach-Object {
            $elementString = $xml.CreateElement('string')
            $elementString.InnerText = $_
            $serviceModelList.AppendChild($elementString)
        }
        $xml.Save($defaultTopologyPath)

        # Generar el runbook a partir del Topology
        Start-Process -FilePath $AXUpdateInstaller -ArgumentList "generate -runbookid=$runbookID -topologyfile=$defaultTopologyPath -servicemodelfile=DefaultServiceModelData.xml -runbookfile=$runbookID.xml" -Wait

        # Instalar el paquete
        Start-Process -FilePath $AXUpdateInstaller -ArgumentList "import -runbookfile=$runbookID.xml" -Wait

        #Ejecutar
        #Start-Process -FilePath $AXUpdateInstaller -ArgumentList "execute -runbookid=$runbookID" 
    }
    else {
        Write-Host "El archivo no existe dentro de la carpeta"
    }
}
else {
    Write-Host "La carpeta no existe en la ruta especificada. Verifica la ruta y vuelve a ejecutar el script."
}