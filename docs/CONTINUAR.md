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

## Publicacion recuperada y continuada (2026-11-11)

- Codigo completo subido a `main`: commit `c5243c69248332e670905fe37cc16f602e332165`.
- El arbol publicado coincide exactamente con el arbol local verificado: `60aa12d4cd34314e749cf992308bb40a859505f1`.
- GitHub Actions en Windows termino correctamente en `main`: https://github.com/maikimanuel/ErxckOS/actions/runs/43122835833.
- Etiqueta y publicacion preliminar creadas: https://github.com/maikimanuel/ErxckOS/releases/tag/v0.3.0.
- Compilacion de la etiqueta y carga de assets terminadas correctamente: https://github.com/maikimanuel/ErxckOS/actions/runs/43123009659.
- Assets publicados y descargados de nuevo para verificar sus hashes contra `SHA256SUMS.txt`:
  - `ErxckOS.apbx`: `37d0e3a4730709bb4d6eaefdf6c1a70d30b64533956297685b5e131a0bf0b376`.
  - `ErxckOS-Tool.zip`: `61cc1e39dd171cf1c7f8c97b6d4720f764fefb800dbf62c86a7fe2aa1d9ffef0`.
- El boton de actualizacion abre la pagina de publicaciones; no instala actualizaciones de forma silenciosa.

## Pendiente al escribir este registro

- 0.4.0 construida y comprobada en Windows: https://github.com/maikimanuel/ErxckOS/actions/runs/43126452001 (commit 82657b36e512015082281b7a4d5a528bb2deb303). Pasaron compilacion, instalacion/reinstalacion, migracion de accesos, diagnostico sin ejecutar tweaks, desinstalacion y empaquetado.
- Artefacto ErxckOS-build id 13902584892. El APBX se descargo y verifico: SHA256 5c444969ed3121604e9bd7f339304bfc3d421a8f86188505f891e28ae7430c2a. Contiene Executables/ErxckOS-Setup.exe (6041342 bytes), version 0.4.0 y llamada AME local silenciosa.
- Entrega privada: ErxckOS-v0.4.0.apbx. La etiqueta/publicacion publica v0.4.0 NO se ha creado: la revision automatica bloqueo la accion y requiere autorizacion explicita del usuario. No reintentar mediante otra via sin esa autorizacion.
- Prueba real de WPF y aplicacion del playbook en Windows/VM. No declarar estable ni prometer FPS; no se ejecutaron ajustes en el equipo del usuario.

## Restricciones permanentes

No depender de Revision Tool. Conservar licencias de componentes reutilizados. No confundir validacion de sintaxis/empaquetado con pruebas de ajustes o interfaz en Windows. Los cambios generales heredados del playbook siguen siendo agresivos y no han sido auditados completamente en esta fase.
