# ErxckOS 0.3.0: perfiles y publicaciones

Objetivo: comparar el comportamiento laptop/PC encontrado en los archivos aportados, implementar deteccion propia compartida entre app y playbook y publicar el proyecto completo en maikimanuel/ErxckOS.

Restricciones: marca ErxckOS, sin dependencia de Revision Tool, conservar licencias, no ejecutar ajustes del sistema durante la construccion, no declarar pruebas reales de Windows ni mejoras de FPS sin mediciones.

Enfoque: PowerShell 5.1/WPF existente, clasificacion explicita de chasis y PCSystemType; una bateria/UPS sola no implica laptop. Equipos desconocidos conservan su plan. Laptop duplica el plan actual para conservar valores DC/tapa; solo ajusta procesador en AC. Desktop usa un plan propio de rendimiento con fallback al actual si la plataforma no permite High Performance. Se conserva hibernacion en ambos.

Alternativas: copiar scripts de terceros propagaria cambios de servicios y dispositivos que no necesita esta funcion; usar solo Win32_Battery confundiria UPS con laptops. Se adopta una implementacion propia con pruebas de entradas.

- [ ] Parte 1: documentar evidencia, limites del archivo cifrado y comparacion.
- [ ] Parte 2: pruebas de clasificacion, plan de bateria conservado, errores y conexion app/playbook; implementar y verificar.
- [ ] Parte 3: configurar repositorio/version, integrar CI y publicaciones repetibles, construir y publicar prueba 0.3.0; comprobar assets y hashes.

Pruebas: tests/device-profile.tests.ps1 con CIM/powercfg sustituidos (sin tocar Windows), analizador PS de todos los scripts y unittest de paquetes. CI repite pruebas en Windows PowerShell 5.1. Riesgos revisados: UPS, bateria retirada, chasis de docking, CIM inaccesible, esquemas no disponibles, publicacion repetida/version distinta a etiqueta.

Progreso y decisiones: docs/CONTINUAR.md conserva estado para otro chat. Este trabajo esta autorizado por el pedido de continuar y terminar GitHub por partes.
