$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'app/Scripts/Set-ErxckOSVolumeLabel.ps1'
$originalDrive = $env:SystemDrive
$script:labels = @{ C = 'Datos'; D = 'Windows' }
$script:changes = 0

function Get-Volume([char]$DriveLetter) {
    [pscustomobject]@{ FileSystemLabel = $script:labels[[string]$DriveLetter] }
}

function Set-Volume([char]$DriveLetter, [string]$NewFileSystemLabel) {
    $script:labels[[string]$DriveLetter] = $NewFileSystemLabel
    $script:changes++
}

try {
    $env:SystemDrive = 'D:'
    & $scriptPath | Out-Null
    if ($script:labels.D -cne 'ErxckOS' -or $script:labels.C -cne 'Datos' -or $script:changes -ne 1) {
        throw 'Debe cambiar solamente la etiqueta de la unidad de Windows.'
    }
    & $scriptPath | Out-Null
    if ($script:changes -ne 1) { throw 'La etiqueta correcta no se debe escribir de nuevo.' }
} finally {
    $env:SystemDrive = $originalDrive
}
Write-Output 'Etiqueta de la unidad de Windows verificada con comandos simulados.'
