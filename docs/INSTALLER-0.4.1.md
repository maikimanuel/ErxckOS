# Ajuste de integracion del instalador — 0.4.1

Los registros recibidos de una ejecucion real de 0.4.0 muestran que AME detuvo el playbook al recibir codigo 4 de ErxckOS-Setup.exe. No contienen el mensaje interno de Inno Setup, porque se suprimian sus mensajes y no se solicitaba un log.

La accion heredaba TrustedInstaller de software.yml. Las pruebas del instalador se hicieron como administrador; no reproducian ese contexto de AME. El instalador usa carpetas de usuario ademas de las compartidas.

Cambio limitado: ejecutar solamente ErxckOS-Setup.exe como currentUserElevated, igual que las acciones de configuracion de la tool. Conservar wait y la detencion ante un resultado no cero. Activar el registro persistente %ProgramData%\ErxckOS-Setup.log. No se ignora el fallo ni se continua sobre una tool incompleta.

La prueba Python comprueba el contrato de ejecucion elevado y de log dentro de las acciones AME. La prueba de Windows comprueba que la instalacion/reinstalacion generan log y mantiene los controles de archivos, accesos, diagnostico y desinstalacion.

Se usa !cmd con start /wait para expandir %ProgramData% dentro del usuario elevado y propagar el codigo del instalador. El !run elevado del codigo publico de AME consultado no expande esas variables en Arguments. La prueba Windows lee y ejecuta el comando real del YAML desde la carpeta del instalador; solo cambia /DIR para aislar la instalacion de prueba.

Limite: el codigo 4 por si solo no identifica el motivo interno. Este cambio corrige la diferencia de contexto identificada y mejora el diagnostico; hace falta comprobar la siguiente ejecucion real con AME. Si falla, obtener ErxckOS-Setup.log ademas de Log.yml y Output.txt.
