[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$admin=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
 try { Start-Process "$PSHOME\powershell.exe" -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-STA','-File',('"{0}"' -f $PSCommandPath)) }
 catch { Write-Error 'Se necesitan permisos de administrador para abrir ErxckOS Tool.' }
 exit
}
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
[xml]$xaml=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="ErxckOS Tool" Width="1160" Height="780" MinWidth="960" MinHeight="680" WindowStartupLocation="CenterScreen" Background="#0B0B10" Foreground="#F5F1F3" FontFamily="Segoe UI">
 <Window.Resources>
  <Style TargetType="Button"><Setter Property="Background" Value="#84283F"/><Setter Property="Foreground" Value="White"/><Setter Property="BorderThickness" Value="0"/><Setter Property="Padding" Value="18,11"/><Setter Property="Margin" Value="0,0,10,0"/><Setter Property="Cursor" Value="Hand"/><Setter Property="FontSize" Value="13"/><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="9" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Background" Value="#A13B55"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter TargetName="b" Property="Opacity" Value="0.45"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
 </Window.Resources>
 <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="222"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
  <Border Grid.Column="0" Background="#121116" BorderBrush="#242129" BorderThickness="0,0,1,0">
   <Grid Margin="23,24"><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
    <StackPanel><Image x:Name="Logo" Height="92" Stretch="Uniform" Margin="0,0,0,10"/><TextBlock Text="ErxckOS" FontSize="27" FontWeight="Bold" HorizontalAlignment="Center"/><TextBlock x:Name="VersionLabel" Text="UTILITY / 0.4.1" Foreground="#A68A94" FontSize="10" HorizontalAlignment="Center" Margin="0,7,0,36"/></StackPanel>
    <StackPanel Grid.Row="1"><Button x:Name="ToolsNav" Content="Tools" HorizontalContentAlignment="Left" Margin="0,0,0,10"/><Button x:Name="TweaksNav" Content="Tweaking" Background="#242029" HorizontalContentAlignment="Left" Margin="0"/></StackPanel>
    <StackPanel Grid.Row="3"><TextBlock Text="Tu sistema. Tu estilo." Foreground="#B59DA6" FontSize="12"/><TextBlock Text="ErxckOS Tool" Foreground="#6E5D65" FontSize="11" Margin="0,5,0,0"/></StackPanel>
   </Grid>
  </Border>
  <Grid Grid.Column="1" Margin="30,24,30,20"><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
   <Border CornerRadius="16" Height="166" Margin="0,0,0,25" ClipToBounds="True"><Grid><Image x:Name="Wallpaper" Stretch="UniformToFill" Opacity="0.6"/><Border Background="#550B0B10"/><StackPanel Margin="25,23"><TextBlock Text="ERXCKOS / CONTROL CENTER" Foreground="#E79AAD" FontSize="10" FontWeight="SemiBold"/><TextBlock x:Name="Heading" Text="Tools" FontSize="34" FontWeight="Bold" Margin="0,8,0,6"/><TextBlock x:Name="Subtitle" Text="Todo lo que necesitas, en un solo lugar." Foreground="#DDD0D5" FontSize="13"/></StackPanel></Grid></Border>
   <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled"><StackPanel x:Name="Content" Margin="0,0,12,0"/></ScrollViewer>
   <Border Grid.Row="2" Background="#17131B" CornerRadius="10" Padding="15,12" Margin="0,14,0,0"><TextBlock x:Name="Status" Text="Listo. Selecciona una herramienta." Foreground="#D2BBC4" TextWrapping="Wrap" FontSize="12"/></Border>
  </Grid>
 </Grid>
</Window>
'@
$window=[Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($xaml))
$window.Icon=[Windows.Media.Imaging.BitmapFrame]::Create([uri](Join-Path $PSScriptRoot 'Assets/ErxckOS.ico'))
$versionConfig=Get-Content (Join-Path $PSScriptRoot 'update-config.json') -Raw | ConvertFrom-Json
$window.FindName('VersionLabel').Text='UTILITY / '+$versionConfig.version
$script:content=$window.FindName('Content');$script:status=$window.FindName('Status')
$script:heading=$window.FindName('Heading');$script:subtitle=$window.FindName('Subtitle')
$window.FindName('Logo').Source=[Windows.Media.Imaging.BitmapImage]::new([uri](Join-Path $PSScriptRoot 'Assets/logo.png'))
$window.FindName('Wallpaper').Source=[Windows.Media.Imaging.BitmapImage]::new([uri](Join-Path $PSScriptRoot 'Assets/wallpaper.png'))
$script:process=$null;$script:result=$null;$script:buttons=[Collections.Generic.List[Windows.Controls.Button]]::new()
function Text([string]$value,[int]$size=14,[string]$color='#F5F1F3') {
 $t=[Windows.Controls.TextBlock]::new();$t.Text=$value;$t.FontSize=$size;$t.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString($color);$t.TextWrapping='Wrap';return $t
}
function Header([string]$value) {
 $t=Text $value 19;$t.FontWeight='SemiBold';$t.Margin='0,12,0,14';$script:content.Children.Add($t)|Out-Null
}
function Run-Action([string]$action) {
 if ($script:process -and -not $script:process.HasExited) { return }
 $script:result=Join-Path ([IO.Path]::GetTempPath()) ('ErxckOS-'+[guid]::NewGuid().ToString('N')+'.json')
 $workerArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File',('"{0}"' -f (Join-Path $PSScriptRoot 'Scripts/Invoke-ErxckOS.ps1')),'-Action',$action,'-ResultPath',('"{0}"' -f $script:result))
 try {
  $script:process=Start-Process "$PSHOME\powershell.exe" -ArgumentList $workerArguments -WindowStyle Hidden -PassThru
  $script:status.Text='Aplicando cambios... espera a que termine.'
  foreach ($b in $script:buttons) { $b.IsEnabled=$false }
 } catch { $script:status.Text=$_.Exception.Message }
}
function New-ActionButton([string]$label,[string]$action,[bool]$secondary=$false) {
 $b=[Windows.Controls.Button]::new();$b.Content=$label;$b.Tag=$action
 if ($secondary) { $b.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#30242D') }
 $b.Add_Click({ param($sender,$e) Run-Action ([string]$sender.Tag) });$script:buttons.Add($b);return $b
}
function Card([string]$title,[string]$description,[object[]]$actions) {
 if ($actions.Count -eq 2 -and $actions[0] -is [string]) { $actions=@(,$actions) }
 $border=[Windows.Controls.Border]::new();$border.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#17151D');$border.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString('#30252E');$border.BorderThickness='1';$border.CornerRadius='13';$border.Padding='20';$border.Margin='0,0,0,12'
 $panel=[Windows.Controls.StackPanel]::new();$h=Text $title 16;$h.FontWeight='SemiBold';$panel.Children.Add($h)|Out-Null
 $d=Text $description 12 '#AE9CA5';$d.Margin='0,7,0,16';$panel.Children.Add($d)|Out-Null
 $row=[Windows.Controls.WrapPanel]::new();$i=0
 foreach ($a in $actions) { $row.Children.Add((New-ActionButton $a[0] $a[1] ($i -gt 0)))|Out-Null;$i++ }
 $panel.Children.Add($row)|Out-Null;$border.Child=$panel;$script:content.Children.Add($border)|Out-Null
}
function Open-Updates([bool]$playbook) {
 try {
  $config=Get-Content (Join-Path $PSScriptRoot 'update-config.json') -Raw | ConvertFrom-Json
  if ($config.repository -notmatch '^[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+$') { throw 'El repositorio de actualizaciones aun no esta configurado.' }
  $url='https://github.com/'+$config.repository+'/releases'
  if ($playbook) {
   [Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
   $releases=Invoke-RestMethod -Uri ('https://api.github.com/repos/'+$config.repository+'/releases?per_page=10') -Headers @{'User-Agent'='ErxckOS-Tool'} -TimeoutSec 10
   $asset=$null
   foreach ($release in $releases) {
    if ($release.draft) { continue }
    $asset=$release.assets | Where-Object {$_.name -eq 'ErxckOS.apbx'} | Select-Object -First 1
    if ($asset) { break }
   }
   if (-not $asset) { throw 'Aun no hay un playbook publicado en este repositorio.' }
   $candidate=[uri]$asset.browser_download_url
   if ($candidate.Scheme -ne 'https' -or $candidate.Host -ne 'github.com' -or -not $candidate.AbsolutePath.StartsWith('/'+$config.repository+'/releases/download/')) { throw 'La publicacion devolvio una direccion inesperada.' }
   $url=$candidate.AbsoluteUri
  }
  Start-Process $url
  $script:status.Text='Abriendo la publicacion de ErxckOS. Las actualizaciones del playbook se aplican con AME Wizard.'
 } catch { $script:status.Text=$_.Exception.Message }
}
function Tools {
 if ($script:process -and -not $script:process.HasExited) { return }
 $script:content.Children.Clear();$script:buttons.Clear();$script:heading.Text='Tools';$script:subtitle.Text='Herramientas para preparar tu sistema.'
 Header 'Install Browsers'
 Card 'Google Chrome' 'Instala Google Chrome mediante winget.' @(@('Instalar','Chrome'))
 Card 'Firefox' 'Instala Firefox mediante winget.' @(@('Instalar','Firefox'))
 Card 'Brave' 'Instala Brave mediante winget.' @(@('Instalar','Brave'))
 Card 'Chromium' 'Instala Chromium para Windows mediante winget.' @(@('Instalar','Chromium'))
 Header 'Planes de energia'
 Card 'Perfil automatico: laptop / PC' 'Detecta el chasis y el tipo de equipo. En laptop conserva la configuracion de bateria y ajusta el procesador conectado a corriente. Si no puede identificarlo, mantiene el plan actual.' @(@('Automatico','AutoPower'),@('Laptop','LaptopPower'),@('PC','DesktopPower'))
 Card 'ErxckOS - Equilibrado' 'Plan equilibrado de ErxckOS.' @(@('Activar','Balanced'))
 Card 'ErxckOS - Rendimiento' 'Plan de rendimiento de ErxckOS.' @(@('Activar','Performance'))
 Card 'ErxckOS - Ultra Performance' 'Plan de ErxckOS con los parametros de rendimiento de la base del playbook.' @(@('Activar','Ultra'))
 Header 'Identidad y actualizaciones'
 Card 'Identidad ErxckOS' 'Cambia la identificacion del sistema y renombra la cuenta local actual. Conserva la carpeta del perfil. No renombra cuentas Microsoft o de dominio.' @(@('Aplicar ErxckOS','Branding'))
 $row=[Windows.Controls.WrapPanel]::new()
 $release=[Windows.Controls.Button]::new();$release.Content='Ver actualizaciones';$release.Add_Click({Open-Updates $false})
 $playbook=[Windows.Controls.Button]::new();$playbook.Content='Descargar playbook';$playbook.Add_Click({Open-Updates $true})
 $row.Children.Add($release)|Out-Null;$row.Children.Add($playbook)|Out-Null;$script:content.Children.Add($row)|Out-Null
}
function Tweaks {
 if ($script:process -and -not $script:process.HasExited) { return }
 $script:content.Children.Clear();$script:buttons.Clear();$script:heading.Text='Tweaking';$script:subtitle.Text='Ajustes integrados. Sin instalar otra utilidad.'
 Card 'Proteccion integrada del sistema' 'Controla los servicios de proteccion. Desactivarlos reduce la proteccion del equipo. La restauracion usa los archivos guardados por esta herramienta.' @(@('Activar proteccion','SecurityOn'),@('Desactivar proteccion','SecurityOff'))
 Card 'SysMain y ReadyBoost' 'Activa o desactiva los servicios y los parametros de precarga incluidos en el playbook. Requiere reiniciar.' @(@('Activar','SysMainOn'),@('Desactivar','SysMainOff'))
 Card 'Compresion de memoria' 'Controla la compresion de memoria del sistema.' @(@('Activar','MemoryOn'),@('Desactivar','MemoryOff'))
 Card 'MPO' 'Controla Multiplane Overlay. Reinicia despues de cambiarlo.' @(@('Restaurar','MpoOn'),@('Desactivar','MpoOff'))
 Card 'Aplicaciones en segundo plano' 'Permite o bloquea la actividad en segundo plano para el usuario que ejecuta la app.' @(@('Permitir','BackgroundOn'),@('Bloquear','BackgroundOff'))
 Card 'Captura de juegos' 'Activa o desactiva la captura de juegos para el usuario que ejecuta la app.' @(@('Activar','DvrOn'),@('Desactivar','DvrOff'))
 Card 'Power throttling' 'Controla la politica de limitacion de energia en segundo plano.' @(@('Activar','PowerThrottleOn'),@('Desactivar','PowerThrottleOff'))
 Card 'Actualizacion de controladores' 'Incluye o excluye controladores en las actualizaciones del sistema.' @(@('Permitir','DriversOn'),@('Bloquear','DriversOff'))
}
$window.FindName('ToolsNav').Add_Click({Tools})
$window.FindName('TweaksNav').Add_Click({Tweaks})
$timer=[Windows.Threading.DispatcherTimer]::new();$timer.Interval=[TimeSpan]::FromMilliseconds(250)
$timer.Add_Tick({
 if ($script:process -and $script:process.HasExited) {
  try {
   if (Test-Path $script:result) { $r=Get-Content $script:result -Raw | ConvertFrom-Json;$script:status.Text=$r.message }
   else { $script:status.Text='La operacion termino sin resultado verificable. Codigo: '+$script:process.ExitCode }
  } catch { $script:status.Text='No se pudo leer el resultado: '+$_.Exception.Message }
  finally {
   Remove-Item $script:result -ErrorAction SilentlyContinue;$script:process.Dispose();$script:process=$null
   foreach ($b in $script:buttons) { $b.IsEnabled=$true }
  }
 }
})
$window.Add_Closing({param($sender,$e) if ($script:process -and -not $script:process.HasExited) {$e.Cancel=$true;$script:status.Text='Espera a que termine la operacion antes de cerrar.'}})
$window.Add_Closed({$timer.Stop()})
Tools;$timer.Start();$window.ShowDialog() | Out-Null
