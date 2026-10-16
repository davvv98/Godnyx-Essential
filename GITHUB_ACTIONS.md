# Compilar Onyx Essential con GitHub Actions

El workflow está en `.github/workflows/onyx-release.yml`.
Utiliza el proyecto Onyx incluido en este ZIP, no el fork Duchamp sin adaptar.
Copia el CONTENIDO de `Godnyx-Essential-Onyx/` a la raíz de tu repositorio,
incluyendo la carpeta oculta `.github`. No subas el ZIP como un único archivo
esperando que GitHub lo descomprima.

## Ejecutar una compilación de prueba

1. Sube los archivos a tu repositorio y abre la pestaña Actions.
2. Selecciona `onyx-release`, pulsa Run workflow y elige la rama que contiene
   el código Onyx. El workflow compila el ref seleccionado; no fuerza duchamp.
3. Al terminar, descarga `Onyx-Essential-Poco-F7` en Artifacts. Incluye:
   `Onyx-Essential.apk`, `Onyx-Essential-KernelSU-Next-Magisk.zip` y SHA256SUMS.txt.

Una ejecución manual funciona sin secretos: genera una clave temporal. Las
compilaciones con claves distintas no son compatibles para actualizar el APK.
Para conservar compatibilidad, usa siempre el mismo keystore.

## Firma persistente y releases

En Settings > Secrets and variables > Actions > Repository secrets configura:

| Secret | Contenido |
| --- | --- |
| ONYX_KEYSTORE_BASE64 | Tu archivo JKS completo codificado en base64 |
| ONYX_KEY_ALIAS | Alias de tu clave; predeterminado: onyx-essential |
| ONYX_KEYSTORE_PASS | Contraseña del JKS; predeterminada para pruebas: android |
| ONYX_KEY_PASS | Contraseña de la clave; predeterminada: la del JKS |

Genera y conserva tu clave fuera del repositorio, por ejemplo:

```sh
keytool -genkeypair -storetype JKS -keystore onyx-release.jks \
  -alias onyx-essential -keyalg RSA -keysize 4096 -validity 9125 \
  -dname 'CN=Onyx Essential,O=Onyx Essential,C=MX'
base64 -w 0 onyx-release.jks > onyx-release-base64.txt
```

Introduce contraseñas cuando keytool las solicite. Copia el contenido del TXT
en el secret, y conserva el JKS y sus contraseñas para futuras actualizaciones.
No publiques el JKS ni el TXT. No se necesita un PAT: la publicación utiliza
el GITHUB_TOKEN del job con contents: write.

El push de un tag `v*` ejecuta el workflow y publica los archivos. Para tags se
exige ONYX_KEYSTORE_BASE64; así no se publica por accidente una release firmada
con una clave temporal.

```sh
git tag v1.18.5-onyx.1
git push origin v1.18.5-onyx.1
```

El nombre del tag identifica la release; no cambia automáticamente la versión
interna del APK, que sigue sincronizada con los archivos del proyecto.

## Cambios frente al workflow Duchamp

- Nombres de salida y release Onyx / POCO F7; variables internas RODIN_* y crate
  rodin-essential-daemon, que son los que realmente existen en este código.
- Flutter 3.47.7; motor compilado en otro checkout fijado a engine.version.
  No se mueve la revisión del SDK al sincronizar el motor.
- Caché del motor compilado, cabecera embedder.h y marca de revisión. Se evita
  una caché de todo el árbol de fuentes del motor, que puede ser muy grande.
- La sincronización falla después de tres intentos fallidos; no continúa con
  un checkout incompleto.
- Android API 36, build-tools 36.0.0 y NDK 27.2.12479018. Los scripts respetan
  esas versiones explícitas, aunque el runner tenga versiones superiores.
- El certificado esperado se obtiene del keystore configurado y se comprueba
  contra la firma del APK; no se desactiva la comprobación de certificado.
- Sin bundle AOSP: las políticas SELinux nativas Onyx aún no están validadas.
  Este workflow entrega la aplicación y el módulo root.

## Validación realizada

El YAML pasó actionlint 1.7.7, todas las secciones run pasaron bash -n, y pasaron
los contratos de módulo y de sincronización de versiones. Se revisó la sintaxis
Dart después de retirar dos controles Mali sin uso. No se ejecutó este job en
GitHub ni se generó un APK en esta sesión. El primer resultado real y sus logs
se obtendrán al ejecutar Actions en tu repositorio. Esto no amplía el soporte
de hardware indicado en README_ONYX.md.
