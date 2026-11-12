$ErrorActionPreference='Stop'
$appRoot=Split-Path $PSScriptRoot -Parent
$shell=New-Object -ComObject WScript.Shell
foreach ($folder in @([Environment]::GetFolderPath('Desktop'),[Environment]::GetFolderPath('Programs'))) {
 if ([string]::IsNullOrWhiteSpace($folder)) { continue }
 $path=Join-Path $folder 'ErxckOS Tool.lnk'
 # Inno creates shared shortcuts. Retire older per-user links which shadow them.
 if (-not (Test-Path $path)) { continue }
 $shortcut=$shell.CreateShortcut($path)
 if ($shortcut.TargetPath -eq (Join-Path $appRoot 'ErxckOS.exe') -or $shortcut.Arguments.Contains((Join-Path $appRoot 'ErxckOS.ps1'))) {
  Remove-Item $path -Force
 }
}
