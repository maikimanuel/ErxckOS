$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$file = Join-Path $root 'app/Scripts/ErxckOS.Power.ps1'
if (-not (Test-Path $file)) { throw 'Falta el modulo de perfiles laptop/PC' }
. $file
$script:passed = 0
function Assert-Equal($Actual, $Expected, [string]$Name) {
    if ($Actual -ne $Expected) { throw "$Name : esperado '$Expected', recibido '$Actual'" }
    $script:passed++
}
Assert-Equal (Resolve-ErxckOSDeviceType -PCSystemType 2 -ChassisTypes @(10)) 'Laptop' 'Notebook'
Assert-Equal (Resolve-ErxckOSDeviceType -PCSystemType 0 -ChassisTypes @(10)) 'Laptop' 'Laptop sin bateria'
Assert-Equal (Resolve-ErxckOSDeviceType -PCSystemType 3 -ChassisTypes @(3) -BatteryCount 1) 'Desktop' 'Workstation con UPS'
Assert-Equal (Resolve-ErxckOSDeviceType -PCSystemType 0 -ChassisTypes @(21)) 'Unknown' 'Docking no es laptop'
Assert-Equal (Resolve-ErxckOSDeviceType -PCSystemType 0 -ChassisTypes @(1, 31)) 'Laptop' 'Todos los chasis'
Assert-Equal (Resolve-ErxckOSDeviceType -BatteryCount 1) 'Unknown' 'Bateria sola'
Assert-Equal (Resolve-ErxckOSDeviceType) 'Unknown' 'Sin datos'
Assert-Equal (Resolve-ErxckOSDeviceType -PCSystemType 3 -ChassisTypes @(7)) 'Desktop' 'Torre'
Assert-Equal (Resolve-ErxckOSDeviceType -ChassisTypes @(32)) 'Laptop' 'Desmontable'

function Get-CimInstance { throw 'CIM no disponible' }
Assert-Equal (Get-ErxckOSDeviceProfile).DeviceType 'Unknown' 'CIM inaccesible'
function Get-CimInstance {
    param($ClassName, $ErrorAction)
    switch ($ClassName) {
        'Win32_ComputerSystem' { [pscustomobject]@{ PCSystemType = 2 } }
        'Win32_SystemEnclosure' { throw 'Chasis no disponible' }
        'Win32_Battery' { throw 'Bateria no disponible' }
    }
}
Assert-Equal (Get-ErxckOSDeviceProfile).DeviceType 'Laptop' 'Consultas independientes'

# Simula solo la frontera nativa; ejecuta la logica real del perfil.
$script:current = '11111111-1111-1111-1111-111111111111'
$script:calls = [Collections.Generic.List[string]]::new()
$script:existing = [Collections.Generic.List[string]]::new()
$script:existing.Add($script:current)
$script:failSetting = $false
$script:failHighPerformance = $false
function powercfg.exe {
    $line = $args -join ' '
    $script:calls.Add($line)
    $global:LASTEXITCODE = 0
    switch ($args[0]) {
        '/getactivescheme' { "Power Scheme GUID: $script:current" }
        '/list' { $script:existing -join "`n" }
        '/duplicatescheme' {
            if ($script:failHighPerformance -and $args[1] -eq '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') { $global:LASTEXITCODE = 1; return }
            $script:existing.Add([string]$args[2])
        }
        '/setactive' { $script:current = [string]$args[1] }
        '/setacvalueindex' { if ($script:failSetting) { $global:LASTEXITCODE = 1 } }
    }
}
$laptop = Set-ErxckOSPowerProfile -Mode Laptop
Assert-Equal $laptop.DeviceType 'Laptop' 'Modo laptop manual'
Assert-Equal (@($script:calls | Where-Object { $_ -match '/setdc|/hibernate|/change |/x ' }).Count) 0 'No cambia bateria o hibernacion'
Assert-Equal (@($script:calls | Where-Object { $_ -eq '/duplicatescheme 11111111-1111-1111-1111-111111111111 689c9b24-7072-4aa4-9a9b-eef2a4432004' }).Count) 1 'Conserva el plan previo'
$before = @($script:calls | Where-Object { $_ -like '/duplicatescheme *' }).Count
$null = Set-ErxckOSPowerProfile -Mode Laptop
Assert-Equal (@($script:calls | Where-Object { $_ -like '/duplicatescheme *' }).Count) $before 'Repeticion sin duplicados'

function Get-ErxckOSDeviceProfile { [pscustomobject]@{ DeviceType = 'Unknown' } }
$before = $script:calls.Count
$unknown = Set-ErxckOSPowerProfile -Mode Auto
Assert-Equal $unknown.Changed $false 'Desconocido no cambia plan'
Assert-Equal $script:calls.Count $before 'Desconocido no ejecuta powercfg'

function Get-ErxckOSDeviceProfile { [pscustomobject]@{ DeviceType = 'Desktop' } }
$script:failHighPerformance = $true
$desktop = Set-ErxckOSPowerProfile -Mode Auto
Assert-Equal $desktop.DeviceType 'Desktop' 'Modo PC automatico'
Assert-Equal $desktop.Changed $true 'Fallback de esquema disponible'
Assert-Equal (@($script:calls | Where-Object { $_ -match '/setdc|/hibernate' }).Count) 0 'PC no cambia hibernacion global'

$previous = $script:current
$script:failSetting = $true
$thrown = $false
try { $null = Set-ErxckOSPowerProfile -Mode Laptop } catch { $thrown = $true }
Assert-Equal $thrown $true 'Error nativo llega al usuario'
Assert-Equal $script:current $previous 'Restaura plan activo al fallar'
Write-Output "$script:passed comprobaciones de perfiles aprobadas; no se modifico Windows."
