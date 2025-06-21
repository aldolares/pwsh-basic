# Script: RenombrarJPGsConFecha.ps1
# Descripción: Renombra todos los archivos .jpg del directorio especificado (o actual) añadiendo un prefijo con la fecha actual (año, mes, día).

param(
    [string]$Directorio = '.'
)

# Obtener todos los archivos en el directorio
$archivosTotales = Get-ChildItem -Path $Directorio -File
$totalArchivos = $archivosTotales.Count

# Obtener todos los archivos .jpg (ignorando mayúsculas/minúsculas)
$archivosJPG = Get-ChildItem -Path $Directorio -File | Where-Object { $_.Extension -ieq ".jpg" }
$cantidadJPG = $archivosJPG.Count
$porcentajeJPG = if ($totalArchivos -gt 0) { [math]::Round(($cantidadJPG / $totalArchivos) * 100, 2) } else { 0 }

Write-Host "Archivos .jpg encontrados:" -ForegroundColor Cyan
$archivosJPG | Select-Object Name | Format-Table -AutoSize
Write-Host "Total de archivos en el directorio: $totalArchivos"
Write-Host "Cantidad de archivos .jpg: $cantidadJPG"
Write-Host "Porcentaje de archivos .jpg: $porcentajeJPG%"

# Renombrar los archivos .jpg
$fecha = Get-Date -Format "yyyyMMdd"
$archivosJPG | ForEach-Object {
    $nuevoNombre = "$fecha-$($_.Name)"
    Rename-Item -Path $_.FullName -NewName $nuevoNombre
}
