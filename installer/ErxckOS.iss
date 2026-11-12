#ifndef AppSource
  #error AppSource is required
#endif
#ifndef AppVersion
  #error AppVersion is required
#endif
#ifndef OutputFolder
  #error OutputFolder is required
#endif

[Setup]
AppId={{A50F47EF-91BC-4A82-9C46-4010CE60C7CC}
AppName=ErxckOS Tool
AppVersion={#AppVersion}
AppPublisher=ErxckOS
DefaultDirName={autopf}\ErxckOS Tool
DefaultGroupName=ErxckOS Tool
DisableProgramGroupPage=yes
DisableDirPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputFolder}
OutputBaseFilename=ErxckOS-Setup
SetupIconFile={#AppSource}\Assets\ErxckOS.ico
UninstallDisplayIcon={app}\ErxckOS.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "{#AppSource}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
Type: files; Name: "{userdesktop}\ErxckOS Tool.lnk"
Type: files; Name: "{userprograms}\ErxckOS Tool.lnk"

[Icons]
Name: "{commonprograms}\ErxckOS Tool"; Filename: "{app}\ErxckOS.exe"; WorkingDir: "{app}"
Name: "{commondesktop}\ErxckOS Tool"; Filename: "{app}\ErxckOS.exe"; WorkingDir: "{app}"
