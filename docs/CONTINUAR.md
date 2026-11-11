# Continuar ErxckOS

## Encargo vigente

Continuar los chats Revisión de ReviOS y Greeting exchange. Revisar y aprovechar la idea de laptop/PC de los archivos aportados, mantener marca ErxckOS y completar el repositorio maikimanuel/ErxckOS y sus publicaciones. Trabajar por partes y mantener este registro para evitar perder el estado si el chat se llena.

## Base y fuentes

- Base recuperada: ErxckOS-v0.2.0.zip, app PowerShell 5.1/WPF y playbook AME.
- Optiping(3).apbx revisado como ZIP con clave de formato AME.
- PickleOS.apbx.enc estaba cifrado externamente. El usuario aporto despues PickleOS.apbx, que se pudo abrir y revisar directamente.
- docs/COMPARACION-LAPTOP-PC.md contiene la evidencia. No se publican los binarios ni playbooks de referencia de PickleOS/Optiping.

## Trabajo local terminado

- Version 0.3.0; actualizaciones configuradas para maikimanuel/ErxckOS.
- Modulo propio ErxckOS.Power.ps1 compartido por app/playbook: clasifica portatiles, PC o desconocido; una UPS no basta para decidir laptop.
- Acciones Automatico/Laptop/PC en Tools.
- Laptop conserva valores DC/tapa del esquema copiado y solo escribe limites del procesador AC. Desconocido no cambia plan.
- Retiradas imposiciones globales de Ultra, hibernacion desactivada y compresion de memoria desactivada.
- CI en main/PR; release por etiqueta vVERSION, hashes y publicacion de prueba repetible.
- Pruebas locales: 22 comprobaciones PowerShell sin ejecutar tweaks; pruebas Python de empaquetado/integracion y analizador de scripts.

## Pendiente al escribir este registro

- Revision final, push a main, verificar ejecucion Windows de Actions y publicar etiqueta v0.3.0.
- Comprobar assets de GitHub Release y hashes.
- Prueba real de WPF y aplicacion del playbook en Windows/VM. No declarar estable ni prometer FPS; no se ejecutaron ajustes en el equipo del usuario.

## Restricciones permanentes

No depender de Revision Tool. Conservar licencias de componentes reutilizados. No confundir validacion de sintaxis/empaquetado con pruebas de ajustes o interfaz en Windows. Los cambios generales heredados del playbook siguen siendo agresivos y no han sido auditados completamente en esta fase.
