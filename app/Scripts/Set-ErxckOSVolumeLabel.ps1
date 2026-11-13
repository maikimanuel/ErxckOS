[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
if ($env:SystemDrive -notmatch '^[A-Za-z]:$') {
    throw 'No se pudo identificar la unidad de Windows.'
}

$driveLetter = [char]($env:SystemDrive[0])
$volume = Get-Volume -DriveLetter $driveLetter
if ($volume.FileSystemLabel -cne 'ErxckOS') {
    Set-Volume -DriveLetter $driveLetter -NewFileSystemLabel 'ErxckOS'
    if ((Get-Volume -DriveLetter $driveLetter).FileSystemLabel -cne 'ErxckOS') {
        throw 'No se pudo confirmar el nombre de la unidad de Windows.'
    }
}

Write-Output "Unidad de Windows ($($env:SystemDrive)): ErxckOS."
