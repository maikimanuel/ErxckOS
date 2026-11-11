$ErrorActionPreference='Stop'
$appRoot=Split-Path $PSScriptRoot -Parent
$shell=New-Object -ComObject WScript.Shell
foreach ($folder in @([Environment]::GetFolderPath('Desktop'),[Environment]::GetFolderPath('Programs'))) {
 if ([string]::IsNullOrWhiteSpace($folder)) { continue }
 $shortcut=$shell.CreateShortcut((Join-Path $folder 'ErxckOS Tool.lnk'))
 $shortcut.TargetPath="$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
 $shortcut.Arguments='-NoProfile -ExecutionPolicy Bypass -STA -File "'+(Join-Path $appRoot 'ErxckOS.ps1')+'"'
 $shortcut.WorkingDirectory=$appRoot
 $shortcut.IconLocation=(Join-Path $appRoot 'Assets/ErxckOS.ico')+',0'
 $shortcut.Save()
}
