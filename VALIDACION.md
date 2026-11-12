# Validacion 0.4.1

- Local: 8 pruebas Python, 22 comprobaciones de perfiles y analizador de 9 scripts PowerShell.
- El test Python usa bytes sinteticos como fixture del instalador exclusivamente para comprobar el contenido y los hashes del APBX; no prueba la ejecucion del EXE.
- La prueba real de Windows `tests/installer-smoke.ps1` instala dos veces en una ruta con espacios, comprueba archivos/version/licencias/accesos/registro de desinstalacion, ejecuta solo el diagnostico del lanzador y desinstala. El diagnostico no ejecuta PowerShell ni tweaks.
- La compilacion del lanzador C# y del instalador Inno Setup y la prueba real del instalador se verifican en GitHub Actions antes de publicar.

## Historial

- Base 0.2.0: dos pruebas Python de empaquetado, sin instalacion completa en Windows.
- 0.3.0: 22 comprobaciones de perfiles ejecutadas con CIM/powercfg sustituidos; nunca se ejecutan tweaks durante esos tests.
- Casos: notebook, portatil sin bateria, UPS en PC, workstation, varios chasis, docking, desmontable, CIM parcial/inaccesible, desconocido, reejecucion, fallback de esquema y error de powercfg.
- Cuatro pruebas Python: identidad/repositorio del paquete, presencia del modulo en app y playbook, configuracion de actualizaciones y ausencia de imposiciones globales de hibernacion/Ultra.
- Siete scripts pasan el analizador sintactico PowerShell 7.7.0.
- GitHub Actions ejecuta esos controles en Windows PowerShell 5.1, construye los paquetes y publica una version de prueba al subir la etiqueta que coincide con VERSION.

No se ha ejecutado la interfaz WPF ni aplicado el playbook completo en Windows. No se midieron FPS, latencia, temperatura o bateria. Las pruebas con fronteras simuladas verifican la logica, no la respuesta de todos los dispositivos o versiones de Windows. Los ajustes heredados requieren pruebas propias.

El perfil Laptop conserva los valores existentes cuando se crea por primera vez. No restaura configuraciones perdidas por versiones anteriores. Ante un fallo se intenta recuperar el esquema activo previo, sin prometer revertir parametros ya escritos en un esquema existente.

## Integracion AME 0.4.1

Se incorpora una prueba del usuario elevado y del log del instalador. Ver docs/INSTALLER-0.4.1.md; la ejecucion real de AME en el equipo que reporto el fallo sigue pendiente.
