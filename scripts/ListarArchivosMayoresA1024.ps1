# ListarArchivosMayoresA1024.ps1
# Este script muestra un listado de los archivos de un directorio que pesen más de 1024 bytes.
# Si no se recibe un parámetro, se usa el directorio actual.

param(
    [string]$Directorio = "."
)

$archivos = Get-ChildItem -Path $Directorio -File | Where-Object { $_.Length -gt 1024 }
$totalArchivos = (Get-ChildItem -Path $Directorio -File).Count
$porcentaje = if ($totalArchivos -gt 0) { [math]::Round(($archivos.Count / $totalArchivos) * 100, 2) } else { 0 }
$archivos | Select-Object Name, Length | Format-Table -AutoSize
Write-Host "Total de archivos encontrados: $($archivos.Count)"
Write-Host "Total de archivos en el directorio: $totalArchivos"
Write-Host "Porcentaje de archivos mayores a 1024 bytes: $porcentaje%"
