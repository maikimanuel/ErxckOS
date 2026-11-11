# Validacion 0.3.0

- Base 0.2.0: dos pruebas Python de empaquetado, sin instalacion completa en Windows.
- 0.3.0: 22 comprobaciones de perfiles ejecutadas con CIM/powercfg sustituidos; nunca se ejecutan tweaks durante esos tests.
- Casos: notebook, portatil sin bateria, UPS en PC, workstation, varios chasis, docking, desmontable, CIM parcial/inaccesible, desconocido, reejecucion, fallback de esquema y error de powercfg.
- Cuatro pruebas Python: identidad/repositorio del paquete, presencia del modulo en app y playbook, configuracion de actualizaciones y ausencia de imposiciones globales de hibernacion/Ultra.
- Siete scripts pasan el analizador sintactico PowerShell 7.7.0.
- GitHub Actions ejecuta esos controles en Windows PowerShell 5.1, construye los paquetes y publica una version de prueba al subir la etiqueta que coincide con VERSION.

No se ha ejecutado la interfaz WPF ni aplicado el playbook completo en Windows. No se midieron FPS, latencia, temperatura o bateria. Las pruebas con fronteras simuladas verifican la logica, no la respuesta de todos los dispositivos o versiones de Windows. Los ajustes heredados requieren pruebas propias.

El perfil Laptop conserva los valores existentes cuando se crea por primera vez. No restaura configuraciones perdidas por versiones anteriores. Ante un fallo se intenta recuperar el esquema activo previo, sin prometer revertir parametros ya escritos en un esquema existente.
