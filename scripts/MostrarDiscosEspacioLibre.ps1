param(
    [int]$PorcentajeMinimo = 20
)

function Mostrar-Barra {
    param(
        [int]$PorcentajeLibre
    )
    $total = 20
    $usado = [math]::Round($total * (100 - $PorcentajeLibre) / 100)
    $libre = $total - $usado
    $barra = ('█' * $usado) + ('░' * $libre)
    return $barra
}

if ($IsWindows) {
    # Windows: usa WMI
    Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $totalGB = [math]::Floor($_.Size / 1GB)
        $freeGB = [math]::Floor($_.FreeSpace / 1GB)
        if ($_.Size -gt 0) {
            $porcentajeLibre = ($_.FreeSpace / $_.Size) * 100
            if ($porcentajeLibre -lt $PorcentajeMinimo) {
                $barra = Mostrar-Barra -PorcentajeLibre ([math]::Round($porcentajeLibre,0))
                Write-Output ("Unidad: {0}  [{1}]  {2}/{3}GB Libres [{4}%]" -f $_.DeviceID, $barra, $freeGB, $totalGB, [math]::Round($porcentajeLibre,0))
            }
        }
    }
}
elseif ($IsMacOS -or $IsLinux) {
    # macOS y Linux: usa df -kP para formato POSIX y filtra solo la raíz
    $df = df -kP | Select-Object -Skip 1
    foreach ($line in $df) {
        $parts = ($line -replace '\s+', ' ').Trim().Split(' ')
        if ($parts.Count -eq 6) {
            if ([int]::TryParse($parts[1], [ref]$null) -and [int]::TryParse($parts[3], [ref]$null)) {
                $mount = $parts[5]
                if ($mount -eq "/") {
                    $sizeGB = [math]::Floor([int]$parts[1] / 1024 / 1024)
                    $availGB = [math]::Floor([int]$parts[3] / 1024 / 1024)
                    $porcentajeLibre = if ($sizeGB -gt 0) { ($availGB / $sizeGB) * 100 } else { 0 }
                    if ($porcentajeLibre -lt $PorcentajeMinimo) {
                        $barra = Mostrar-Barra -PorcentajeLibre ([math]::Round($porcentajeLibre,0))
                        Write-Output ("Montaje: {0}  [{1}]  {2}/{3}GB Libres [{4}%]" -f $mount, $barra, $availGB, $sizeGB, [math]::Round($porcentajeLibre,0))
                    }
                }
            }
        }
    }
} else {
    Write-Output "Sistema operativo no soportado."
}
