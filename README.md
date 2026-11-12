# ErxckOS

Playbook personalizado y primera base nativa de ErxckOS Tool para Windows.
Version de pruebas **0.4.1**. No se ha ejecutado una instalacion completa del playbook ni la interfaz en Windows.

## Uso

- Abre `ErxckOS.apbx` con AME Wizard. Dentro viene `ErxckOS-Setup.exe`, que instala la tool automaticamente, sin descargarla ni extraer un ZIP aparte.
- Al terminar, abre **ErxckOS Tool** desde el escritorio o Inicio: el acceso directo ejecuta `ErxckOS.exe` y solicita permisos de administrador.
- La instalacion registra la tool en las aplicaciones de Windows para poder desinstalarla. Desinstalarla elimina sus archivos; no revierte los tweaks aplicados.
- El EXE es un lanzador Windows compilado; la interfaz conserva su motor PowerShell 5.1/WPF y sus archivos de recursos dentro de Program Files. No se ha reescrito la interfaz en C#.
- El EXE y el instalador aun no tienen firma de editor.
- Las modificaciones se ejecutan en la cuenta que eleva la app. Si introduces credenciales de otra cuenta, esa es la cuenta afectada por los ajustes de usuario.

## Contenido implementado

Tools incluye Chrome, Firefox, Brave y Chromium, tres planes ErxckOS, identidad y enlaces de actualizacion.
Chromium utiliza el paquete winget `Hibbiki.Chromium`; se indica aqui el proveedor de la compilacion.
Tweaking incluye proteccion del sistema, SysMain/ReadyBoost, compresion de memoria, MPO,
actividad en segundo plano, captura de juegos, power throttling y actualizaciones de controladores.
Las acciones son individuales y se registra su resultado. El cambio de registro o de un servicio
no garantiza por si solo que una proteccion haya cambiado de estado en ejecucion.

Esta base todavia no reproduce todas las herramientas y ajustes del binario KernelOS entregado.
El ZIP recibido no incluye su proyecto fuente, y no se dispone de una referencia visual de TujuOS
para verificar una replica del diseno. La interfaz usa los recursos y la marca ErxckOS suministrados.

## Perfiles laptop / PC

En Tools, **Automatico** detecta el tipo de equipo y el chasis. **Laptop** y **PC**
permiten elegirlo manualmente. Se utiliza el mismo modulo desde el playbook.

- Laptop copia el plan activo al crear su perfil por primera vez y modifica solo
  los limites de procesador en corriente (minimo 5%, maximo 100%). Conserva sus
  valores de bateria, cierre de tapa, tiempos e hibernacion.
- PC crea un plan ErxckOS a partir de Alto rendimiento, o del plan actual si ese
  esquema no esta disponible. Ajusta los limites del procesador solo en corriente.
- Una UPS o bateria por si sola no identifica una laptop. Si faltan datos de
  chasis/tipo, Automatico informa y conserva el plan actual.
- Se retiro la imposicion global de Ultra, la desactivacion global de hibernacion
  y la desactivacion global de compresion de memoria de la version anterior.
- Los tres planes generales siguen siendo opciones manuales; elegirlos cambia
  el esquema completo. Usa el perfil Laptop para conservar tu configuracion DC.

No se instalan tareas residentes ni se cambia el perfil con un proceso en segundo
plano. Windows aplica los valores AC/DC del esquema seleccionado al conectar o
desconectar el cargador. Un fallo intenta reactivar el plan anterior; no constituye
una restauracion de todos los parametros de un perfil existente.

[Comparacion con los archivos aportados](docs/COMPARACION-LAPTOP-PC.md).

## Identidad y cuentas

La identificacion del autor en AME, los campos OEM, propietario registrado y planes usan ErxckOS.
La cuenta local que ejecuta la configuracion se renombra a ErxckOS, conservando su SID,
carpeta de perfil y contrasena. Una cuenta Microsoft o de dominio no se renombra.
Si ya existe otra cuenta ErxckOS, el script se detiene y no fusiona ni elimina cuentas.
No se cambian EditionID, licencia ni activacion de Windows. El sistema sigue siendo Windows.

## Dependencias del playbook

No descarga, instala ni llama a Revision Tool. Los dos scripts antes externos ahora se incluyen
con una version fija y con nombres ErxckOS. Se incluye un ayudante de elevacion local.
El playbook original descargaba la ultima version de forma dinamica: no se afirma que estos scripts
sean identicos a una version no especificada que se hubiera descargado anteriormente.
Las descargas de aplicaciones/navegadores y Chocolatey requieren Internet.
Compatibilidad heredada del playbook: builds 19044, 19045, 22621, 22631. No se ha ampliado.
Los scripts heredados realizan cambios agresivos y necesitan pruebas sobre esas builds.

## Construir y publicar

1. En Windows x64, instalar Python 3.12 e Inno Setup 6 y ejecutar `python -m pip install -r requirements.txt`.
2. Ejecutar `python -m unittest discover -s tests -v` y `powershell -NoProfile -File tests/device-profile.tests.ps1`.
3. Ejecutar `powershell -NoProfile -File scripts/build-installer.ps1`, despues `powershell -NoProfile -File tests/installer-smoke.ps1` en un Windows de prueba. La prueba instala y desinstala la tool, sin ejecutar tweaks. Finalmente ejecutar `python build.py --repository maikimanuel/ErxckOS --output dist`.
4. Subir el proyecto a `https://github.com/maikimanuel/ErxckOS`.
5. Cambiar `VERSION`, crear una etiqueta `v0.4.1` (o la version correspondiente) y subirla.

GitHub Actions comprueba sintaxis y perfiles en Windows PowerShell 5.1, verifica que
la etiqueta coincida con VERSION, compila/prueba el instalador y empaqueta `ErxckOS.apbx`, genera hashes
y crea una publicacion de prueba. No ejecuta los tweaks en el runner.
El empaquetador configura el repositorio real en el playbook y en la app.
El boton de la app abre las publicaciones; descargar un playbook no lo ejecuta automaticamente.
Sin repositorio configurado, la app lo informa y no usa una URL ficticia.
Para enviar una version estable tras probarla, desmarcar "pre-release" en la publicacion.

## Licencias

La interfaz no contiene una pagina de creditos. Se conservan las licencias y avisos del codigo
y componentes reutilizados en `licenses`, junto con sus scripts fuente. Consulta esos archivos.

## Continuar el trabajo

Consulta [docs/CONTINUAR.md](docs/CONTINUAR.md) para el estado verificado y los pendientes.
