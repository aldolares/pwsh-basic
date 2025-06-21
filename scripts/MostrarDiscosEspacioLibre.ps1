param(
    [int]$PorcentajeMinimo = 100
)

function Show-Barra {
    param(
        [string]$Unidad,
        [int]$GBLibres,
        [int]$GBTotal
    )
    $porcentajeLibre = if ($GBTotal -gt 0) { [math]::Round(($GBLibres / $GBTotal) * 100, 0) } else { 0 }
    $usado = [math]::Round(20 * (100 - $porcentajeLibre) / 100)
    $libre = 20 - $usado
    $barra = ('█' * $usado) + ('░' * $libre)
    if ($porcentajeLibre -lt $PorcentajeMinimo) {
        Write-Output ("Unidad: {0}  [{1}]  {2}/{3}GB Libres [{4}%]" -f $Unidad, $barra, $GBLibres, $GBTotal, $porcentajeLibre)
    }
}

if ($IsWindows) {
    # Windows: usa WMI
    Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $totalGB = [math]::Floor($_.Size / 1GB)
        $freeGB = [math]::Floor($_.FreeSpace / 1GB)
        Show-Barra -Unidad $_.DeviceID -GBLibres $freeGB -GBTotal $totalGB
    }
}

elseif ($IsMacOS -or $IsLinux) {
    # macOS y Linux: usa df -kP para formato POSIX y filtra solo discos relevantes
    $df = df -kP | Select-Object -Skip 1
    foreach ($line in $df) {
        $parts = ($line -replace '\s+', ' ').Trim().Split(' ')
        if ($parts.Count -eq 6) {
            if ([int]::TryParse($parts[1], [ref]$null) -and [int]::TryParse($parts[3], [ref]$null)) {
                $mount = $parts[5]
                $sizeGB = [math]::Floor([int]$parts[1] / 1024 / 1024)
                $availGB = [math]::Floor([int]$parts[3] / 1024 / 1024)
                if ($sizeGB -gt 0 -and -not ($mount -like '/System/Volumes/*') -and -not ($mount -like '/dev*')) {
                    Show-Barra -Unidad $mount -GBLibres $availGB -GBTotal $sizeGB
                }
            }
        }
    }
} else { Write-Output "Sistema operativo no soportado."}