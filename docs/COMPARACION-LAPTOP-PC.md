# Revision directa de laptop / PC

Archivos: PickleOS.apbx aportado sin cifrado externo, Optiping(3).apbx y ErxckOS-v0.2.0.zip. Se abrieron los ZIP con la clave de empaquetado AME `malte`; no se ejecutaron los scripts.

## Hallazgos del playbook PickleOS

`Executables/laptop-desktop.bat` (152 lineas, SHA-256 `69eef59f7e85d84a4360d3dbea2b8a3e9a4c1a993987fa87eadcec7def756dd9`) es llamado desde `Configuration/custom.yml`.

- Consulta Win32_SystemEnclosure y toma solo el primer ChassisType. Si encuentra Win32_Battery elige laptop; sin bateria, valores hasta 7 son PC y todos los superiores son laptop.
- Ambas ramas importan PicklePlan.pow y ponen en 0 los tiempos de pantalla, suspension e hibernacion tanto en corriente como en bateria. El comentario de que asi es seguro en bateria no demuestra ese resultado.
- PC cambia servicios ACPI/bateria, desactiva BAM y compresion de memoria, aplica parametros USB/PCI y cambia power throttling.
- Laptop establece inicio de servicios seriales, WLAN y WMIACPI y mantiene power throttling habilitado. El comportamiento completo depende ademas del plan .pow y del resto del playbook.
- Anade al escritorio un menu para elegir planes de energia. Optiping contiene una estructura practicamente equivalente con otra marca.

La utilidad Pickle Utility(1).zip tambien tiene scripts legibles con una deteccion mas especifica mediante PCSystemType y varios tipos de chasis. Esa deteccion no es la misma que la del playbook recibido: no deben confundirse sus funciones.

## Comparacion

| Funcion | ErxckOS 0.2.0 | ErxckOS 0.3.0 |
| --- | --- | --- |
| Distinguir laptop / PC | No | Chasis portatil o PCSystemType Mobile; UPS sola no basta |
| Equipo desconocido | Aplica Ultra igualmente | Conserva el plan actual e informa |
| Laptop sin bateria instalada | Sin distincion | Se detecta por chasis/tipo |
| Politica en bateria | Depende de Ultra impuesto | Copia los valores del plan actual; no escribe DC |
| Hibernacion | Se desactiva globalmente | Se conserva su estado actual |
| Compresion de memoria | Desactivacion global | Se conserva; disponible como accion manual |
| Perfil manual | Tres planes generales | Automatico, Laptop y PC, ademas de los planes existentes |
| Actualizaciones | Repositorio sin configurar | maikimanuel/ErxckOS y publicaciones de prueba |

Implementacion propia de la idea de perfiles; no se redistribuye el playbook PickleOS ni se copian sus scripts. No se trasladan sus cambios masivos de ACPI/USB/PCI ni sus tiempos DC en cero. Los ajustes generales heredados de ErxckOS siguen necesitando pruebas en Windows; esta mejora no certifica todo el playbook.

Las configuraciones de bateria conservadas son las que existen al crear el perfil Laptop por primera vez. No pueden recuperar automaticamente valores anteriores a otras herramientas. Elegir un plan general manual (Equilibrado, Rendimiento o Ultra) cambia el esquema completo y no ofrece la misma conservacion que el perfil Laptop.

## Referencias de Windows

- [ChassisTypes / Win32_SystemEnclosure](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-systemenclosure)
- [Powercfg: esquemas y valores AC/DC](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)
