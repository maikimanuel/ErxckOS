[CmdletBinding()]
param(
 [string]$Repository='maikimanuel/ErxckOS',
 [string]$OutputDirectory='build/windows'
)
$ErrorActionPreference='Stop'
if ($Repository -notmatch '^[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+$') { throw 'Repositorio no valido.' }
$root=Split-Path $PSScriptRoot -Parent
$version=(Get-Content (Join-Path $root 'VERSION') -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'VERSION debe contener tres numeros.' }
$output=$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Path $output -Force | Out-Null
$metadataPath=Join-Path $output 'ErxckOS-Setup.json'
Remove-Item $metadataPath -ErrorAction SilentlyContinue
$stage=Join-Path ([IO.Path]::GetTempPath()) ('ErxckOS-build-'+[guid]::NewGuid().ToString('N'))
$app=Join-Path $stage 'app'
New-Item -ItemType Directory -Path $app -Force | Out-Null
try {
Copy-Item (Join-Path $root 'app/*') $app -Recurse -Force
New-Item -ItemType Directory -Path (Join-Path $app 'licenses') -Force | Out-Null
Copy-Item (Join-Path $root 'licenses/*') (Join-Path $app 'licenses') -Recurse -Force
@{repository=$Repository;version=$version} | ConvertTo-Json | Set-Content (Join-Path $app 'update-config.json') -Encoding UTF8
Remove-Item (Join-Path $app 'Start-ErxckOS.cmd') -ErrorAction SilentlyContinue
$compiler=Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
if (-not (Test-Path $compiler)) { throw 'Falta el compilador .NET Framework de Windows.' }
$info=Join-Path $stage 'VersionInfo.cs'
@"
using System.Reflection;
[assembly: AssemblyTitle("ErxckOS Tool")]
[assembly: AssemblyCompany("ErxckOS")]
[assembly: AssemblyProduct("ErxckOS Tool")]
[assembly: AssemblyVersion("$version.0")]
[assembly: AssemblyFileVersion("$version.0")]
"@ | Set-Content $info -Encoding UTF8
& $compiler /nologo /target:winexe /platform:x64 /reference:System.Windows.Forms.dll "/win32icon:$(Join-Path $app 'Assets/ErxckOS.ico')" "/win32manifest:$(Join-Path $root 'installer/ErxckOS.manifest')" "/out:$(Join-Path $app 'ErxckOS.exe')" (Join-Path $root 'installer/ErxckOS.cs') $info
if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar ErxckOS.exe.' }
$iscc=Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6/ISCC.exe'
if (-not (Test-Path $iscc)) { throw 'Instala Inno Setup 6 desde jrsoftware.org antes de compilar.' }
& $iscc "/DAppSource=$app" "/DAppVersion=$version" "/DOutputFolder=$output" (Join-Path $root 'installer/ErxckOS.iss')
if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar ErxckOS-Setup.exe.' }
$setup=Join-Path $output 'ErxckOS-Setup.exe'
@{version=$version;repository=$Repository;sha256=(Get-FileHash $setup -Algorithm SHA256).Hash.ToLowerInvariant()} | ConvertTo-Json | Set-Content $metadataPath -Encoding UTF8
Write-Output $setup
} finally {
 Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
}
