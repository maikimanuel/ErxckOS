[CmdletBinding()]
param(
 [Parameter(Mandatory=$true)]
 [ValidateSet('SecurityOff','SecurityOn','SysMainOff','SysMainOn','MemoryOff','MemoryOn','MpoOff','MpoOn','BackgroundOff','BackgroundOn','DvrOff','DvrOn','PowerThrottleOff','PowerThrottleOn','DriversOff','DriversOn','Balanced','Performance','Ultra','AutoPower','LaptopPower','DesktopPower','Chrome','Firefox','Brave','Chromium','Branding')]
 [string]$Action,
 [string]$ResultPath
)
$ErrorActionPreference = 'Stop'
function Set-Dword([string]$Path,[string]$Name,[int]$Value) {
 New-Item -Path $Path -Force | Out-Null
 New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
 if ((Get-ItemPropertyValue -Path $Path -Name $Name) -ne $Value) { throw "No se pudo verificar $Name" }
}
function Native([string]$File,[string[]]$Arguments) {
 & $File @Arguments | Out-String | Write-Output
 if ($LASTEXITCODE -ne 0) { throw "La operacion fallo. Codigo: $LASTEXITCODE" }
}
function Legacy([string]$Script) {
 $helper = Join-Path $PSScriptRoot 'ErxckOS.Elevate.exe'
 $file = Join-Path $PSScriptRoot $Script
 $proc = Start-Process $helper -ArgumentList @('--NoLogo','--TrustedInstaller',('"{0}"' -f $env:ComSpec),'/d','/c',('""{0}""' -f $file)) -Wait -PassThru
 if ($proc.ExitCode -ne 0) { throw "La operacion fallo. Codigo: $($proc.ExitCode)" }
}
try {
 $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
 if (-not $isAdmin) { throw 'Abre ErxckOS Tool como administrador.' }
 $actionMessage = 'Configuracion aplicada. Algunos cambios requieren reiniciar.'
 switch ($Action) {
  { $_ -in @('AutoPower','LaptopPower','DesktopPower') } {
   . (Join-Path $PSScriptRoot 'ErxckOS.Power.ps1')
   $mode = @{ AutoPower = 'Auto'; LaptopPower = 'Laptop'; DesktopPower = 'Desktop' }[$Action]
   $profile = Set-ErxckOSPowerProfile -Mode $mode
   $actionMessage = $profile.Message
  }
  'SecurityOff' { Legacy 'ErxckOS.Security.Disable.cmd'; if ((Get-ItemPropertyValue 'HKLM:\SYSTEM\ControlSet001\Services\WinDefend' Start) -ne 4) { throw 'La proteccion impidio el cambio de servicio.' } }
  'SecurityOn' { Legacy 'ErxckOS.Security.Enable.cmd'; if ((Get-ItemPropertyValue 'HKLM:\SYSTEM\ControlSet001\Services\WinDefend' Start) -eq 4) { throw 'No se restauro el inicio del servicio.' } }
  'SysMainOff' { Legacy 'ErxckOS.SysMain.Disable.cmd'; if ((Get-ItemPropertyValue 'HKLM:\SYSTEM\ControlSet001\Services\SysMain' Start) -ne 4) { throw 'No se verifico el cambio de SysMain.' } }
  'SysMainOn' { Legacy 'ErxckOS.SysMain.Enable.cmd'; if ((Get-ItemPropertyValue 'HKLM:\SYSTEM\ControlSet001\Services\SysMain' Start) -ne 2) { throw 'No se verifico el cambio de SysMain.' } }
  'MemoryOff' { Disable-MMAgent -MemoryCompression; if ((Get-MMAgent).MemoryCompression) { throw 'No se desactivo la compresion.' } }
  'MemoryOn' { Enable-MMAgent -MemoryCompression; if (-not (Get-MMAgent).MemoryCompression) { throw 'No se activo la compresion.' } }
  'MpoOff' { Set-Dword 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' 'OverlayTestMode' 5 }
  'MpoOn' { Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' 'OverlayTestMode' -ErrorAction SilentlyContinue }
  'BackgroundOff' { Set-Dword 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1 }
  'BackgroundOn' { Set-Dword 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 0 }
  'DvrOff' { Set-Dword 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0; Set-Dword 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0 }
  'DvrOn' { Set-Dword 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 1; Set-Dword 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 1 }
  'PowerThrottleOff' { Set-Dword 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' 'PowerThrottlingOff' 1 }
  'PowerThrottleOn' { Set-Dword 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' 'PowerThrottlingOff' 0 }
  'DriversOff' { Set-Dword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' 1 }
  'DriversOn' { Set-Dword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' 0 }
  { $_ -in @('Balanced','Performance','Ultra') } {
   $plans = @{
    Balanced = @('381b4222-f694-41f0-9685-ff5bb260df2e','689c9b24-7072-4aa4-9a9b-eef2a4432001','ErxckOS - Equilibrado')
    Performance = @('8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c','689c9b24-7072-4aa4-9a9b-eef2a4432002','ErxckOS - Rendimiento')
    Ultra = @('e9a42b02-d5df-448d-aa00-03f14749eb61','3ff9831b-6f80-4830-8178-736cd4229e7b','ErxckOS - Ultra Performance')
   }
   $p=$plans[$Action]
   $existing=(& powercfg.exe /list | Out-String)
   if ($existing -notmatch $p[1]) { Native 'powercfg.exe' @('/duplicatescheme',$p[0],$p[1]) }
   Native 'powercfg.exe' @('/changename',$p[1],$p[2])
   Native 'powercfg.exe' @('/setactive',$p[1])
   if ($Action -eq 'Ultra') {
    foreach ($pair in @(@('PERFINCPOL','2'),@('PERFDECPOL','1'),@('PERFINCTHRESHOLD','10'),@('PERFDECTHRESHOLD','8'))) {
     Native 'powercfg.exe' @('/setacvalueindex','scheme_current','sub_processor',$pair[0],$pair[1])
    }
    Native 'powercfg.exe' @('/setactive',$p[1])
   }
   if ((& powercfg.exe /getactivescheme | Out-String) -notmatch $p[1]) { throw 'El plan no quedo activo.' }
  }
  { $_ -in @('Chrome','Firefox','Brave','Chromium') } {
   $ids=@{Chrome='Google.Chrome';Firefox='Mozilla.Firefox';Brave='Brave.Brave';Chromium='Hibbiki.Chromium'}
   $winget=Get-Command winget.exe -ErrorAction SilentlyContinue
   if (-not $winget) { throw 'Se necesita App Installer (winget) para instalar navegadores.' }
   Native $winget.Source @('install','--id',$ids[$Action],'--exact','--source','winget','--accept-package-agreements','--accept-source-agreements','--disable-interactivity')
  }
  'Branding' {
   & (Join-Path $PSScriptRoot 'Set-ErxckOSIdentity.ps1')
   & (Join-Path $PSScriptRoot 'Set-ErxckOSVolumeLabel.ps1')
   $actionMessage = 'Identidad aplicada. La unidad de Windows se llama ErxckOS.'
  }
 }
 $result=@{ok=$true;message=$actionMessage;action=$Action}
 $exitCode=0
} catch {
 $result=@{ok=$false;message=$_.Exception.Message;action=$Action};$exitCode=1
}
$json=$result | ConvertTo-Json -Compress
if ($ResultPath) { [IO.File]::WriteAllText($ResultPath,$json,[Text.UTF8Encoding]::new($false)) }
Write-Output $json
exit $exitCode
