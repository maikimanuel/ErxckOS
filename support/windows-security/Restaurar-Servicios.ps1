[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ReportDir)
$ErrorActionPreference='Stop'
# Fixed repair scope: two Start DWORDs. No ACL, ownership, antivirus, or task changes.
$targets=@(@{Name='SecurityHealthService';Value=3},@{Name='wscsvc';Value=2})
$results=@()
foreach ($target in $targets) {
 $name=$target.Name
 $item=[ordered]@{Servicio=$name;Antes=$null;Despues=$null;Correcto=$false;Error=''}
 try {
  $path='HKLM:\SYSTEM\CurrentControlSet\Services\'+$name
  if (-not (Test-Path $path)) { throw "No existe el servicio $name; no se creo una clave nueva." }
  $item.Antes=(Get-ItemProperty -LiteralPath $path -Name Start).Start
  $backup=Join-Path $ReportDir ($name+'-antes.reg')
  & reg.exe export ('HKLM\SYSTEM\CurrentControlSet\Services\'+$name) $backup /y | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'No se pudo guardar el estado anterior; no se modifico este servicio.' }
  New-ItemProperty -LiteralPath $path -Name Start -PropertyType DWord -Value $target.Value -Force | Out-Null
  $item.Despues=(Get-ItemProperty -LiteralPath $path -Name Start).Start
  if ($item.Despues -ne $target.Value) { throw 'El valor de inicio no quedo restaurado.' }
  $item.Correcto=$true
 } catch { $item.Error=$_.Exception.Message }
 $results+=[pscustomobject]$item
}
$results | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $ReportDir 'cambios.json') -Encoding UTF8
if (@($results | Where-Object { -not $_.Correcto }).Count -gt 0) { exit 1 }
exit 0
