# Seguridad de Windows — 0.4.2

Caso observado: WinDefend Running/Automatic, SecurityHealthService y wscsvc Stopped/Disabled; sc config y reg add como administrador devuelven Acceso denegado. La pagina de Seguridad de Windows no esta disponible. No se ha confirmado una tarea que reaplique el bloqueo en cada arranque.

Causa encontrada en el proyecto: software.yml invocaba ErxckOS.Security.Disable.cmd automaticamente tras instalar la tool. Ese script ponia Start=4 en ambos servicios y retiraba el inicio del icono. Es una fuente concreta del cambio; el estado del equipo tambien puede incluir modificaciones de otras herramientas.

Prevencion: retirar esa invocacion automatica; preservar los dos servicios de interfaz y el inicio del icono incluso en la accion manual SecurityOff; retirar HideSystray y la marca de desaprovisionamiento de SecHealthUI; dejar de aplicar la configuracion heredada que ponia a cero parametros de Restaurar sistema. SecurityOff sigue siendo una opcion manual que reduce otras protecciones: no se debe confundir con la reparacion limitada.

Reparacion separada: support/windows-security usa el mismo auxiliar MinSudo/NanaRun, verificado por SHA256. Intenta restaurar exclusivamente los DWORD Start de SecurityHealthService=3 y wscsvc=2 bajo TrustedInstaller. Exporta las claves antes, verifica los valores y registra errores. No cambia ACL, propietarios, WinDefend, directivas de interfaz ni tareas; no reinicia automaticamente. El modo SoloDiagnostico solo consulta.

Validacion: pruebas del contrato de preservacion, sintaxis PS5.1, diagnostico de solo lectura en Windows y prueba del token de elevacion con un script temporal que solo escribe su identidad. No se ejecuta la reparacion real de servicios en CI. Requiere confirmar el resultado y la apertura de la pagina en el equipo del usuario despues de reiniciar. Si la pagina sigue bloqueada con los servicios restaurados, revisar las directivas o componentes que recojan los registros; no declarar reparacion completa antes.
