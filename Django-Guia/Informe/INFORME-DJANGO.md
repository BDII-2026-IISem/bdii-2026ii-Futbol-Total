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

## ISS-02 — Apps client, product y sale

**Estado:** completada según las evidencias recibidas.

### Objetivo

Crear las tres apps de negocio con la CLI y registrarlas dentro del paquete `apps`, todavía sin escribir modelos.

### Paso 1. Creación de las apps y del paquete `apps`

Creé las tres apps de negocio usando `startapp` y preparé el paquete `apps`:

```sh
mkdir -p apps/client apps/product apps/sale
python manage.py startapp client apps/client
python manage.py startapp product apps/product
python manage.py startapp sale apps/sale
mkdir -p apps
cat > apps/__init__.py <<'EOF'
EOF
```

#### Evidencia EVI-02-01 — Estructura de las tres apps

![Paquete apps con client, product y sale](Trazabilidad/ISS-02-EVI-02-01.png)

**Qué hice:** creé las carpetas `client`, `product` y `sale` dentro de `apps/`, además de `apps/__init__.py`.

**Retroalimentación:** el explorador muestra las tres apps y el archivo de inicialización del paquete.

**Lo que aprendí:** `startapp` genera la estructura estándar de cada app, y `apps/__init__.py` permite importar el paquete común.

### Paso 2. Configuración de `AppConfig`

Actualicé el `name` y el `label` de cada aplicación, conservando los nombres de clase indicados por la guía.

#### Evidencia EVI-02-02 — `ClientConfig`

![Configuración de ClientConfig](Trazabilidad/ISS-02-EVI-02-02.png)

**Qué hice:** configuré `name = "apps.client"` y `label = "client"`.

**Retroalimentación:** los valores aparecen en `ClientConfig` y se conserva el nombre de clase.

**Lo que aprendí:** `name` representa la ruta importable de la app y `label` mantiene el nombre del dominio.

#### Evidencia EVI-02-03 — `ProductConfig`

![Configuración de ProductConfig](Trazabilidad/ISS-02-EVI-02-03.png)

**Qué hice:** configuré `name = "apps.product"` y `label = "product"`.

**Retroalimentación:** los valores aparecen en `ProductConfig`.

**Lo que aprendí:** cada app alojada en `apps/` necesita su ruta completa en `name`.

#### Evidencia EVI-02-04 — `SaleConfig`

![Configuración de SaleConfig](Trazabilidad/ISS-02-EVI-02-04.png)

**Qué hice:** configuré `name = "apps.sale"` y `label = "sale"`.

**Retroalimentación:** los valores aparecen en `SaleConfig` y la clase conserva el nombre indicado.

**Lo que aprendí:** las tres apps usan el mismo patrón de configuración y cada una conserva su label de dominio.

### Paso 3. Registro de las apps y ejecución de `check`

Agregué las tres clases a `INSTALLED_APPS` y ejecuté la verificación indicada:

```sh
python manage.py check
```

#### Evidencia — Registro de las apps en settings

![Las apps client, product y sale registradas en INSTALLED_APPS](Trazabilidad/ISS-02-EVI-02-05.png)

**Qué hice:** agregué `ClientConfig`, `ProductConfig` y `SaleConfig` a `config/settings/__init__.py`.

**Retroalimentación:** la lista muestra las tres rutas de configuración registradas.

**Lo que aprendí:** Django debe cargar las apps desde `INSTALLED_APPS`, además de que sus directorios existan.

#### Evidencia EVI-02-01 — Resultado de `python manage.py check`

![Resultado de System check](Trazabilidad/ISS-02-EVI-02-06.png)

**Qué hice:** ejecuté el comando `python manage.py check`.

**Retroalimentación:** la terminal responde `System check identified no issues (0 silenced)`.

**Lo que aprendí:** esta comprobación detecta problemas de configuración de Django, incluidos errores al cargar las apps.

#### Evidencia complementaria — Settings y ausencia de modelos de negocio

![Settings del proyecto y estado de las apps en esta unidad](Trazabilidad/ISS-02-EVI-02-07.png)

**Qué hice:** documenté la vista adicional de settings y el estado del proyecto después del registro de las apps.

**Retroalimentación:** la captura complementa la revisión del settings; esta unidad no añade modelos de negocio.

**Lo que aprendí:** la ISS-02 prepara las apps para las unidades siguientes y deja la creación de modelos para cuando corresponda.

### Conclusión

Creé y registré `client`, `product` y `sale`, configuré sus nombres de paquete y labels, y ejecuté `python manage.py check`. La salida mostrada no reporta problemas. En esta unidad todavía no se escribieron modelos de negocio; según las evidencias recibidas, el GATE de ISS-02 queda en PASS.

## ISS-03 — Custom User antes de la primera migración

**Estado:** completé parcialmente esta ISS. Me quedan pendientes las pruebas del flujo de autenticación y confirmar todos los criterios de aceptación.

### Objetivo

Definir el usuario de StoreLab sobre `django.contrib.auth` y fijar `AUTH_USER_MODEL` antes de migrar.

### Paso 1. Creación de `apps/common` y `RecordStatus`

Creé el paquete común y definí `RecordStatus` con los estados `ACTIVE` e `INACTIVE`, según el bloque de la guía.

#### Evidencia — Paquete común y estados del registro

![Creación de apps/common y RecordStatus](Trazabilidad/ISS-03-EVI-03-01.png)

**Qué hice:** creé `apps/common/__init__.py` y escribí `apps/common/status.py` con las opciones de estado.

**Retroalimentación:** la terminal muestra la escritura de ambos archivos y el explorador muestra el paquete y `status.py`.

**Lo que aprendí:** puedo centralizar opciones compartidas para que el usuario y las apps de negocio utilicen la misma definición de estado.

### Paso 2. Creación de la app `security`

Creé el directorio de destino y generé la app de seguridad mediante `startapp`.

#### Evidencia — Estructura inicial de `apps/security`

![Creación de la app security con startapp](Trazabilidad/ISS-03-EVI-03-02.png)

**Qué hice:** ejecuté los comandos de la ISS para crear `apps/security` con la CLI de Django.

**Retroalimentación:** la terminal muestra `python manage.py startapp security apps/security` y el explorador muestra los archivos iniciales de la aplicación.

**Lo que aprendí:** `startapp` genera la estructura estándar de la aplicación dentro del directorio de destino creado previamente.

### Paso 3. Configuración de `SecurityConfig`

Actualicé `apps/security/apps.py` con el nombre importable y el label indicados en la guía.

#### Evidencia — `SecurityConfig`

![Configuración de SecurityConfig](Trazabilidad/ISS-03-EVI-03-03.png)

**Qué hice:** configuré `name = "apps.security"` y `label = "security"`, manteniendo la clase `SecurityConfig`.

**Retroalimentación:** la captura muestra los valores en el archivo de configuración de la app.

**Lo que aprendí:** `name` debe reflejar la ubicación de la app dentro del paquete `apps`, mientras que el label identifica a la app en Django.

### Paso 4. Definición del usuario personalizado

Elegí `AbstractUser`, como propone la ISS, y escribí el modelo `User`, su manager, los campos de estado y fechas, la restricción y el comportamiento de `save()`.

#### Evidencia — Modelo `User` y `StoreUserManager`

![Modelo de usuario personalizado y manager](Trazabilidad/ISS-03-EVI-03-04.png)

**Qué hice:** escribí el código del modelo y del manager conforme al bloque de la guía.

**Retroalimentación:** la captura muestra el uso de `AbstractUser`, los valores de estado predeterminados, el email único, las fechas y la restricción `users_status_valid`.

**Lo que aprendí:** `AbstractUser` aporta la funcionalidad de autenticación de Django, y el manager permite definir estados iniciales distintos para usuarios normales y superusuarios.

### Paso 5. Registro de security y declaración del usuario de Django

Agregué `SecurityConfig` antes de las apps de negocio y declaré `AUTH_USER_MODEL = "security.User"` antes de ejecutar las migraciones.

#### Evidencia — `INSTALLED_APPS` y `AUTH_USER_MODEL`

![Registro de SecurityConfig y declaración de AUTH_USER_MODEL](Trazabilidad/ISS-03-EVI-03-05.png)

**Qué hice:** registré la app de seguridad en settings y declaré el modelo de usuario personalizado.

**Retroalimentación:** la captura muestra `apps.security.apps.SecurityConfig` delante de las apps de negocio y la asignación de `AUTH_USER_MODEL`.

**Lo que aprendí:** Django debe conocer el modelo personalizado antes de la primera migración para crear el esquema de autenticación correcto desde el inicio.

### Paso 6. Pruebas de selección de base de datos

Reemplacé el archivo de pruebas de la app con `DatabaseSelectionTests`, tal como indica la ISS.

#### Evidencia — `DatabaseSelectionTests`

![Pruebas de selección de motores en apps/security/tests.py](Trazabilidad/ISS-03-EVI-03-06.png)

**Qué hice:** escribí pruebas para los cuatro motores, el motor inválido y la ausencia de una variable obligatoria.

**Retroalimentación:** el archivo muestra los casos de prueba y sus valores de entorno de ejemplo.

**Lo que aprendí:** con `SimpleTestCase` puedo verificar la configuración de motores sin abrir una conexión a cada base de datos.

### Paso 7. Generación de migración y ejecución de pruebas

Ejecuté los comandos de la ISS para generar la migración de seguridad, aplicar migraciones y ejecutar `DatabaseSelectionTests`.

#### Evidencia — Migración inicial y seis pruebas PASS

![Migración security.0001_initial y resultado de DatabaseSelectionTests](Trazabilidad/ISS-03-EVI-03-07.png)

**Qué hice:** ejecuté `makemigrations security`, `migrate` y `python manage.py test apps.security.tests.DatabaseSelectionTests`.

**Retroalimentación:** la salida muestra la creación de `security.0001_initial`, seis pruebas ejecutadas y el resultado `OK`, junto con `System check identified no issues`. Esta captura no demuestra las pruebas de login de `AuthFlowTests` ni identifica por sí sola el motor de base de datos utilizado.

**Lo que aprendí:** la migración del usuario personalizado debe generarse después de configurar `AUTH_USER_MODEL`, y las pruebas de selección comprueban la configuración sin sustituir las pruebas del flujo de autenticación.

### Conclusión

Avancé con la creación de `RecordStatus`, la app `security`, el modelo de usuario personalizado, su registro en settings y las pruebas de selección de motores. La evidencia final muestra seis pruebas de `DatabaseSelectionTests` aprobadas y la migración inicial generada. Dejo el estado como parcialmente completado: la guía especifica `AuthFlowTests` para verificar los criterios de login, y esas pruebas no aparecen en las capturas recibidas. Por ello, todavía no marco el GATE completo como PASS.

## ISS-04 — Modelo Client

**Estado:** completé parcialmente esta ISS. Me queda pendiente documentar las verificaciones del cliente y confirmar los criterios de aceptación.

### Objetivo

Persistir compradores con el diccionario de `clients`.

### Paso 1. Creación de los modelos abstractos compartidos

Creé `apps/common/models.py` con `TimeStampedModel` para las fechas y `StoreLabModel` para el estado y la restricción reutilizable, siguiendo el bloque de la ISS.

#### Evidencia — Modelos base `TimeStampedModel` y `StoreLabModel`

![Modelos abstractos compartidos en apps/common/models.py](Trazabilidad/ISS-04-EVI-04-01.png)

**Qué hice:** definí las clases abstractas y el método `status_constraint()` que produce la restricción de estados permitidos.

**Retroalimentación:** la captura muestra los campos `created_at`, `updated_at`, `status` y el constraint construido a partir de `RecordStatus`.

**Lo que aprendí:** las clases abstractas permiten compartir fechas y estado entre modelos sin crear una tabla propia para la clase base.

### Paso 2. Creación del modelo `Client`

Reescribí `apps/client/models.py` con los campos del comprador, las reglas de validación, la tabla física `clients` y la normalización del correo electrónico.

#### Evidencia — Modelo `Client`

![Modelo Client en apps/client/models.py](Trazabilidad/ISS-04-EVI-04-02.png)

**Qué hice:** definí `Client` como descendiente de `StoreLabModel`, agregué nombre, dirección, teléfono y correo, establecí `db_table = "clients"` y convertí el email a minúsculas al guardar.

**Retroalimentación:** el código de la captura muestra el validador de longitud mínima para el nombre, los campos opcionales y la unicidad del correo.

**Lo que aprendí:** las reglas del modelo y la clase base compartida mantienen consistentes los datos persistidos y preparan la validación que usarán interfaces posteriores.

### Paso 3. Generación y aplicación de la migración

Ejecuté los comandos indicados para crear la migración de `client` y aplicar las migraciones:

```sh
python manage.py makemigrations client
python manage.py migrate
```

#### Evidencia EVI-04-01 — Migración inicial de `client`

![Creación de client.0001_initial y salida de migrate](Trazabilidad/ISS-04-EVI-04-03.png)

**Qué hice:** generé `apps/client/migrations/0001_initial.py` y ejecuté el comando de migración.

**Retroalimentación:** la terminal muestra la creación de la migración `client.0001_initial` con el modelo `Client`; después, `migrate` informa que no hay migraciones pendientes.

**Lo que aprendí:** Django genera la migración a partir del modelo y registra qué migraciones quedan por aplicar en la base configurada.

### Verificaciones pendientes

La ISS indica crear un cliente en el shell y observar `status`, `created_at` y el rechazo de un email repetido. Esa ejecución todavía no aparece en las capturas recibidas. La prueba HTTP llega en ISS-08 y `ClientApiTests` se menciona como verificación posterior; no afirmo que estas pruebas hayan pasado con la evidencia actual.

### Conclusión

Creé los modelos abstractos reutilizables, definí `Client` y generé su migración inicial. La captura muestra que no quedaron migraciones pendientes, pero aún no tengo evidencia de la creación manual del cliente ni de las comprobaciones de unicidad y longitud. Por eso dejo la ISS-04 parcialmente completada y no marco su GATE como PASS.

## ISS-05 — ProductType y Product

**Estado:** completé parcialmente esta ISS. Tengo evidencia de la definición de los modelos y de la migración; me faltan las pruebas requeridas para confirmar el GATE.

### Objetivo

Modelar el catálogo y la integridad `ProductType 1 → N Product`.

### Paso 1. Definición de `ProductType` y `Product`

Reescribí `apps/product/models.py` con los dos modelos de catálogo y la relación protegida entre ellos.

#### Evidencia — Modelos y migración de producto

![Modelos ProductType y Product junto con la migración](Trazabilidad/ISS-05-EVI-05-01.png)

**Qué hice:** definí `ProductType` y `Product`, los campos de catálogo, precio y stock, y la clave foránea `product_type` con `on_delete=models.RESTRICT`. Después ejecuté los comandos de migración indicados en la guía:

```sh
python manage.py makemigrations product
python manage.py migrate
```

**Retroalimentación:** la captura muestra el código de ambos modelos y la salida con la creación de `product.0001_initial` y su aplicación.

**Lo que aprendí:** el detalle de la relación se conserva mediante una FK explícita; `RESTRICT` evita eliminar un tipo de producto que esté siendo referenciado.

### Verificaciones pendientes

La captura no muestra la ejecución de `ProductApiTests.test_default_status_and_type_restriction` ni `test_duplicate_product_name`. Por eso todavía no confirmo mediante pruebas el rechazo al borrar un tipo referenciado, el nombre duplicado ni los valores por defecto.

### Conclusión

Definí los modelos `ProductType` y `Product` y generé y apliqué la migración inicial. Me falta evidencia de las pruebas de restricción, unicidad y valores predeterminados, así que dejo la ISS-05 parcialmente completada y el GATE pendiente.

## ISS-06 — Sale y ProductSale

**Estado:** en progreso. Generé la migración de `sale`, pero `migrate` quedó bloqueado por una incompatibilidad en la tabla `clients`.

### Objetivo

Representar la venta y su detalle con precio histórico, sin sustituir el detalle por una relación muchos-a-muchos simple.

### Paso 1. Creación del manager de ventas

Creé `apps/sale/managers.py` con el `SaleQuerySet` y el `SaleManager` vacíos, tal como indica esta ISS.

#### Evidencia — `SaleQuerySet` y `SaleManager`

![Creación de apps/sale/managers.py](Trazabilidad/ISS-06-EVI-06-01.png)

**Qué hice:** declaré el queryset y el manager que utilizará el modelo `Sale`; todavía no agregué el método `register`, que corresponde a ISS-11.

**Retroalimentación:** la captura muestra las dos clases generadas con `pass`, de acuerdo con el alcance de esta unidad.

**Lo que aprendí:** puedo preparar el manager para el modelo sin adelantar operaciones transaccionales que la guía reserva para una ISS posterior.

### Paso 2. Creación de `Sale` y `ProductSale` y generación de migración

Escribí los modelos de venta y detalle siguiendo el bloque de ISS-06 y ejecuté:

```sh
python manage.py makemigrations sale
python manage.py migrate
```

#### Evidencia — Error al aplicar `sale.0001_initial`

![La migración sale.0001_initial falla al crear la clave foránea de sales hacia clients](Trazabilidad/ISS-06-EVI-06-02.png)

**Qué hice:** generé `sale.0001_initial` y traté de aplicar las migraciones.

**Retroalimentación:** Django generó la migración con los modelos `Sale` y `ProductSale`, pero MySQL detuvo su aplicación con el error 3734: no encuentra la columna `id` en la tabla referenciada `clients` para crear la clave foránea `sales_client_id_32ab12f6_fk_clients_id`. Por tanto, la migración de `sale` no quedó confirmada como aplicada.

**Lo que aprendí:** las claves foráneas de MySQL requieren que la columna referenciada exista en la tabla real y sea compatible con la clave primaria que declara el modelo.

### Solución del error

La causa fue que la base de datos ya tenía tablas creadas. Borré y volví a crear la base de datos para dejarla limpia y permitir que Django construyera las tablas a partir de las migraciones del proyecto.

**Qué hice:** eliminé la base de datos anterior, que ya contenía tablas, y creé nuevamente la base. Después volví a ejecutar `migrate`.

**Retroalimentación:** la captura posterior muestra `Applying sale.0001_initial... OK`, por lo que la migración se aplicó en la base recién creada.

**Lo que aprendí:** las tablas preexistentes pueden no coincidir con el esquema que espera el estado actual de las migraciones. Al recrear la base, Django pudo construir desde cero las tablas y claves foráneas definidas por el proyecto.

### Paso 3. Aplicación exitosa de la migración

Después de recrear la base de datos, ejecuté nuevamente:

```sh
python manage.py migrate
```

#### Evidencia — `sale.0001_initial` aplicada

![Migraciones aplicadas correctamente, incluida sale.0001_initial](Trazabilidad/ISS-06-EVI-06-03.png)

**Qué hice:** apliqué las migraciones del proyecto sobre la base de datos recién creada.

**Retroalimentación:** la terminal muestra que las migraciones se aplicaron y que `sale.0001_initial` terminó con `OK`.

**Lo que aprendí:** después de iniciar una base limpia, las migraciones pueden crear en orden las tablas y sus claves foráneas según los modelos del proyecto.

### Estado y verificaciones pendientes

La migración de `sale` quedó aplicada. Aún me falta la verificación del precio histórico indicada por la ISS; por ello, no marco el GATE completo como PASS.

### Conclusión

Primero encontré el error de clave foránea porque la base ya tenía tablas creadas. Borré y creé de nuevo la base, volví a ejecutar `migrate` y la captura confirma que `sale.0001_initial` se aplicó correctamente. Me queda pendiente la prueba de precio histórico para completar las verificaciones de ISS-06.

## ISS-07 — Serializers y JSON camelCase

**Estado:** completé la instalación de dependencias, la configuración de DRF y los serializers; me quedan pendientes las pruebas de esta ISS.

### Objetivo

Traducir modelos a JSON sin renombrar los campos Python.

### Paso 1. Instalación de dependencias de la API

Instalé Django REST Framework, el renderer/parser camelCase y CORS con los comandos de la guía:

```sh
source .venv/bin/activate
python -m pip install "djangorestframework==3.17.2" "djangorestframework-camel-case==1.4.2" "django-cors-headers==4.9.0"
python -m pip freeze > requirements.txt
```

#### Evidencia — Dependencias instaladas y apps registradas

![Instalación de dependencias API y registro de rest_framework y corsheaders](Trazabilidad/ISS-07-EVI-07-01.png)

**Qué hice:** instalé los tres paquetes indicados y preparé su registro en `INSTALLED_APPS`.

**Retroalimentación:** la terminal muestra la instalación exitosa de Django REST Framework, camel-case y CORS; el settings visible muestra `rest_framework` y `corsheaders`.

**Lo que aprendí:** los serializers y el renderer/parsers pertenecen a dependencias adicionales a Django y se registran en la configuración para usarlos en la API.

### Paso 2. Configuración de CORS y REST Framework

Configuré `CORS_ALLOW_ALL_ORIGINS` y las clases de permisos, renderers, parsers y paginación según la ISS.

#### Evidencia — `REST_FRAMEWORK` y CORS

![Configuración de CORS, renderers y parsers camelCase](Trazabilidad/ISS-07-EVI-07-02.png)

**Qué hice:** añadí la configuración de CORS y definí los renderers y parsers camelCase de REST Framework.

**Retroalimentación:** la captura muestra la configuración `AllowAny`, el renderer JSON camelCase, sus parsers y `DEFAULT_PAGINATION_CLASS = None`.

**Lo que aprendí:** la conversión camelCase se configura en el borde HTTP; los nombres de los campos Python y de la base de datos se mantienen en snake_case.

### Paso 3. Creación de `ClientSerializer`

Creé `apps/client/serializers.py` con los campos expuestos, reglas de lectura y validación del correo y de los campos opcionales.

#### Evidencia — Serializer de clientes

![ClientSerializer y validación de email](Trazabilidad/ISS-07-EVI-07-03.png)

**Qué hice:** definí `ClientSerializer` con lista explícita de campos, campos de solo lectura y validaciones para nombre, email, dirección y teléfono.

**Retroalimentación:** el código muestra que el email vacío se normaliza a `None` y el email escrito se guarda en minúsculas.

**Lo que aprendí:** la lista explícita de campos controla lo que expone la API y las validaciones del serializer preparan los datos antes de persistirlos.

### Paso 4. Creación de serializers para productos

Creé `ProductTypeSerializer` y `ProductSerializer`, exponiendo la relación escribible `product_type_id` y el nombre de tipo solo como lectura.

#### Evidencia — Serializers de tipos y productos

![ProductTypeSerializer y ProductSerializer](Trazabilidad/ISS-07-EVI-07-04.png)

**Qué hice:** declaré los campos de ambos serializers, incluida la relación con `ProductType`.

**Retroalimentación:** la captura muestra `product_type_id` como `PrimaryKeyRelatedField` y `product_type_name` como campo de solo lectura.

**Lo que aprendí:** una API puede aceptar el identificador de la relación y responder también con un campo informativo derivado del objeto relacionado.

### Paso 5. Creación de serializers de lectura para ventas

Creé `ProductSaleSerializer` y `SaleSerializer` en `apps/sale/serializers.py`.

#### Evidencia — Serializers de ventas y líneas

![ProductSaleSerializer y SaleSerializer](Trazabilidad/ISS-07-EVI-07-05.png)

**Qué hice:** definí la representación de las líneas y la venta con `client_name` y `lines` anidados de solo lectura.

**Retroalimentación:** todos los campos mostrados están declarados como solo lectura, de acuerdo con el alcance de ISS-07, que solo consulta ventas.

**Lo que aprendí:** el serializer puede componer datos relacionados en una respuesta JSON sin permitir todavía el alta transaccional de la venta.

### Verificaciones pendientes

La guía indica ejecutar `ClientApiTests.test_create_defaults_and_persists` y `ProductApiTests.test_product_crud_and_available_filter`. Las capturas recibidas muestran el código de los serializers y settings, pero no la salida de esas pruebas. Todavía no marco el GATE de ISS-07 como PASS.

### Conclusión

Instalé las dependencias de la API, configuré CORS y REST Framework y escribí los serializers de clientes, productos y ventas. Las capturas documentan estos pasos. Me falta la evidencia de las pruebas que verifican el JSON camelCase, la normalización del correo y el nombre del tipo de producto; por eso dejo ISS-07 parcialmente completada.

## ISS-08 — Client con ModelViewSet

**Estado:** implementé y probé el CRUD de clientes. Las cuatro pruebas pasaron en la ejecución documentada; quedan pendientes evidencias de los otros motores mencionados por el GATE.

### Objetivo

Publicar el CRUD de clientes con `ModelViewSet`.

### Paso 1. Vista para el recurso de clientes

Creé `apps/client/views.py` con `ClientViewSet`, acceso `AllowAny`, filtro opcional por `status` y baja lógica.

#### Evidencia EVI-08-01 — `ClientViewSet`

![ClientViewSet con filtro por estado y eliminación lógica](Trazabilidad/ISS-08-EVI-08-01.png)

**Qué hice:** implementé las operaciones CRUD genéricas con `ModelViewSet` y personalicé la consulta y la baja lógica.

**Retroalimentación:** la captura muestra `AllowAny`, el filtro por parámetro `status` y `perform_destroy`, que conserva la fila al marcarla inactiva.

**Lo que aprendí:** `ModelViewSet` cubre el CRUD y permite personalizar las partes específicas del recurso sin reimplementar cada método HTTP.

### Paso 2. Pruebas de la API de clientes

Preparé `ClientApiTests` para verificar el alta y persistencia, las validaciones, la baja lógica, el listado, el detalle y la actualización.

#### Evidencia EVI-08-02 — Pruebas del CRUD

![Pruebas de API para clientes](Trazabilidad/ISS-08-EVI-08-02.png)

**Qué hice:** escribí las cuatro pruebas indicadas para comprobar los comportamientos principales del endpoint.

**Retroalimentación:** la captura deja visibles las aserciones de alta, respuesta JSON camelCase, validación de correo y persistencia.

**Lo que aprendí:** las pruebas de API comprueban tanto el código HTTP como los datos devueltos y el estado que finalmente queda guardado.

### Paso 3. Primera ejecución de las pruebas

Ejecuté `python manage.py test apps.client`. En este primer intento, el servidor MySQL no permitió crear la base `test_Pedalibre` y devolvió el error `1044`.

#### Evidencia EVI-08-03 — Primer intento bloqueado por permisos de base de datos

![Primer intento de pruebas bloqueado al crear test_Pedalibre](Trazabilidad/ISS-08-EVI-08-03.png)

**Qué observé:** Django encontró cuatro pruebas, pero el servidor rechazó la creación de la base de pruebas por permisos.

**Retroalimentación:** este intento no constituye un resultado PASS; identificó una condición de acceso a la base de pruebas que debía resolverse antes de validar la suite.

**Lo que aprendí:** al ejecutar pruebas con una base SQL, Django necesita preparar su propia base de pruebas, además de poder conectarse a la base normal del proyecto.

### Paso 4. Registro de rutas del recurso

Creé `apps/client/urls.py` con `SimpleRouter(use_regex_path=False)` y registré el recurso `clients`.

#### Evidencia EVI-08-04 — Router de clientes

![SimpleRouter con las rutas del recurso clients](Trazabilidad/ISS-08-EVI-08-04.png)

**Qué hice:** registré `ClientViewSet` en el router para generar las rutas de lista/alta y detalle/actualización/baja.

**Retroalimentación:** la captura muestra el convertidor de ruta de tipo entero y el `basename` `client`.

**Lo que aprendí:** el router de DRF conecta las acciones de `ModelViewSet` con las rutas del recurso sin definir cada URL manualmente.

### Paso 5. Inclusión del router en el proyecto

Incluí `apps.client.urls` bajo el prefijo `api/` en `config/urls.py`, para completar la ruta `/api/clients/`.

#### Evidencia EVI-08-05 — Prefijo `/api/`

![Inclusión de las rutas de clientes en config/urls.py](Trazabilidad/ISS-08-EVI-08-05.png)

**Qué hice:** agregué el `include` del URLconf de clientes a las rutas principales del proyecto.

**Retroalimentación:** la configuración muestra el prefijo de API conectado al router de la app cliente.

**Lo que aprendí:** Django concatena el prefijo del proyecto con el segmento registrado por la app para formar la URL completa del recurso.

### Paso 6. Ejecución exitosa de las pruebas

Volví a ejecutar `python manage.py test apps.client`. La terminal indicó que `test_Pedalibre` ya existía y ofreció eliminarla para continuar; después, la suite terminó con cuatro pruebas ejecutadas y resultado `OK`.

#### Evidencia EVI-08-06 — Cuatro pruebas aprobadas

![Ejecución de ClientApiTests con cuatro pruebas y resultado OK](Trazabilidad/ISS-08-EVI-08-06.png)

**Qué observé:** después de confirmar la eliminación de la base de pruebas anterior, las cuatro pruebas finalizaron correctamente y Django destruyó la base temporal.

**Retroalimentación:** esta captura sí muestra la verificación exitosa de `ClientApiTests` en la configuración de base de datos activa durante esa ejecución.

**Lo que aprendí:** una base de pruebas residual puede impedir una nueva ejecución; resolver el aviso de Django permitió recrearla y completar las pruebas.

### Criterios y verificaciones pendientes

La captura acredita que las cuatro pruebas del CRUD pasaron en la ejecución mostrada. La guía pide evidencia PASS en PostgreSQL, MySQL y SQL Server; las capturas no acreditan los tres motores. Por ello, mantengo pendiente el GATE completo hasta documentar los motores restantes.

### Conclusión

Implementé el `ClientViewSet`, sus pruebas y las rutas `/api/clients/`. El primer intento de pruebas no pudo crear la base temporal por permisos; en la siguiente ejecución, Django detectó una base de pruebas existente, permitió eliminarla y recrearla, y las cuatro pruebas terminaron en `OK`. Aprendí a distinguir los problemas de preparación de la base de pruebas de los fallos de la API. Dejo el GATE parcialmente completado porque todavía falta la evidencia de todos los motores solicitados.

## ISS-09 — Catálogo con ModelViewSet

**Estado:** implementé el CRUD de tipos y productos, y la captura de pruebas muestra los cuatro casos aprobados. El GATE queda parcial porque no hay evidencia de los tres motores.

### Objetivo

Publicar tipos y productos con el mismo criterio de CRUD homogéneo.

### Paso 1. Vista compartida para el catálogo

Creé `CatalogViewSet` para compartir el permiso abierto, el filtro opcional por `status` y la baja lógica. Añadí `ProductTypeViewSet` y `ProductViewSet`; este último carga `product_type` relacionado con `select_related`.

#### Evidencia EVI-09-01 — Vistas del catálogo

![CatalogViewSet y viewsets de tipo y producto](Trazabilidad/ISS-09-EVI-09-01.png)

**Qué hice:** implementé los viewsets para tipos y productos reutilizando el comportamiento común del catálogo.

**Retroalimentación:** la captura muestra el permiso `AllowAny`, el convertidor entero, el filtro por estado y la baja lógica. También se ve el uso de `select_related("product_type")` en productos.

**Lo que aprendí:** una clase base puede reunir el comportamiento que comparten recursos CRUD sin dejar de usar `ModelViewSet`.

### Paso 2. Rutas de tipos y productos

Creé `apps/product/urls.py` y registré `product-types` y `products` con un `SimpleRouter`.

#### Evidencia EVI-09-02 — Router del catálogo

![SimpleRouter para tipos de producto y productos](Trazabilidad/ISS-09-EVI-09-02.png)

**Qué hice:** registré cada viewset con su `basename` para generar las rutas de lista, detalle y acciones CRUD.

**Retroalimentación:** la captura muestra ambos registros en el router; todavía no incluye una ruta para productos disponibles, que corresponde al ISS-10.

**Lo que aprendí:** puedo incluir varios recursos en el URLconf de una app usando el mismo router.

### Paso 3. Inclusión de rutas en el proyecto

Incluí `apps.product.urls` bajo `api/` en `config/urls.py`.

#### Evidencia EVI-09-03 — URLconf del proyecto

![Inclusión de las rutas del catálogo bajo api](Trazabilidad/ISS-09-EVI-09-03.png)

**Qué hice:** añadí el URLconf del catálogo junto al de clientes en las rutas principales.

**Retroalimentación:** la captura muestra que ambas apps reciben el prefijo `api/`.

**Lo que aprendí:** el prefijo compartido permite organizar rutas por recurso en sus apps y reunirlas desde el URLconf principal.

### Paso 4. Pruebas de tipos y productos

Reescribí `apps/product/tests.py` con cuatro pruebas para el CRUD de tipos, la actualización y baja lógica de productos, los valores por defecto, la restricción de borrado del tipo relacionado y el rechazo de nombres duplicados.

#### Evidencia EVI-09-04 — Pruebas de tipos y catálogo

![Pruebas ProductApiTests para CRUD y validaciones](Trazabilidad/ISS-09-EVI-09-04.png)

**Qué hice:** añadí pruebas HTTP con `APITestCase`; el tipo `Bebida` de apoyo se crea directamente en el ORM, como indica la guía.

**Retroalimentación:** la captura muestra las pruebas de CRUD de tipos y productos y las aserciones para los valores predeterminados y la restricción de borrado.

**Lo que aprendí:** puedo combinar solicitudes al endpoint con aserciones del ORM para verificar la persistencia y las reglas del modelo.

#### Evidencia EVI-09-05 — Validación de nombres duplicados

![Prueba de nombre duplicado y precio persistido](Trazabilidad/ISS-09-EVI-09-05.png)

**Qué hice:** verifiqué que la primera alta del nombre `Café` responda 201, la repetida responda 400 y el precio original permanezca guardado.

**Retroalimentación:** las aserciones distinguen el rechazo de duplicados de la persistencia correcta del primer producto.

**Lo que aprendí:** las restricciones de unicidad del catálogo se deben comprobar a través de la API, además de validar los datos que quedan almacenados.

### Paso 5. Ejecución de la suite de productos

Ejecuté `python manage.py test apps.product`.

#### Evidencia EVI-09-06 — Cuatro pruebas aprobadas

![Ejecución de apps.product: cuatro pruebas con resultado OK](Trazabilidad/ISS-09-EVI-09-06.png)

**Qué observé:** Django encontró cuatro pruebas, ejecutó todas y terminó con `OK`.

**Retroalimentación:** la captura verifica la suite de productos en la configuración de base de datos activa en esa ejecución. No identifica evidencia de ejecución en los tres motores.

**Lo que aprendí:** una ejecución satisfactoria de la suite comprueba los casos implementados en ese entorno; para afirmar compatibilidad multi-motor hacen falta resultados separados por motor.

### Criterios y verificaciones pendientes

La suite de cuatro pruebas pasó en la ejecución mostrada. Las capturas no demuestran la ejecución en PostgreSQL, MySQL y SQL Server, así que no afirmo haber cerrado el GATE multi-motor.

### Conclusión

Publiqué los CRUD de tipos y productos, compartí el comportamiento común en `CatalogViewSet`, conecté sus rutas y escribí cuatro pruebas. La evidencia muestra que las cuatro pasaron. Aprendí a reutilizar el comportamiento de baja lógica y a verificar restricciones y defaults mediante la API. Dejo el GATE parcialmente completado hasta contar con evidencia de los tres motores pedidos.

## ISS-10 — Disponibles con ListAPIView

**Estado:** guía recibida; pendiente de ejecutar los pasos y documentar evidencias.

### Objetivo

Publicar una lectura filtrada de productos disponibles que no forma parte del CRUD del producto.

### Preparación

Guardé la guía ejecutable en [ISS-10.md](Iss/ISS-10.md). Todavía no implemento el endpoint ni agrego pruebas para el filtro.

### Conclusión

Pendiente de realizar los pasos de ISS-10 y documentar sus evidencias.
