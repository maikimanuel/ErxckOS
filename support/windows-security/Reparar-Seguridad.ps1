[CmdletBinding()]
param([switch]$SoloDiagnostico)
$ErrorActionPreference='Stop'
$psExe=Join-Path ([Environment]::SystemDirectory) 'WindowsPowerShell\v1.0\powershell.exe'
$admin=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
 $arguments='-NoProfile -ExecutionPolicy Bypass -File "'+$PSCommandPath+'"'
 if ($SoloDiagnostico) { $arguments+=' -SoloDiagnostico' }
 $child=Start-Process $psExe -Verb RunAs -ArgumentList $arguments -Wait -PassThru
 exit $child.ExitCode
}
$reports=Join-Path $PSScriptRoot ('Resultados\'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $reports -Force | Out-Null
function Save-Diagnostics([string]$Name) {
 $file=Join-Path $reports $Name
 '=== Servicios y valores de inicio ===' | Out-File $file -Encoding UTF8
 foreach ($name in @('SecurityHealthService','wscsvc','WinDefend')) {
  try {
   $service=Get-Service $name
   $start=(Get-ItemProperty ('HKLM:\SYSTEM\CurrentControlSet\Services\'+$name) -Name Start).Start
   [pscustomobject]@{Servicio=$name;Estado=$service.Status;Inicio=$service.StartType;StartRegistro=$start} | Format-List | Out-String | Add-Content $file
  } catch { $_.Exception.Message | Add-Content $file }
 }
 '=== Directivas de la interfaz (solo lectura) ===' | Add-Content $file
 try { & reg.exe query 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center' /s 2>&1 | Out-String | Add-Content $file }
 catch { $_.Exception.Message | Add-Content $file }
 '=== Motor Defender (solo lectura) ===' | Add-Content $file
 try { Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled,IsTamperProtected | Format-List | Out-String | Add-Content $file }
 catch { $_.Exception.Message | Add-Content $file }
}
try {
 Save-Diagnostics 'antes.txt'
 if ($SoloDiagnostico) { Write-Host "Diagnostico guardado en: $reports"; exit 0 }
 $helper=Join-Path $PSScriptRoot 'ErxckOS.Elevate.exe'
 if (-not (Test-Path $helper)) { $helper=Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'app\Scripts\ErxckOS.Elevate.exe' }
 if (-not (Test-Path $helper)) { throw 'Falta ErxckOS.Elevate.exe. Extrae TODO el ZIP antes de ejecutar.' }
 $expected='5809182E27BC4145E890A6DBD998A29A24F3B8E161BF7D35CAC23160101D81E6'
 if ((Get-FileHash $helper -Algorithm SHA256).Hash -ne $expected) { throw 'El auxiliar no coincide con el archivo esperado; no se ejecuto.' }
 $worker=Join-Path $PSScriptRoot 'Restaurar-Servicios.ps1'
 $arguments='--NoLogo --TrustedInstaller --Privileged "'+$psExe+'" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "'+$worker+'" -ReportDir "'+$reports+'"'
 Start-Process $helper -ArgumentList $arguments -Wait | Out-Null
 $resultPath=Join-Path $reports 'cambios.json'
 if (-not (Test-Path $resultPath)) { throw 'El auxiliar no devolvio un resultado. No se puede confirmar la reparacion.' }
 $results=@(Get-Content $resultPath -Raw | ConvertFrom-Json)
 Save-Diagnostics 'despues.txt'
 $results | Format-Table Servicio,Antes,Despues,Correcto,Error -AutoSize | Out-Host
 if ($results.Count -ne 2 -or @($results | Where-Object { -not $_.Correcto }).Count -gt 0) { throw 'No se pudieron restaurar ambos servicios. Envia la carpeta Resultados; no cambies permisos manualmente.' }
 Write-Host 'Valores de inicio restaurados. Reinicia manualmente y abre Seguridad de Windows.' -ForegroundColor Green
 Write-Host 'Esto no confirma todavia que la pagina funcione despues del reinicio.'
 Write-Host "Registros: $reports"
 exit 0
} catch {
 $_.Exception.Message | Tee-Object -FilePath (Join-Path $reports 'error.txt') | Out-Host
 Write-Host "Registros: $reports" -ForegroundColor Yellow
 exit 1
}
