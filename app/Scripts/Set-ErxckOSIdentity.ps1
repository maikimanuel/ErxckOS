[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$account = Get-LocalUser -SID $identity.User -ErrorAction SilentlyContinue
if ($null -eq $account -or $account.PrincipalSource -ne 'Local') {
    Write-Output 'Cuenta Microsoft o de dominio: no se modifica el nombre de inicio de sesion.'
} else {
    $conflict = Get-LocalUser -Name 'ErxckOS' -ErrorAction SilentlyContinue
    if ($null -ne $conflict -and $conflict.SID -ne $account.SID) {
        throw 'Ya existe otra cuenta ErxckOS. No se renombro ninguna cuenta.'
    }
    if ($account.Name -ne 'ErxckOS') { Rename-LocalUser -SID $account.SID -NewName 'ErxckOS' }
    Set-LocalUser -SID $account.SID -FullName 'ErxckOS'
    Write-Output 'Cuenta local: ErxckOS. La carpeta del perfil y la contrasena se conservan.'
}
$nt = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
Set-ItemProperty $nt RegisteredOwner 'ErxckOS'
Set-ItemProperty $nt RegisteredOrganization 'ErxckOS'
foreach ($name in @('EditionSubManufacturer','EditionSubstring','EditionSubVersion')) {
    New-ItemProperty $nt -Name $name -PropertyType String -Value 'ErxckOS' -Force | Out-Null
}
$oem = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'
New-Item $oem -Force | Out-Null
foreach ($name in @('Manufacturer','Model','SupportProvider')) {
    New-ItemProperty $oem -Name $name -Value 'ErxckOS' -PropertyType String -Force | Out-Null
}
Write-Output 'Identificacion de ErxckOS aplicada. Cierra sesion para actualizar el nombre visible.'
