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
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="ErxckOS Tool" Width="1160" Height="780" MinWidth="960" MinHeight="680" WindowStartupLocation="CenterScreen" Background="#08070B" Foreground="#F5F1F3" FontFamily="Segoe UI Variable Text, Segoe UI" UseLayoutRounding="True" SnapsToDevicePixels="True">
 <Window.Resources>

  <!-- Brushes reutilizables -->
  <LinearGradientBrush x:Key="HairlineBrush" StartPoint="0,0" EndPoint="1,0"><GradientStop Color="#55C9566F" Offset="0"/><GradientStop Color="#00C9566F" Offset="1"/></LinearGradientBrush>
  <LinearGradientBrush x:Key="AccentBarBrush" StartPoint="0,0" EndPoint="0,1"><GradientStop Color="#E0476A" Offset="0"/><GradientStop Color="#84283F" Offset="1"/></LinearGradientBrush>

  <!-- Boton principal (vino) -->
  <Style TargetType="Button">
   <Setter Property="Foreground" Value="#FFFFFF"/>
   <Setter Property="FontSize" Value="12.5"/>
   <Setter Property="FontWeight" Value="SemiBold"/>
   <Setter Property="Padding" Value="18,9"/>
   <Setter Property="Margin" Value="0,0,10,0"/>
   <Setter Property="BorderThickness" Value="1"/>
   <Setter Property="BorderBrush" Value="#40E79AAD"/>
   <Setter Property="Cursor" Value="Hand"/>
   <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
   <Setter Property="Background"><Setter.Value><LinearGradientBrush StartPoint="0,0" EndPoint="0,1"><GradientStop Color="#A63450" Offset="0"/><GradientStop Color="#7A2238" Offset="1"/></LinearGradientBrush></Setter.Value></Setter>
   <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button">
    <Grid x:Name="root" SnapsToDevicePixels="True">
     <Border x:Name="b" CornerRadius="8" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"/>
     <Border x:Name="hl" CornerRadius="8" Background="White" Opacity="0" IsHitTestVisible="False"/>
     <ContentPresenter Margin="{TemplateBinding Padding}" HorizontalAlignment="Center" VerticalAlignment="Center" RecognizesAccessKey="True"/>
    </Grid>
    <ControlTemplate.Triggers>
     <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="hl" Property="Opacity" Value="0.12"/></Trigger>
     <Trigger Property="IsKeyboardFocused" Value="True"><Setter TargetName="b" Property="BorderBrush" Value="#E79AAD"/></Trigger>
     <Trigger Property="IsPressed" Value="True"><Setter TargetName="hl" Property="Background" Value="Black"/><Setter TargetName="hl" Property="Opacity" Value="0.25"/></Trigger>
     <Trigger Property="IsEnabled" Value="False"><Setter TargetName="root" Property="Opacity" Value="0.4"/></Trigger>
    </ControlTemplate.Triggers>
   </ControlTemplate></Setter.Value></Setter>
  </Style>

  <!-- Boton secundario (contorno) -->
  <Style x:Key="GhostButton" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
   <Setter Property="Foreground" Value="#E9DCE2"/>
   <Setter Property="BorderBrush" Value="#3B2D37"/>
   <Setter Property="Background" Value="#1B1620"/>
  </Style>

  <!-- Navegacion lateral -->
  <Style x:Key="NavButton" TargetType="Button">
   <Setter Property="Foreground" Value="#A99AA2"/>
   <Setter Property="FontSize" Value="13.5"/>
   <Setter Property="FontWeight" Value="Medium"/>
   <Setter Property="Padding" Value="18,12"/>
   <Setter Property="Margin" Value="0,0,0,6"/>
   <Setter Property="Cursor" Value="Hand"/>
   <Setter Property="HorizontalContentAlignment" Value="Left"/>
   <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
   <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button">
    <Grid SnapsToDevicePixels="True">
     <Border x:Name="bg" CornerRadius="10" Background="Transparent"/>
     <Border x:Name="bar" Width="3" Height="20" CornerRadius="2" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="0" Background="{StaticResource AccentBarBrush}" Visibility="Collapsed"/>
     <ContentPresenter Margin="{TemplateBinding Padding}" HorizontalAlignment="Left" VerticalAlignment="Center"/>
    </Grid>
    <ControlTemplate.Triggers>
     <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bg" Property="Background" Value="#14FFFFFF"/></Trigger>
     <Trigger Property="Tag" Value="active"><Setter TargetName="bg" Property="Background" Value="#33A63450"/><Setter TargetName="bar" Property="Visibility" Value="Visible"/></Trigger>
    </ControlTemplate.Triggers>
   </ControlTemplate></Setter.Value></Setter>
   <Style.Triggers>
    <Trigger Property="IsMouseOver" Value="True"><Setter Property="Foreground" Value="#F5F1F3"/></Trigger>
    <Trigger Property="Tag" Value="active"><Setter Property="Foreground" Value="#FFFFFF"/></Trigger>
   </Style.Triggers>
  </Style>

  <!-- Tarjeta -->
  <Style x:Key="Card" TargetType="Border">
   <Setter Property="CornerRadius" Value="12"/>
   <Setter Property="Padding" Value="20,18"/>
   <Setter Property="Margin" Value="0,0,0,10"/>
   <Setter Property="BorderThickness" Value="1"/>
   <Setter Property="BorderBrush" Value="#292129"/>
   <Setter Property="Background"><Setter.Value><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#17141C" Offset="0"/><GradientStop Color="#120F16" Offset="1"/></LinearGradientBrush></Setter.Value></Setter>
   <Style.Triggers>
    <Trigger Property="IsMouseOver" Value="True"><Setter Property="BorderBrush" Value="#5C2B3D"/></Trigger>
   </Style.Triggers>
  </Style>

  <!-- Barra de desplazamiento fina -->
  <Style TargetType="ScrollBar">
   <Setter Property="Width" Value="8"/>
   <Setter Property="Background" Value="Transparent"/>
   <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="ScrollBar">
    <Grid Background="Transparent">
     <Track x:Name="PART_Track" IsDirectionReversed="True">
      <Track.DecreaseRepeatButton><RepeatButton Command="ScrollBar.PageUpCommand" Focusable="False" IsTabStop="False"><RepeatButton.Template><ControlTemplate TargetType="RepeatButton"><Border Background="Transparent"/></ControlTemplate></RepeatButton.Template></RepeatButton></Track.DecreaseRepeatButton>
      <Track.IncreaseRepeatButton><RepeatButton Command="ScrollBar.PageDownCommand" Focusable="False" IsTabStop="False"><RepeatButton.Template><ControlTemplate TargetType="RepeatButton"><Border Background="Transparent"/></ControlTemplate></RepeatButton.Template></RepeatButton></Track.IncreaseRepeatButton>
      <Track.Thumb><Thumb><Thumb.Template><ControlTemplate TargetType="Thumb"><Border x:Name="t" Background="#3A2C36" CornerRadius="4" Margin="1,0"/><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="t" Property="Background" Value="#84283F"/></Trigger><Trigger Property="IsDragging" Value="True"><Setter TargetName="t" Property="Background" Value="#A63450"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Thumb.Template></Thumb></Track.Thumb>
     </Track>
    </Grid>
   </ControlTemplate></Setter.Value></Setter>
  </Style>

 </Window.Resources>

 <Grid>
  <Grid.ColumnDefinitions><ColumnDefinition Width="250"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>

  <!-- Barra lateral -->
  <Border Grid.Column="0" BorderBrush="#221C26" BorderThickness="0,0,1,0">
   <Border.Background><LinearGradientBrush StartPoint="0,0" EndPoint="0,1"><GradientStop Color="#120F16" Offset="0"/><GradientStop Color="#0B090E" Offset="1"/></LinearGradientBrush></Border.Background>
   <Grid Margin="20,28,20,24">
    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
    <StackPanel>
     <Grid Height="104" Margin="0,0,0,8">
      <Ellipse Width="150" Height="104" IsHitTestVisible="False"><Ellipse.Fill><RadialGradientBrush><GradientStop Color="#40C9566F" Offset="0"/><GradientStop Color="#00C9566F" Offset="1"/></RadialGradientBrush></Ellipse.Fill></Ellipse>
      <Image x:Name="Logo" Height="84" Stretch="Uniform" RenderOptions.BitmapScalingMode="HighQuality"/>
     </Grid>
     <TextBlock Text="ErxckOS" FontFamily="Segoe UI Variable Display, Segoe UI" FontSize="26" FontWeight="Bold" HorizontalAlignment="Center"/>
     <Border HorizontalAlignment="Center" Margin="0,10,0,32" Padding="10,3" CornerRadius="10" Background="#1F1620" BorderBrush="#3B2530" BorderThickness="1"><TextBlock x:Name="VersionLabel" Text="UTILITY / 0.4.3" Foreground="#C79AA9" FontSize="10" FontWeight="SemiBold"/></Border>
    </StackPanel>
    <StackPanel Grid.Row="1">
     <TextBlock Text="MENU" Foreground="#6A5A62" FontSize="10" FontWeight="SemiBold" Margin="18,0,0,10"/>
     <Button x:Name="ToolsNav" Style="{StaticResource NavButton}" Tag="active"><StackPanel Orientation="Horizontal"><Path Width="16" Height="16" Stretch="Uniform" StrokeThickness="1.6" StrokeLineJoin="Round" VerticalAlignment="Center" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType={x:Type Button}}}" Data="M1,1 H6 V6 H1 Z M10,1 H15 V6 H10 Z M1,10 H6 V15 H1 Z M10,10 H15 V15 H10 Z"/><TextBlock Text="Tools" Margin="13,0,0,0" VerticalAlignment="Center"/></StackPanel></Button>
     <Button x:Name="TweaksNav" Style="{StaticResource NavButton}"><StackPanel Orientation="Horizontal"><Path Width="16" Height="16" Stretch="Uniform" StrokeThickness="1.6" StrokeStartLineCap="Round" StrokeEndLineCap="Round" VerticalAlignment="Center" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType={x:Type Button}}}" Data="M1,4 H15 M1,12 H15 M5,1.5 V6.5 M11,9.5 V14.5"/><TextBlock Text="Tweaking" Margin="13,0,0,0" VerticalAlignment="Center"/></StackPanel></Button>
    </StackPanel>
    <StackPanel Grid.Row="3">
     <Rectangle Height="1" Fill="{StaticResource HairlineBrush}" Margin="0,0,0,14"/>
     <TextBlock Text="Tu sistema. Tu estilo." Foreground="#B59DA6" FontSize="12" FontWeight="Medium"/>
     <TextBlock Text="ErxckOS Tool" Foreground="#6E5D65" FontSize="11" Margin="0,4,0,0"/>
    </StackPanel>
   </Grid>
  </Border>

  <!-- Area principal -->
  <Grid Grid.Column="1">
   <Grid.Background><RadialGradientBrush Center="0.95,0" GradientOrigin="0.95,0" RadiusX="0.85" RadiusY="0.65"><GradientStop Color="#1E84283F" Offset="0"/><GradientStop Color="#0008070B" Offset="1"/></RadialGradientBrush></Grid.Background>
   <Grid Margin="36,28,36,22">
    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>

    <!-- Banner -->
    <Border Height="156" Margin="0,0,0,22" CornerRadius="16" BorderBrush="#3A2430" BorderThickness="1">
     <Grid>
      <Grid.OpacityMask><VisualBrush Visual="{Binding ElementName=BannerMask}"/></Grid.OpacityMask>
      <Border x:Name="BannerMask" CornerRadius="15" Background="#0D0B10"/>
      <Image x:Name="Wallpaper" Width="1100" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,-330,0" Stretch="Uniform" Opacity="0.9" RenderOptions.BitmapScalingMode="HighQuality"/>
      <Border><Border.Background><LinearGradientBrush StartPoint="0,0" EndPoint="1,0"><GradientStop Color="#F008070B" Offset="0"/><GradientStop Color="#C808070B" Offset="0.42"/><GradientStop Color="#2008070B" Offset="1"/></LinearGradientBrush></Border.Background></Border>
      <StackPanel Margin="30,0,30,0" VerticalAlignment="Center">
       <StackPanel Orientation="Horizontal"><Ellipse Width="6" Height="6" Fill="#E0476A" VerticalAlignment="Center"/><TextBlock Text="ERXCKOS / CONTROL CENTER" Foreground="#E79AAD" FontSize="10" FontWeight="SemiBold" Margin="9,0,0,0"/></StackPanel>
       <TextBlock x:Name="Heading" Text="Tools" FontFamily="Segoe UI Variable Display, Segoe UI" FontSize="36" FontWeight="Bold" Margin="0,8,0,6"/>
       <TextBlock x:Name="Subtitle" Text="Todo lo que necesitas, en un solo lugar." Foreground="#D9CBD1" FontSize="13"/>
      </StackPanel>
     </Grid>
    </Border>

    <!-- Contenido -->
    <ScrollViewer x:Name="Scroller" Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled"><StackPanel x:Name="Content" Margin="0,0,14,6"/></ScrollViewer>

    <!-- Estado -->
    <Border Grid.Row="2" Background="#120F16" BorderBrush="#2A212B" BorderThickness="1" CornerRadius="10" Padding="16,12" Margin="0,14,0,0">
     <Grid>
      <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
      <Ellipse Width="8" Height="8" Fill="#E0476A" VerticalAlignment="Center" Margin="0,0,14,0"><Ellipse.Effect><DropShadowEffect Color="#E0476A" BlurRadius="9" ShadowDepth="0" Opacity="0.85"/></Ellipse.Effect></Ellipse>
      <TextBlock x:Name="Status" Grid.Column="1" Text="Listo. Selecciona una herramienta." Foreground="#D2BBC4" TextWrapping="Wrap" FontSize="12" VerticalAlignment="Center"/>
     </Grid>
    </Border>
   </Grid>
  </Grid>
 </Grid>
</Window>
'@
$window=[Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($xaml))
$window.Icon=[Windows.Media.Imaging.BitmapFrame]::Create([uri](Join-Path $PSScriptRoot 'Assets/ErxckOS.ico'))
$versionConfig=Get-Content (Join-Path $PSScriptRoot 'update-config.json') -Raw | ConvertFrom-Json
$window.FindName('VersionLabel').Text='UTILITY / '+$versionConfig.version
$script:content=$window.FindName('Content');$script:status=$window.FindName('Status')
$script:heading=$window.FindName('Heading');$script:subtitle=$window.FindName('Subtitle');$script:scroller=$window.FindName('Scroller')
$window.FindName('Logo').Source=[Windows.Media.Imaging.BitmapImage]::new([uri](Join-Path $PSScriptRoot 'Assets/logo.png'))
$window.FindName('Wallpaper').Source=[Windows.Media.Imaging.BitmapImage]::new([uri](Join-Path $PSScriptRoot 'Assets/wallpaper.png'))
# Barra de titulo oscura (solo estetica; si el sistema no lo soporta se ignora)
try {
 Add-Type -Namespace ErxckOS -Name Dwm -MemberDefinition '[DllImport("dwmapi.dll")] public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int value, int size);'
 $window.Add_SourceInitialized({
  param($sender,$e)
  try {
   $handle=[Windows.Interop.WindowInteropHelper]::new($sender).Handle
   $dark=1;$caption=0x120C0E
   foreach ($attr in 20,19) { [ErxckOS.Dwm]::DwmSetWindowAttribute($handle,$attr,[ref]$dark,4)|Out-Null }
   [ErxckOS.Dwm]::DwmSetWindowAttribute($handle,35,[ref]$caption,4)|Out-Null
  } catch {}
 })
} catch {}
$script:process=$null;$script:result=$null;$script:buttons=[Collections.Generic.List[Windows.Controls.Button]]::new()
function Text([string]$value,[int]$size=14,[string]$color='#F5F1F3') {
 $t=[Windows.Controls.TextBlock]::new();$t.Text=$value;$t.FontSize=$size;$t.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString($color);$t.TextWrapping='Wrap';return $t
}
function Set-Nav([string]$active) {
 $window.FindName('ToolsNav').Tag=$(if ($active -eq 'Tools') {'active'} else {''})
 $window.FindName('TweaksNav').Tag=$(if ($active -eq 'Tweaks') {'active'} else {''})
}
function Header([string]$value) {
 $grid=[Windows.Controls.Grid]::new()
 if ($script:content.Children.Count -eq 0) { $grid.Margin='0,2,0,14' } else { $grid.Margin='0,20,0,14' }
 $c1=[Windows.Controls.ColumnDefinition]::new();$c1.Width=[Windows.GridLength]::Auto
 $c2=[Windows.Controls.ColumnDefinition]::new();$c2.Width=[Windows.GridLength]::new(1,[Windows.GridUnitType]::Star)
 $grid.ColumnDefinitions.Add($c1);$grid.ColumnDefinitions.Add($c2)
 $t=Text ($value.ToUpper()) 11 '#C9566F';$t.FontWeight='SemiBold'
 $line=[Windows.Shapes.Rectangle]::new();$line.Height=1;$line.Margin='16,0,0,0';$line.VerticalAlignment='Center';$line.Fill=$window.FindResource('HairlineBrush')
 [Windows.Controls.Grid]::SetColumn($line,1)
 $grid.Children.Add($t)|Out-Null;$grid.Children.Add($line)|Out-Null;$script:content.Children.Add($grid)|Out-Null
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
 if ($secondary) { $b.Style=$window.FindResource('GhostButton') }
 $b.Add_Click({ param($sender,$e) Run-Action ([string]$sender.Tag) });$script:buttons.Add($b);return $b
}
function Compose-Card([string]$title,[string]$description,[Windows.Controls.Button[]]$cardButtons,[bool]$inline) {
 $border=[Windows.Controls.Border]::new();$border.Style=$window.FindResource('Card')
 $grid=[Windows.Controls.Grid]::new()
 $titleRow=[Windows.Controls.StackPanel]::new();$titleRow.Orientation='Horizontal'
 $bar=[Windows.Shapes.Rectangle]::new();$bar.Width=3;$bar.Height=16;$bar.RadiusX=1.5;$bar.RadiusY=1.5;$bar.Fill=$window.FindResource('AccentBarBrush');$bar.Margin='0,0,10,0';$bar.VerticalAlignment='Center'
 $h=Text $title 15;$h.FontWeight='SemiBold';$h.VerticalAlignment='Center'
 $titleRow.Children.Add($bar)|Out-Null;$titleRow.Children.Add($h)|Out-Null
 $text=[Windows.Controls.StackPanel]::new();$text.Children.Add($titleRow)|Out-Null
 $d=Text $description 12 '#A8979F';$d.LineHeight=18
 if ($inline) {
  $d.Margin='13,7,28,0';$text.Children.Add($d)|Out-Null
  $c1=[Windows.Controls.ColumnDefinition]::new();$c1.Width=[Windows.GridLength]::new(1,[Windows.GridUnitType]::Star)
  $c2=[Windows.Controls.ColumnDefinition]::new();$c2.Width=[Windows.GridLength]::Auto
  $grid.ColumnDefinitions.Add($c1);$grid.ColumnDefinitions.Add($c2)
  $row=[Windows.Controls.StackPanel]::new();$row.Orientation='Horizontal';$row.VerticalAlignment='Center'
  foreach ($cb in $cardButtons) { $cb.Margin='10,0,0,0';$row.Children.Add($cb)|Out-Null }
  [Windows.Controls.Grid]::SetColumn($row,1)
  $grid.Children.Add($text)|Out-Null;$grid.Children.Add($row)|Out-Null
 } else {
  $d.Margin='13,7,0,0';$text.Children.Add($d)|Out-Null
  $r1=[Windows.Controls.RowDefinition]::new();$r1.Height=[Windows.GridLength]::Auto
  $r2=[Windows.Controls.RowDefinition]::new();$r2.Height=[Windows.GridLength]::Auto
  $grid.RowDefinitions.Add($r1);$grid.RowDefinitions.Add($r2)
  $row=[Windows.Controls.WrapPanel]::new();$row.Margin='13,16,0,0'
  foreach ($cb in $cardButtons) { $cb.Margin='0,0,10,0';$row.Children.Add($cb)|Out-Null }
  [Windows.Controls.Grid]::SetRow($row,1)
  $grid.Children.Add($text)|Out-Null;$grid.Children.Add($row)|Out-Null
 }
 $border.Child=$grid;$script:content.Children.Add($border)|Out-Null
}
function Card([string]$title,[string]$description,[object[]]$actions) {
 if ($actions.Count -eq 2 -and $actions[0] -is [string]) { $actions=@(,$actions) }
 $cardButtons=[Collections.Generic.List[Windows.Controls.Button]]::new();$i=0;$chars=0
 foreach ($a in $actions) { $cardButtons.Add((New-ActionButton $a[0] $a[1] ($i -gt 0)));$chars+=([string]$a[0]).Length;$i++ }
 Compose-Card $title $description $cardButtons.ToArray() (($cardButtons.Count -le 3) -and ($chars -le 28))
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
 Set-Nav 'Tools';$script:scroller.ScrollToTop()
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
 Card 'Identidad ErxckOS' 'Cambia la identificacion del sistema y renombra la cuenta local actual. Conserva la carpeta del perfil y pone ErxckOS como nombre de la unidad de Windows. Las cuentas Microsoft o de dominio conservan su nombre.' @(@('Aplicar ErxckOS','Branding'))
 $release=[Windows.Controls.Button]::new();$release.Content='Ver actualizaciones';$release.Add_Click({Open-Updates $false})
 $playbook=[Windows.Controls.Button]::new();$playbook.Content='Descargar playbook';$playbook.Style=$window.FindResource('GhostButton');$playbook.Add_Click({Open-Updates $true})
 Compose-Card 'Actualizaciones' 'Las actualizaciones del playbook se aplican con AME Wizard.' @($release,$playbook) $false
}
function Tweaks {
 if ($script:process -and -not $script:process.HasExited) { return }
 $script:content.Children.Clear();$script:buttons.Clear();$script:heading.Text='Tweaking';$script:subtitle.Text='Ajustes integrados. Sin instalar otra utilidad.'
 Set-Nav 'Tweaks';$script:scroller.ScrollToTop()
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
