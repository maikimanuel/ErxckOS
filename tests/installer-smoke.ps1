[CmdletBinding()]
param([string]$Installer='build/windows/ErxckOS-Setup.exe',[string]$Repository='maikimanuel/ErxckOS')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$installerPath=(Resolve-Path $Installer).Path
$install=Join-Path $env:TEMP ('ErxckOS prueba con espacios '+[guid]::NewGuid().ToString('N'))
$uninstall=Join-Path $install 'unins000.exe'
$key='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A50F47EF-91BC-4A82-9C46-4010CE60C7CC}_is1'
Add-Type @'
using System.Runtime.InteropServices;
using System.Text;
public static class InstallerSmokePaths {
 [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
 public static extern uint GetLongPathName(string path, StringBuilder result, uint capacity);
}
'@
function Get-LongPath([string]$Path) {
 $buffer=New-Object Text.StringBuilder 32768
 $length=[InstallerSmokePaths]::GetLongPathName($Path,$buffer,32768)
 if ($length -eq 0 -or $length -ge 32768) { throw "No se pudo normalizar la ruta: $Path" }
 return $buffer.ToString()
}
function Run-Checked([string]$File,[string]$Arguments,[int]$Expected=0) {
 $process=Start-Process -FilePath $File -ArgumentList $Arguments -Wait -PassThru
 if ($process.ExitCode -ne $Expected) { throw "Codigo inesperado $($process.ExitCode) al ejecutar $File; se esperaba $Expected." }
}
try {
 # Installing the tool writes application files and shortcuts; it never applies tweaks.
 foreach ($attempt in 1..2) {
  Run-Checked $installerPath ('/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR="'+$install+'"')
 }
 # TEMP may use RUNNER~1 while Windows shortcuts expand it to runneradmin.
 # Compare canonical long paths to avoid treating those aliases as different files.
 $install=Get-LongPath $install
 $exe=Join-Path $install 'ErxckOS.exe'
 $version=(Get-Content (Join-Path $root 'VERSION') -Raw).Trim()
 if ((Get-Item $exe).VersionInfo.FileVersion -ne "$version.0") { throw 'Version del EXE incorrecta.' }
 $config=Get-Content (Join-Path $install 'update-config.json') -Raw | ConvertFrom-Json
 if ($config.version -ne $version -or $config.repository -ne $Repository) { throw 'Configuracion de actualizaciones incorrecta.' }
 foreach ($source in Get-ChildItem (Join-Path $root 'app') -File -Recurse) {
  $relative=$source.FullName.Substring((Join-Path $root 'app').Length+1)
  if ($relative -in @('Start-ErxckOS.cmd','update-config.json')) { continue }
  $target=Join-Path $install $relative
  if (-not (Test-Path $target)) { throw "Falta $relative." }
  if ((Get-FileHash $source.FullName).Hash -ne (Get-FileHash $target).Hash) { throw "Contenido distinto en $relative." }
 }
 foreach ($name in @('GPL-3.0.txt','Elevacion-LICENSE.txt','THIRD-PARTY-NOTICES.txt')) {
  if (-not (Test-Path (Join-Path $install "licenses/$name"))) { throw "Falta licencia $name." }
 }
 $shell=New-Object -ComObject WScript.Shell
 foreach ($folder in @([Environment]::GetFolderPath('CommonDesktopDirectory'),[Environment]::GetFolderPath('CommonPrograms'))) {
  $path=Join-Path $folder 'ErxckOS Tool.lnk'
  if (-not (Test-Path $path)) { throw "Falta acceso directo $path." }
  $actualTarget=$shell.CreateShortcut($path).TargetPath
  Write-Output "Acceso: $path; destino: $actualTarget; esperado: $exe"
  if ($actualTarget -ne $exe) { throw "El acceso directo no apunta al EXE. Actual: $actualTarget. Esperado: $exe." }
 }
 # Reproduce a legacy per-user shortcut, then exercise the AME migration helper.
 $legacy=Join-Path ([Environment]::GetFolderPath('Programs')) 'ErxckOS Tool.lnk'
 $link=$shell.CreateShortcut($legacy)
 $link.TargetPath="$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
 $link.Arguments='-File "'+(Join-Path $install 'ErxckOS.ps1')+'"'
 $link.Save()
 & (Join-Path $install 'Scripts/Install-ErxckOSShortcut.ps1')
 if (Test-Path $legacy) { throw 'El acceso directo anterior sigue ocultando al nuevo.' }
 $entry=Get-ItemProperty $key
 if ($entry.DisplayVersion -ne $version) { throw 'No se registro correctamente la desinstalacion.' }
 Run-Checked $exe '--self-test'
 $module=Join-Path $install 'Scripts/ErxckOS.Power.ps1'
 Move-Item $module ($module+'.missing')
 try { Run-Checked $exe '--self-test' 2 }
 finally { Move-Item ($module+'.missing') $module }
 Run-Checked $exe '--unknown-option' 64
 Write-Output 'Instalacion, reinstalacion, recursos, accesos al EXE y diagnostico aprobados. No se aplicaron tweaks.'
} finally {
 if (Test-Path $uninstall) { Run-Checked $uninstall '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART' }
}
if (Test-Path (Join-Path $install 'ErxckOS.exe')) { throw 'La desinstalacion dejo el EXE instalado.' }
if (Test-Path $key) { throw 'La desinstalacion dejo la entrada de aplicaciones.' }
Write-Output 'Desinstalacion aprobada.'
