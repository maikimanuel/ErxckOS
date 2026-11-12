# Instalacion EXE integrada — 0.4.0

Solicitud: instalar ErxckOS Tool mediante un EXE integrado en el APBX, sin extraer un ZIP.

Se mantiene la interfaz WPF/PowerShell existente. Un lanzador Windows `ErxckOS.exe` inicia el motor instalado; Inno Setup genera `ErxckOS-Setup.exe`, registra la desinstalacion y crea accesos directos al EXE. AME ejecuta ese instalador localmente y espera su terminacion. No descarga la tool. No se ejecutan tweaks al instalar la tool por separado.

El paquete publicado contiene el APBX y sus hashes. El instalador queda dentro del APBX; no se genera el ZIP portable. Los recursos y scripts internos permanecen instalados en Program Files, como archivos de la aplicacion.

Plan de ejecucion:

- [x] Probar el contrato del paquete: instalador dentro, sin ZIP, rechazo si falta el instalador.
- [x] Crear lanzador C# y definicion Inno Setup, con version, icono, recursos, scripts y licencias; compilacion pendiente de Windows CI.
- [x] Sustituir robocopy por instalacion silenciosa local en el playbook; accesos a ErxckOS.exe.
- [ ] Ejecutar pruebas y empaquetado; en CI instalar en una ruta con espacios, verificar archivos/accesos/version, probar diagnostico sin abrir WPF, desinstalar.
- [ ] Publicar version preliminar 0.4.0 y verificar APBX y hashes.

La prueba de instalador no aplica tweaks ni ejecuta la interfaz WPF. La instalacion completa del playbook sigue pendiente de prueba real. El EXE no dispone de firma de editor.
