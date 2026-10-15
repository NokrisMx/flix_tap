# Flix Tap

Aplicación móvil desarrollada con Flutter para descubrir películas y consultar su información usando la API de [The Movie Database (TMDB)](https://www.themoviedb.org/). Permite explorar películas, buscar títulos, revisar detalles y guardar favoritos localmente.

## Funcionalidades

- Carruseles de películas en cartelera, próximas, populares y mejor calificadas.
- Búsqueda de películas.
- Exploración por categorías.
- Detalles de películas, reparto, personas y videos disponibles.
- Lista de favoritos persistida en el dispositivo.

## Requisitos

- Flutter y Dart compatibles con las versiones indicadas en [`pubspec.yaml`](pubspec.yaml).
- Una clave de API de TMDB.

## Configuración y ejecución

1. Clona el repositorio y entra en la carpeta del proyecto.
2. Copia `.env.template` como `.env` en la raíz del proyecto.
3. En `.env`, reemplaza el valor de `THE_MOVIEDB_KEY` por tu clave de API de TMDB:

   ```env
   THE_MOVIEDB_KEY=tu_clave_de_api
   ```

4. Instala las dependencias y ejecuta la aplicación:

   ```bash
   flutter pub get
   flutter run
   ```

La aplicación carga `.env` al iniciarse. No compartas ni publiques tu clave de API.

## Estructura del proyecto

- `lib/config/`: configuración de rutas, tema, base de datos y formatos.
- `lib/domain/`: entidades y contratos de repositorios y fuentes de datos.
- `lib/infrastructure/`: integración con TMDB, persistencia local y repositorios.
- `lib/presentation/`: pantallas, vistas, widgets y providers de estado.
- `assets/`: iconos, imágenes y tipografía.

## Compilar para Android

Genera un APK de lanzamiento:

```bash
flutter build apk --release
```

Genera un Android App Bundle:

```bash
flutter build appbundle --release
```

## Personalización de la app

Los siguientes comandos están disponibles desde la raíz del proyecto:

```bash
# Cambiar el identificador del paquete
dart run change_app_package_name:main com.ejemplo.nuevaapp

# Generar los iconos de la aplicación
dart run flutter_launcher_icons

# Generar el splash screen
dart run flutter_native_splash:create
```
