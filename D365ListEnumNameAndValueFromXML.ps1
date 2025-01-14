# Cargar el XML
param (
    [Parameter(Mandatory=$true)]
    [string]$rutaArchivoXML
)

[xml]$xmlContent = Get-Content -Path $rutaArchivoXML

# Extraer y proyectar Name y Value
$xmlContent.AxEnum.EnumValues.AxEnumValue | ForEach-Object {
    $name = $_.Name
    $value = if ($_.Value) { $_.Value } else { "N/A" }  # Si no tiene Value, se muestra N/A
    [PSCustomObject]@{
        Name  = $name
        Value = $value
    }
}
