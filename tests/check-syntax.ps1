$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$failed = $false
$count = 0
Get-ChildItem (Join-Path $root 'app'),(Join-Path $root 'tests') -Recurse -Filter *.ps1 | ForEach-Object {
    $tokens = $null; $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$errors)
    $count++
    if ($errors.Count) { $errors | ForEach-Object { Write-Host $_ }; $failed = $true }
}
if ($failed) { throw 'Se encontraron errores de sintaxis PowerShell.' }
Write-Output "$count scripts PowerShell sin errores de sintaxis."
