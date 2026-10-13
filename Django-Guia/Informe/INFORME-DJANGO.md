# Informe del proyecto Django

## ISS-00 — Entorno y proyecto Django

**Estado:** completada según las evidencias recibidas.

### Objetivo

Crear el entorno aislado y el proyecto Django `config`, sin modelos todavía.

### Paso 1. Creación del entorno virtual y del proyecto Django

Creé el entorno virtual, instalé Django 5.2.17, generé el proyecto `config` y guardé las dependencias en `requirements.txt`, siguiendo los comandos de la ISS:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install "Django==5.2.17"
django-admin startproject config .
python -m pip freeze > requirements.txt
python -m django --version
```

#### Evidencia EVI-00-01 y EVI-00-02 — Entorno y proyecto generados

![Entorno virtual, Django instalado y estructura del proyecto](Trazabilidad/ISS-00-EVI-00-01.png)

**Qué hice:** creé `.venv`, instalé Django 5.2.17 y generé el proyecto `config`.

**Retroalimentación:** la terminal muestra la instalación de Django 5.2.17 y el explorador muestra `.venv`, `config`, `manage.py` y `requirements.txt`.

**Lo que aprendí:** el entorno virtual aísla las dependencias del proyecto, y `django-admin startproject config .` crea la estructura inicial sin escribir `manage.py` a mano.

### Paso 2. Creación del archivo `.gitignore`

Creé `.gitignore` con las exclusiones indicadas en la ISS.

#### Evidencia complementaria — Archivo `.gitignore`

![Contenido y creación del archivo .gitignore](Trazabilidad/ISS-00-EVI-00-02.png)

**Qué hice:** agregué al archivo las carpetas y los archivos locales o generados que no deben incluirse en el repositorio.

**Retroalimentación:** la captura muestra el contenido de `.gitignore` y el comando de creación.

**Lo que aprendí:** `.gitignore` permite mantener fuera del repositorio elementos como el entorno virtual, archivos temporales y la base local.

### Paso 3. Verificación de versión y del proyecto

Ejecuté las verificaciones indicadas en la ISS:

```sh
python -m django --version
python manage.py check
```

#### Evidencia de verificación — Django 5.2.17 y resultado de `check`

![Versión de Django y comprobación del sistema](Trazabilidad/ISS-00-EVI-00-03.png)

**Qué hice:** comprobé la versión de Django y ejecuté la revisión del sistema del proyecto.

**Retroalimentación:** la terminal muestra la versión `5.2.17` y que la comprobación terminó sin problemas.

**Lo que aprendí:** estas comprobaciones confirman que la versión requerida está instalada y que la configuración inicial pasa la revisión de Django.

### Conclusión

Completé la ISS-00 y obtuve el entorno virtual, el proyecto `config` y el archivo de dependencias. Según las capturas, se instalaron Django 5.2.17 y la revisión del sistema no reportó problemas. La estructura corresponde al proyecto inicial sin modelos de negocio; por ello, los criterios de aceptación de esta unidad quedan en PASS.

## ISS-01 — Settings y selección del motor

**Estado:** completada según las evidencias recibidas.

### Objetivo

Elegir un solo motor por proceso desde `.env`, sin escribir SQL.

### Paso 1. Activación del entorno virtual y confirmación del intérprete

Ejecuté los comandos iniciales de la ISS:

```sh
source .venv/bin/activate
which python
```

#### Evidencia EVI-01-01 — Intérprete del entorno virtual

![Activación del entorno y ruta del intérprete de Python](Trazabilidad/ISS-01-EVI-01-01.png)

**Qué hice:** activé `.venv` y comprobé la ruta del intérprete.

**Retroalimentación:** la salida de `which python` apunta al ejecutable dentro de `.venv`.

**Lo que aprendí:** debo instalar los paquetes con el intérprete del entorno para que Django pueda utilizarlos.

### Paso 2. Instalación de herramientas del sistema y paquetes Python

Instalé las herramientas de compilación indicadas y los paquetes de la ISS dentro de `.venv`; al finalizar, guardé las dependencias:

```sh
sudo apt install build-essential pkg-config default-libmysqlclient-dev python3.12-dev
python -m pip install "python-dotenv==1.2.3"
python -m pip install "psycopg[binary]==3.3.6"
python -m pip install "mysqlclient==2.3.0"
python -m pip install "mssql-django==2.0.0"
python -m pip install "oracledb==26.0.1"
python -m pip freeze > requirements.txt
```

#### Evidencia EVI-01-02 — Herramientas del sistema

![Instalación de las herramientas de compilación y bibliotecas de MySQL](Trazabilidad/ISS-01-EVI-01-02.png)

**Qué hice:** instalé `build-essential`, `pkg-config`, `default-libmysqlclient-dev` y `python3.12-dev`.

**Retroalimentación:** la terminal indica que las herramientas estaban instaladas o quedaron disponibles sin errores.

**Lo que aprendí:** `mysqlclient` requiere herramientas y cabeceras del sistema además de la instalación del paquete Python.

#### Evidencias EVI-01-03 y EVI-01-04 — Drivers y dependencias Python

![Instalación de los paquetes Python requeridos](Trazabilidad/ISS-01-EVI-01-03.png)

**Qué hice:** instalé las dependencias solicitadas para cargar `.env` y utilizar los motores PostgreSQL, MySQL, SQL Server y Oracle.

**Retroalimentación:** la terminal muestra la resolución y descarga de dependencias, seguida por la finalización de las instalaciones.

**Lo que aprendí:** Django necesita drivers separados para conectarse a los motores de base de datos que admite la configuración del proyecto.

![Finalización de la instalación de oracledb](Trazabilidad/ISS-01-EVI-01-04.png)

**Qué hice:** completé la instalación de `oracledb` después de instalar el resto de las dependencias.

**Retroalimentación:** pip muestra que `oracledb==26.0.1` se instaló correctamente.

**Lo que aprendí:** dejar fijadas las versiones y guardarlas en `requirements.txt` ayuda a reproducir el entorno.

### Paso 3. Preparación del paquete de settings

Ejecuté los comandos de la guía para retirar el archivo generado y crear el directorio del paquete:

```sh
rm config/settings.py
mkdir -p config/settings
```

#### Evidencia EVI-01-05 — Preparación de `config/settings`

![Eliminación de settings.py y creación del directorio settings](Trazabilidad/ISS-01-EVI-01-05.png)

**Qué hice:** eliminé `config/settings.py` y creé el directorio `config/settings`.

**Retroalimentación:** la captura muestra la ejecución de ambos comandos sin errores.

**Lo que aprendí:** la configuración pasa de ser un solo archivo a un paquete llamado `config.settings`.

### Paso 4. Creación de `.env.example` y `.env`

Creé la plantilla de variables y la copié al archivo local de entorno, siguiendo el bloque de la ISS.

#### Evidencia EVI-01-06 — Plantilla `.env.example`

![Creación de .env.example y copia a .env](Trazabilidad/ISS-01-EVI-01-06.png)

**Qué hice:** escribí la plantilla con las variables de Django y las variables separadas para cada motor, y luego ejecuté `cp .env.example .env`.

**Retroalimentación:** la salida muestra las variables de la plantilla y la copia al archivo `.env`.

**Lo que aprendí:** `.env.example` documenta qué valores requiere el proyecto; `.env` es el archivo local que utiliza el proceso y no se versiona.

### Paso 5. Generación de la clave y selección del motor

Generé la clave secreta mediante el comando de la ISS y completé `.env` para el motor elegido.

#### Evidencia EVI-01-07 — Generación de `DJANGO_SECRET_KEY`

![Generación de una clave secreta con Django; el valor se ocultó en la copia versionada](Trazabilidad/ISS-01-EVI-01-07-redactada.png)

**Qué hice:** generé una clave usando `get_random_secret_key` para incorporarla a `.env`.

**Retroalimentación:** la captura original muestra que Django produjo una clave. En la copia incorporada al informe se ocultó el valor para no exponerlo.

**Lo que aprendí:** `DJANGO_SECRET_KEY` debe tener un valor para que settings pueda iniciar.

#### Evidencia EVI-01-11 — Variables del entorno y `DB_ENGINE`

![Archivo .env con valores sensibles ocultos en la copia versionada](Trazabilidad/ISS-01-EVI-01-11-redactada.png)

**Qué hice:** configuré `DB_ENGINE=mysql` y completé las variables de conexión de los motores en `.env`.

**Retroalimentación:** la captura original muestra el motor activo MySQL y sus variables de conexión. En la copia incorporada al informe se ocultaron los valores sensibles para no exponerlos.

**Lo que aprendí:** el bloque de variables que se completa debe corresponder al motor elegido en `DB_ENGINE`.

### Paso 6. Creación de `config/database.py`

Creé `config/database.py` con el código de la ISS para validar `DB_ENGINE`, exigir variables requeridas y construir una única configuración `DATABASES["default"]`.

#### Evidencia EVI-01-08 — Selector de motor de base de datos

![Código de config/database.py](Trazabilidad/ISS-01-EVI-01-08.png)

**Qué hice:** implementé la selección entre PostgreSQL, MySQL, SQL Server y Oracle.

**Retroalimentación:** el código mostrado comprueba el motor y define la configuración del alias `default`.

**Lo que aprendí:** aunque existan configuraciones para varios motores, el proceso utiliza un único motor activo.

### Paso 7. Creación del paquete de settings

Escribí `config/settings/__init__.py` con el bloque de configuración de la ISS: carga de `.env`, clave, aplicaciones instaladas, base de datos y opciones generales.

#### Evidencia EVI-01-09 — Configuración principal de Django

![Código del paquete config.settings](Trazabilidad/ISS-01-EVI-01-09.png)

**Qué hice:** trasladé la configuración del proyecto al paquete `config.settings` y conecté los settings con `database_from_environ`.

**Retroalimentación:** el archivo muestra la lectura de `.env`, la validación de la clave y la configuración de Django.

**Lo que aprendí:** settings reúne la configuración necesaria para inicializar el proyecto y delega la selección del motor al módulo de base de datos.

### Paso 8. Creación de `config/project_python.py`

Creé el módulo de la ISS que vuelve a lanzar el comando con `.venv/bin/python` cuando hace falta.

#### Evidencia EVI-01-10 — Intérprete del proyecto

![Código de config/project_python.py](Trazabilidad/ISS-01-EVI-01-10.png)

**Qué hice:** escribí la función `use_project_python()` según la guía.

**Retroalimentación:** el archivo contiene la ruta al Python del entorno y la comparación con `sys.prefix`.

**Lo que aprendí:** el proyecto puede redirigir sus comandos al intérprete donde están instaladas sus dependencias.

### Paso 9. Ajustes de `manage.py`, `wsgi.py` y `asgi.py`

Ajusté los tres puntos de entrada para que utilicen el código del entorno y carguen `.env` como prescribe la ISS.

#### Evidencia EVI-01-12 — Ajuste de `manage.py`

![Código actualizado de manage.py](Trazabilidad/ISS-01-EVI-01-12.png)

**Qué hice:** agregué la ruta raíz al `sys.path`, llamé a `use_project_python()` y añadí `load_dotenv()` dentro de `main()`.

**Retroalimentación:** la captura muestra la llamada al helper y la carga de variables antes de ejecutar comandos de Django.

**Lo que aprendí:** `manage.py` necesita cargar las variables del entorno antes de ejecutar las tareas administrativas.

#### Evidencia EVI-01-13 — Ajuste de `wsgi.py`

![Código actualizado de config/wsgi.py](Trazabilidad/ISS-01-EVI-01-13.png)

**Qué hice:** añadí `load_dotenv()` antes de establecer `DJANGO_SETTINGS_MODULE` e inicializar la aplicación WSGI.

**Retroalimentación:** la captura muestra la lectura del entorno en el punto de entrada WSGI.

**Lo que aprendí:** el proceso WSGI también debe cargar `.env` para disponer de las variables al iniciar Django.

#### Evidencia EVI-01-14 — Ajuste de `asgi.py`

![Código actualizado de config/asgi.py](Trazabilidad/ISS-01-EVI-01-14.png)

**Qué hice:** apliqué el mismo patrón de carga de `.env` antes de inicializar la aplicación ASGI.

**Retroalimentación:** la captura muestra `load_dotenv()` y la inicialización de ASGI.

**Lo que aprendí:** los dos puntos de entrada del proyecto deben utilizar las variables de entorno.

### Paso 10. Verificación y arranque

Ejecuté los comandos de verificación indicados:

```sh
python manage.py check
python manage.py runserver
```

#### Evidencia EVI-01-15 — Resultado de `check` y servidor en funcionamiento

![Resultado de check, servidor de desarrollo y página de Django](Trazabilidad/ISS-01-EVI-01-15.png)

**Qué hice:** ejecuté `check`, inicié el servidor y abrí la página local de Django.

**Retroalimentación:** la terminal muestra que la comprobación terminó sin problemas y que el servidor atendió una solicitud; el navegador muestra la página inicial de Django.

**Lo que aprendí:** con los settings y las variables del entorno definidos, el proyecto puede iniciar el servidor de desarrollo.

### Conclusión

Completé la ISS-01 configurando la selección de un único motor desde `.env`, creando el paquete de settings y ajustando los puntos de entrada. La evidencia del paso final muestra que `check` terminó sin problemas y que la página inicial de Django respondió. Los criterios de selección de cada motor requieren las pruebas descritas en la ruta; el GATE queda pendiente hasta que esas pruebas se ejecuten en la unidad indicada.
