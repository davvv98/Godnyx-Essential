# Godnyx Essential — POCO F7 / Onyx — adaptación inicial

Basado en https://github.com/davvv98/Godnyx-Essential.
Este archivo describe la adaptación; la documentación histórica de Rodin/MediaTek
conservada en el proyecto no describe las capacidades de esta variante.

## Estado de entrega

Código fuente, NO APK ni módulo flasheable. No se ha instalado ni probado en un
POCO F7. Se verificaron tipos Rust para Android ARM64 (daemon y host), 96 pruebas
unitarias y dos pruebas de integración del daemon, los contratos de versión y
módulo y la sintaxis Dart mediante el formateador local. El análisis Flutter
completo fue bloqueado por la revisión automática del entorno al detectar un
intento de acceso al endpoint de metadatos de infraestructura. No se reintentó.
No se ha realizado un enlace final con NDK ni una compilación APK.

## Cambios

- Instalador: reconoce `onyx`, incluso con `ro.product.vendor.device=mivendor`.
- CPU: políticas 0, 2, 5 y 7; persistencia, restauración y controles por aplicación.
- Governors CPU: walt, migov, conservative, powersave, performance y schedutil;
  cada solicitud se valida contra la lista del kernel.
- CPU: los identificadores enteros de MHz usados por el protocolo se resuelven
  a los kHz exactos de la tabla. 364 identifica 364800 kHz, no 364000 kHz.
  La interfaz muestra MHz truncados; el valor escrito conserva los decimales.
  Si dos OPP producen el mismo identificador, la solicitud se rechaza.
- El máximo seleccionable proviene de scaling_available_frequencies: para
  policy7 la captura anuncia 2956800 kHz. No se inventa un OPP de 3206400 kHz
  solamente porque aparezca en cpuinfo_max_freq.
- GPU: KGSL /sys/class/kgsl/kgsl-3d0/devfreq; validación contra OPP reales,
  lectura de frecuencia/carga y escritura con readback y rollback de límites.
- Stock: captura y restaura los límites originales (264–873 MHz en la captura
  del dispositivo). Gaming: rango completo de la tabla (264–1150 MHz).
  Ahorro: máximo OPP <=510 MHz. Extremo: mínimo=máximo=OPP superior (1150 MHz).
  Un límite configurado no garantiza esa frecuencia instantánea: el driver y
  las protecciones térmicas siguen actuando.
- Governor GPU: msm-adreno-tz. Sin GED, sin políticas Mali ni cambios en
  cooling_device3, sconfig o PowerHAL de MediaTek.
- Xiaomi DisplayFeature AIDL se conserva. No se agrega Oplus Display.
  La presencia del servicio no prueba que cada ID de función funcione igual:
  color, temperatura, HDR y demás necesitan pruebas en el dispositivo.
- Protocolo onyx.1: host y daemon deben actualizarse juntos.
- Estado independiente en /data/adb/onyx-essential para el módulo.

## Funciones pendientes

- Touch: solo OEM. Los perfiles 240/480/resampling devuelven un error explícito;
  no se reutiliza la modificación de memoria THP de Rodin sin validar su layout.
- Carga: carga OEM y telemetría. Los perfiles de potencia de Rodin no se usan:
  no se reutilizan sus corrientes FCC ni se promete forzar 90 W.
- Bypass: el código requiere los nodos explícitos de soporte/estado del proyecto.
  No se observaron en la captura; debe aparecer como no compatible. No se
  interpreta charge_control_limit ni input_suspend como bypass.
- Integración nativa en ROM/SELinux: las políticas AOSP y los paquetes de
  integración de Rodin incluidos son material original, no una política Onyx
  validada. Para esta variante la ruta preparada es el módulo root.

## Compilación

Se necesita Linux, Flutter compatible con el proyecto, Rust con el target
`aarch64-linux-android`, Android SDK/build-tools y NDK. Conserva los requisitos
sobre el motor Flutter personalizado de la documentación del proyecto.

```sh
rustup target add aarch64-linux-android
cargo check --target aarch64-linux-android -p rodin-essential-daemon -p rodin-essential-host
cargo test -p rodin-essential-daemon
RODIN_BUILD_ONLY=1 bash build-and-install.sh
```

Para un ZIP del módulo firmado, usa una clave persistente configurada como
`RODIN_KEYSTORE` y ejecuta `bash tools/build-kernelsu-next-module.sh` después de
revisar los requisitos de firma del proyecto. No mezcles el APK antiguo con el
daemon nuevo. No uses los exportadores AOSP como si ya tuvieran SELinux Onyx.

`onyx.patch` contiene los cambios con respecto al commit indicado en
`BASE_COMMIT.txt`. `diagnostico_onyx_pendientes.sh` recopila información de touch
y carga en modo de solo lectura; no ejecuta lshal, que se quedó bloqueado en
la captura del teléfono.

## Correcciones tras la primera prueba real

Se corrige el nombre visible de la aplicación a Onyx Essential y se aplica
llvm-strip --strip-unneeded al motor Flutter antes de empaquetarlo. El job
reporta los tamaños antes/después. El tamaño final debe comprobarse en el APK
resultante: no se ha generado un APK nuevo aquí.

GPU/CPU/DisplayFeature siguen pendientes de diagnóstico del dispositivo. No
se atribuye el fallo a permisos, SELinux o HAL sin ver el error real.
`diagnostico_onyx_instalado.sh` recopila el snapshot, logs, contextos y nodos
sin modificar controles del dispositivo. Primero intentar GPU, CPU y color en
la app, después ejecutar el diagnóstico como root. Carga y touch permanecen
pendientes; este parche no los convierte en funciones implementadas.

## Corrección GPU + CPU: protocolo onyx.2

La escritura y su lectura efectiva se tratan por separado. Después de una
escritura aceptada y una lectura válida, una diferencia no revierte el perfil
ni elimina la solicitud guardada. Se conserva el valor solicitado y se muestra
el efectivo con estado de límites diferentes (driver/OEM). No se identifica
el propietario de la restricción solamente a partir de esa diferencia.

Errores de permisos, IO, lecturas inválidas, OPP inexistentes y persistencia
siguen siendo errores. Si una transacción falla, se intenta restaurar el rango
anterior; cualquier fallo en esa restauración también se informa.

CPU conserva los cuatro clústeres y la conversión a kHz exactos. cpu_freq_ack:
- 1: la lectura inicial coincide con la solicitud;
- 2: escritura aceptada con lectura efectiva distinta;
- 0: solicitud fallida;
- -1: sin resultado.
Los campos cpu_freq_drift indican si el estado efectivo posterior difiere.

GPU añade gpu_requested_min/gpu_requested_max y mantiene gpu_min_freq /
gpu_max_freq como lecturas efectivas. perf_verify_ok=1 solo indica coincidencia
al verificar; seleccionar un perfil no garantiza una frecuencia instantánea.
La app muestra ambas magnitudes. El índice thermal_pwrlevel se lee como
telemetría; no se modifica.

Se retiraron las escrituras periódicas de límites por divergencia. Se aplican
al pulsar Apply/seleccionar perfil, al cambiar controles por aplicación y en la
restauración de arranque acotada existente. No se promete recuperar por sí sola
la frecuencia cuando otro propietario restaura sus límites. Puede reenviarse
la solicitud desde la app. Los governors y otros controles conservan sus
rutas existentes.

Hay que instalar juntos APK y daemon nuevos: host y daemon usan onyx.2.
Las solicitudes guardadas anteriores se conservan. Esta corrección no agrega
funciones de carga/touch ni cambia DisplayFeature.

Validación: 101 pruebas unitarias + 2 integraciones del daemon; comprobación
Rust Android ARM64 para host y daemon; sintaxis Dart con el SDK fijado al motor
usado por Flutter 3.47.7; contratos del módulo, versión y watchdog. No se ha
compilado ni probado un APK nuevo en el teléfono en esta sesión.
