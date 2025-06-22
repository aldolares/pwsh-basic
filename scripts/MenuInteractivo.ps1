# Dibuja el menú interactivo con las opciones y resalta la opción activa
function Draw-BoxMenu {
    param(
        [string[]]$Options,
        [int]$ActiveIndex
    )
    $boxWidth = 40
    $borderFg = 'DarkGray'; $boxBg = 'White'; $iconFg = 'Cyan'; $titleFg = 'Black'; $subtitleFg = 'Gray'; $optionFg = 'Black'; $optionActiveFg = 'White'; $optionActiveBg = 'Cyan'
    Clear-Host
    $top = "╔{0}╗" -f ('═' * ($boxWidth-2))
    $bottom = "╚{0}╝" -f ('═' * ($boxWidth-2))
    Write-Host $top -ForegroundColor $borderFg -BackgroundColor $boxBg
    Write-Host ("║  "+("╔═╦╗")+"  MENÚ PRINCIPAL"+(' ' * ($boxWidth-24))+"║") -ForegroundColor $borderFg -BackgroundColor $boxBg
    Write-Host ("║  "+("╚═╩╝")+"  Use ↑ ↓ y Enter"+(' ' * ($boxWidth-25))+"║") -ForegroundColor $borderFg -BackgroundColor $boxBg
    Write-Host ("╠{0}╣" -f ('═' * ($boxWidth-2))) -ForegroundColor $borderFg -BackgroundColor $boxBg
    Write-Host ("║"+(' ' * ($boxWidth-2))+"║") -ForegroundColor $borderFg -BackgroundColor $boxBg
    for ($i = 0; $i -lt $Options.Length; $i++) {
        $opt = $Options[$i]
        if ($i -eq $ActiveIndex) {
            Write-Host ("║ "+("▶ $opt").PadRight($boxWidth-4)+" ║") -ForegroundColor $optionActiveFg -BackgroundColor $optionActiveBg
        } else {
            Write-Host ("║   "+$opt.PadRight($boxWidth-5)+"║") -ForegroundColor $optionFg -BackgroundColor $boxBg
        }
        if ($i -lt $Options.Length-1) {
            Write-Host ("║"+(' ' * ($boxWidth-2))+"║") -ForegroundColor $borderFg -BackgroundColor $boxBg
        }
    }
    Write-Host ("║"+(' ' * ($boxWidth-2))+"║") -ForegroundColor $borderFg -BackgroundColor $boxBg
    Write-Host $bottom -ForegroundColor $borderFg -BackgroundColor $boxBg
}

# Lee la tecla presionada por el usuario y retorna 'up', 'down' o 'enter'
function Read-MenuKey {
    $key = $null
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        switch ($key.Key) {
            'UpArrow'    { return 'up' }
            'DownArrow'  { return 'down' }
            'Enter'      { return 'enter' }
        }
    }
}

# Muestra los servicios activos/arrancados según el sistema operativo
function Show-Services {
    if ($IsWindows -or $IsMacOS) {
        Write-Host ($IsWindows ? "`nServicios arrancados:" : "`nServicios activos:") -ForegroundColor Magenta
        if ($IsWindows) {
            Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object Status, Name, DisplayName | Format-Table -AutoSize
        } else {
            ps -A -o pid,comm,user,etime | Where-Object { $_ -notmatch "root" } | Format-Table -AutoSize
        }
    } else {
        Write-Host "Sistema operativo no soportado para listar servicios." -ForegroundColor Red
    }
    Pause
}

# Abre una aplicación específica según el sistema operativo
function Open-App {
    param(
        [string]$winApp,
        [string]$macApp,
        [string]$desc
    )
    if ($IsWindows -or $IsMacOS) {
        Write-Host "Abriendo $desc..." -ForegroundColor Cyan
        if ($IsWindows) { Start-Process $winApp }
        else { Start-Process -FilePath "open" -ArgumentList "-a", $macApp }
    } else {
        Write-Host "Sistema Operativo no soportado para $desc." -ForegroundColor Red
    }
    Pause
}

$menuOptions = @(
    '🟢 Listar los servicios arrancados',
    '📅 Mostrar la fecha del sistema',
    '📝 Ejecutar el Bloc de notas',
    '🧮 Ejecutar la Calculadora',
    '🚪 Salir'
)
$active = 0
$exit = $false
while (-not $exit) {
    Draw-BoxMenu -Options $menuOptions -ActiveIndex $active
    $input = Read-MenuKey
    switch ($input) {
        'up'    { if ($active -gt 0) { $active-- } else { $active = $menuOptions.Length-1 } }
        'down'  { if ($active -lt $menuOptions.Length-1) { $active++ } else { $active = 0 } }
        'enter' {
            switch ($active) {
                0 { Show-Services }
                1 {
                    Write-Host "`nFecha y hora actual:" -ForegroundColor Magenta
                    Get-Date
                    Pause
                }
                2 { Open-App -winApp 'notepad.exe' -macApp 'TextEdit' -desc 'Bloc de notas/TextEdit' }
                3 { Open-App -winApp 'calc.exe' -macApp 'Calculator' -desc 'Calculadora' }
                4 { $exit = $true }
            }
        }
    }
}
Write-Host "`n¡Hasta luego!" -ForegroundColor Yellow

# Espera a que el usuario presione ENTER para continuar
function Pause {
    Write-Host "`nPresione ENTER para continuar..." -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
}
