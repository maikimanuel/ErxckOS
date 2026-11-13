$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'app/Scripts/Set-ErxckOSVolumeLabel.ps1'
$originalDrive = $env:SystemDrive
$state = @{ Labels = @{ C = 'Datos'; D = 'Windows' }; Changes = 0 }

${function:Get-Volume} = {
    param([char]$DriveLetter)
    [pscustomobject]@{ FileSystemLabel = $state.Labels[[string]$DriveLetter] }
}.GetNewClosure()

${function:Set-Volume} = {
    param([char]$DriveLetter, [string]$NewFileSystemLabel)
    $state.Labels[[string]$DriveLetter] = $NewFileSystemLabel
    $state.Changes++
}.GetNewClosure()

try {
    $env:SystemDrive = 'D:'
    & $scriptPath | Out-Null
    if ($state.Labels.D -cne 'ErxckOS' -or $state.Labels.C -cne 'Datos' -or $state.Changes -ne 1) {
        throw 'Debe cambiar solamente la etiqueta de la unidad de Windows.'
    }
    & $scriptPath | Out-Null
    if ($state.Changes -ne 1) { throw 'La etiqueta correcta no se debe escribir de nuevo.' }
} finally {
    $env:SystemDrive = $originalDrive
}
Write-Output 'Etiqueta de la unidad de Windows verificada con comandos simulados.'
