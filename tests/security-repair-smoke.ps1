$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repair=Join-Path $root 'support/windows-security/Reparar-Seguridad.ps1'
function Read-Starts {
 $values=@{}
 foreach ($name in @('SecurityHealthService','wscsvc','WinDefend')) {
  $item=Get-ItemProperty ('HKLM:\SYSTEM\CurrentControlSet\Services\'+$name) -Name Start -ErrorAction SilentlyContinue
  $values[$name]=$item.Start
 }
 return $values
}
$before=Read-Starts
$psExe=Join-Path ([Environment]::SystemDirectory) 'WindowsPowerShell\v1.0\powershell.exe'
$process=Start-Process $psExe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "'+$repair+'" -SoloDiagnostico') -Wait -PassThru
if ($process.ExitCode -ne 0) { throw 'El diagnostico no termino correctamente.' }
$reports=Join-Path (Split-Path $repair -Parent) 'Resultados'
$latest=Get-ChildItem $reports -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $latest -or -not (Test-Path (Join-Path $latest.FullName 'antes.txt'))) { throw 'No se guardo el diagnostico.' }
$after=Read-Starts
foreach ($name in $before.Keys) { if ($before[$name] -ne $after[$name]) { throw "El diagnostico modifico $name." } }
# Verify the bundled elevation path using only a temporary identity-report script.
# Never run the real repair worker on the CI host.
$temp=Join-Path $env:TEMP ('ErxckOS-elevation-probe-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
 $probe=Join-Path $temp 'probe.ps1';$result=Join-Path $temp 'identity.txt'
 @'
param([string]$ResultPath)
$sid=([Security.Principal.NTAccount]::new('NT SERVICE\TrustedInstaller')).Translate([Security.Principal.SecurityIdentifier])
$principal=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
[IO.File]::WriteAllText($ResultPath,$principal.IsInRole($sid).ToString())
'@ | Set-Content $probe -Encoding UTF8
 $helper=Join-Path $root 'app/Scripts/ErxckOS.Elevate.exe'
 $arguments='--NoLogo --TrustedInstaller --Privileged "'+$psExe+'" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "'+$probe+'" -ResultPath "'+$result+'"'
 Start-Process $helper -ArgumentList $arguments -Wait | Out-Null
 if (-not (Test-Path $result) -or (Get-Content $result -Raw) -ne 'True') { throw 'No se verifico el token TrustedInstaller del auxiliar.' }
} finally { Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue }
Write-Output 'Diagnostico sin modificaciones y lanzamiento del auxiliar comprobados. Reparacion de servicios reales no ejecutada en CI.'
