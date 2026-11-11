# Shared by the application and playbook. Compatible with Windows PowerShell 5.1.
function Resolve-ErxckOSDeviceType {
    param([int]$PCSystemType = 0, [int[]]$ChassisTypes = @(), [int]$BatteryCount = 0)
    # A UPS, docking station or desktop marketing name is not a portable chassis.
    $portable = @(8, 9, 10, 11, 14, 30, 31, 32)
    $desktop = @(3, 4, 5, 6, 7, 13, 15, 16, 23, 24)
    if ($PCSystemType -eq 2 -or @($ChassisTypes | Where-Object { $portable -contains $_ }).Count -gt 0) {
        return 'Laptop'
    }
    if ($PCSystemType -eq 1 -or $PCSystemType -eq 3 -or @($ChassisTypes | Where-Object { $desktop -contains $_ }).Count -gt 0) {
        return 'Desktop'
    }
    return 'Unknown'
}

function Get-ErxckOSDeviceProfile {
    $pcType = 0; $chassis = @(); $batteries = 0
    try { $pcType = [int](Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop | Select-Object -First 1).PCSystemType } catch {}
    try { $chassis = @(Get-CimInstance -ClassName Win32_SystemEnclosure -ErrorAction Stop | ForEach-Object { $_.ChassisTypes } | Where-Object { $_ }) } catch {}
    try { $batteries = @(Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop).Count } catch {}
    [pscustomobject]@{
        DeviceType = Resolve-ErxckOSDeviceType -PCSystemType $pcType -ChassisTypes $chassis -BatteryCount $batteries
        PCSystemType = $pcType
        ChassisTypes = $chassis
        BatteryCount = $batteries
    }
}

function Invoke-ErxckOSPowercfg {
    param([string[]]$Arguments)
    $output = & powercfg.exe @Arguments 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { throw "powercfg $($Arguments -join ' ') fallo (codigo $LASTEXITCODE): $output" }
    return $output
}

function Get-ErxckOSActiveScheme {
    $output = Invoke-ErxckOSPowercfg -Arguments @('/getactivescheme')
    $match = [regex]::Match($output, '[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}')
    if (-not $match.Success) { throw 'No se pudo identificar el plan de energia activo.' }
    return $match.Value
}

function Set-ErxckOSPowerProfile {
    [CmdletBinding()]
    param([ValidateSet('Auto', 'Laptop', 'Desktop')][string]$Mode = 'Auto')
    $type = $Mode
    if ($Mode -eq 'Auto') { $type = (Get-ErxckOSDeviceProfile).DeviceType }
    if ($type -eq 'Unknown') {
        return [pscustomobject]@{ Changed = $false; DeviceType = $type; Message = 'No se pudo identificar laptop/PC. Se conserva el plan actual; puedes elegir el perfil manualmente.' }
    }
    $previous = Get-ErxckOSActiveScheme
    $guid = '689c9b24-7072-4aa4-9a9b-eef2a4432002'
    $name = 'ErxckOS - Rendimiento PC'
    if ($type -eq 'Laptop') { $guid = '689c9b24-7072-4aa4-9a9b-eef2a4432004'; $name = 'ErxckOS - Laptop' }
    $plans = Invoke-ErxckOSPowercfg -Arguments @('/list')
    try {
        if ($plans -notmatch [regex]::Escape($guid)) {
            if ($type -eq 'Laptop') {
                # Copy the user's actual DC, lid and critical-battery policies.
                $null = Invoke-ErxckOSPowercfg -Arguments @('/duplicatescheme', $previous, $guid)
            } else {
                try { $null = Invoke-ErxckOSPowercfg -Arguments @('/duplicatescheme', '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c', $guid) }
                catch { $null = Invoke-ErxckOSPowercfg -Arguments @('/duplicatescheme', $previous, $guid) }
            }
        }
        $null = Invoke-ErxckOSPowercfg -Arguments @('/changename', $guid, $name)
        # AC only. Never write DC timeouts or disable hibernation/drivers globally.
        $null = Invoke-ErxckOSPowercfg -Arguments @('/setacvalueindex', $guid, 'SUB_PROCESSOR', 'PROCTHROTTLEMIN', '5')
        $null = Invoke-ErxckOSPowercfg -Arguments @('/setacvalueindex', $guid, 'SUB_PROCESSOR', 'PROCTHROTTLEMAX', '100')
        $null = Invoke-ErxckOSPowercfg -Arguments @('/setactive', $guid)
        if ((Get-ErxckOSActiveScheme) -ne $guid) { throw 'El perfil no quedo activo.' }
    } catch {
        $failure = $_
        try { $null = Invoke-ErxckOSPowercfg -Arguments @('/setactive', $previous) } catch {}
        throw $failure
    }
    $message = 'Perfil PC aplicado. No se cambiaron los servicios ACPI ni la hibernacion.'
    if ($type -eq 'Laptop') { $message = 'Perfil laptop aplicado. Se ajusto el procesador en corriente; se conservaron los valores de bateria, tapa e hibernacion del plan copiado.' }
    return [pscustomobject]@{ Changed = $true; DeviceType = $type; Scheme = $guid; Message = $message }
}
