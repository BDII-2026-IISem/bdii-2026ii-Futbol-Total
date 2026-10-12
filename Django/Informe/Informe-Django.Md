# Informe de desarrollo del proyecto Django

---

## Universidad de La Guajira

### Facultad de Ingeniería

| Dato | Información |
| :-- | :-- |
| Programa | Ingeniería de Sistemas |
| Estudiante | [Escribe aquí tu nombre completo] |
| Asignatura | Desarrollo Web — 2026-II semestre |
| Área del proyecto | Base de Datos II |
| Docente | ING. JAIDER J. QUINTERO MENDOZA, PhD G en Innovación |
| Proyecto | Desarrollo de PedalLibre con Django |

---

## Presentación

En este informe documento el desarrollo de PedalLibre con Django siguiendo, en orden, las instrucciones de cada ISS. Para cada paso registro el propósito, los bloques de código que ejecuto, la captura de evidencia, la retroalimentación sobre el resultado, la conclusión y lo que aprendí. Las capturas se presentan dentro del informe, debajo del paso al que corresponden, y también se conservan en la carpeta `Trazabilidad`.

## ISS-00 - Entorno y proyecto Django

### Paso 1 - Creación del entorno virtual e inicio del proyecto

Creé el entorno virtual `.venv`, lo activé, instalé Django 5.2.17, generé el proyecto `config` en la raíz y guardé las dependencias instaladas en `requirements.txt`.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install "Django==5.2.17"
django-admin startproject config .
python -m pip freeze > requirements.txt
python -m django --version
```

![EVI-00-02 - Entorno y proyecto Django generados](./Trazabilidad/EVI-00-02-proyecto-django.png)

**Retroalimentación de la evidencia:** En la captura observé la ejecución de los comandos, la instalación exitosa de Django 5.2.17 y la versión `5.2.17` impresa al final. En el Explorador de VS Code aparecen `.venv/`, `config/`, `manage.py` y `requirements.txt`, correspondientes a la estructura inicial.

**Conclusión y aprendizaje:** Aprendí que `venv` permite aislar las dependencias del proyecto y que `django-admin startproject config .` genera la configuración en la raíz actual. `requirements.txt` conserva las dependencias para poder reproducir el entorno.

### Paso 2 - Creación del archivo `.gitignore`

Creé el archivo `.gitignore` en la raíz del proyecto `Django` para excluir del control de versiones el entorno virtual, los archivos temporales de Python, la configuración local y otros archivos generados.

```gitignore
.venv/
__pycache__/
*.py[cod]
.env
db.sqlite3
*.log
.idea/
.vscode/
staticfiles/
media/
.pytest_cache/
htmlcov/
.coverage
```

![EVI-00-01 - Creación y contenido de `.gitignore`](./Trazabilidad/EVI-00-01-gitignore.png)

**Retroalimentación de la evidencia:** En la captura observé el comando que crea `.gitignore` desde la raíz `Django`, la ruta impresa por `pwd` y el contenido mostrado después con `cat`. Así comprobé que el archivo quedó en la ubicación indicada y que contiene las reglas de exclusión solicitadas.

**Conclusión y aprendizaje:** Aprendí que `.gitignore` debe estar en la raíz del proyecto para que Git aplique sus reglas a los archivos y carpetas generados dentro de él. Excluir `.venv/`, cachés y archivos locales evita incorporarlos accidentalmente a los commits.

### Paso 3 - Verificación de la instalación y del proyecto

Verifiqué la versión instalada de Django y comprobé la configuración inicial del proyecto.

```bash
python -m django --version
python manage.py check
```

![EVI-00-03 - Verificación de Django y del proyecto](./Trazabilidad/EVI-00-03-verificacion-django.png)

**Retroalimentación de la evidencia:** En la captura observé la versión `5.2.17` y el resultado `System check identified no issues (0 silenced)`. Esto confirma que Django reconoce el proyecto y que la comprobación del sistema no encontró problemas.

**Conclusión y aprendizaje:** Aprendí a verificar tanto la versión instalada como la configuración del proyecto con los comandos oficiales de Django. La comprobación sin errores deja validado el entorno inicial para continuar con el ISS-01.

## ISS-01 - Settings y selección del motor

### Paso 1 - Instalación de dependencias

Instalé las herramientas del sistema necesarias para compilar el controlador de MySQL y agregué al entorno virtual las dependencias de Django, dotenv y los cuatro motores de base de datos. Al final actualicé `requirements.txt` con `pip freeze`.

```bash
sudo apt update
sudo apt install build-essential pkg-config default-libmysqlclient-dev python3.12-dev

source .venv/bin/activate
python -m pip install "Django==5.2.17" "python-dotenv==1.2.3"
python -m pip install "mysqlclient==2.3.0"
python -m pip install "psycopg[binary]==3.3.6" "mssql-django==2.0.0" "oracledb==26.0.1"
python -m pip freeze > requirements.txt
```

![EVI-01-01 - Actualización de paquetes e instalación de herramientas del sistema](./Trazabilidad/EVI-01-01-instalacion-dependencias.png)

![EVI-01-02 - Instalación de dependencias Python completada](./Trazabilidad/EVI-01-02-dependencias-instaladas.png)

**Retroalimentación de las evidencias:** En la primera captura observé que `apt update` finalizó correctamente y que las herramientas de compilación y desarrollo requeridas ya estaban instaladas o actualizadas. En la segunda observé la instalación completada de las dependencias de Python y el regreso al prompt con el entorno `(.venv)` activo. El archivo `requirements.txt` registra Django 5.2.17, python-dotenv 1.2.3, mysqlclient 2.3.0, psycopg 3.3.6, mssql-django 2.0.0 y oracledb 26.0.1, además de sus dependencias.

**Conclusión y aprendizaje:** Aprendí que algunos controladores requieren herramientas del sistema además de paquetes de Python. También aprendí que actualizar `requirements.txt` después de instalar las dependencias deja constancia reproducible de las versiones incorporadas al entorno.

### Paso 2 - Creación del archivo `.env`

Creé `.env` en la raíz del proyecto con la configuración de Django y las variables de conexión para los motores indicados en el ISS-01. Seleccioné MySQL mediante `DB_DIALECT`. El archivo está excluido del control de versiones por `.gitignore`.

Por seguridad, en este informe no reproduzco las claves ni contraseñas. La siguiente estructura identifica las variables configuradas; los valores sensibles se reemplazan por marcadores:

```dotenv
DJANGO_SECRET_KEY=[REDACTADO]
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=[VALORES_CONFIGURADOS]

DB_DIALECT=mysql
DB_MYSQL_HOST=[VALOR_CONFIGURADO]
DB_MYSQL_PORT=[VALOR_CONFIGURADO]
DB_MYSQL_USERNAME=[REDACTADO]
DB_MYSQL_PASSWORD=[REDACTADO]
DB_MYSQL_NAME=[VALOR_CONFIGURADO]

DB_POSTGRES_HOST=[VALOR_CONFIGURADO]
DB_POSTGRES_PORT=[VALOR_CONFIGURADO]
DB_POSTGRES_USERNAME=[REDACTADO]
DB_POSTGRES_PASSWORD=[REDACTADO]
DB_POSTGRES_NAME=[VALOR_CONFIGURADO]

DB_MSSQL_HOST=[VALOR_CONFIGURADO]
DB_MSSQL_PORT=[VALOR_CONFIGURADO]
DB_MSSQL_USERNAME=[REDACTADO]
DB_MSSQL_PASSWORD=[REDACTADO]
DB_MSSQL_NAME=[VALOR_CONFIGURADO]

DB_ORACLE_HOST=[VALOR_CONFIGURADO]
DB_ORACLE_PORT=[VALOR_CONFIGURADO]
DB_ORACLE_USERNAME=[REDACTADO]
DB_ORACLE_PASSWORD=[REDACTADO]
DB_ORACLE_CONNECT_STRING=[VALOR_CONFIGURADO]
```

![EVI-01-03 - Archivo `.env` creado con las claves y contraseñas censuradas](./Trazabilidad/EVI-01-03-env-claves-redactadas.png)

**Retroalimentación de la evidencia:** En la captura observé el bloque de configuración en la terminal y el archivo `.env` en el Explorador de VS Code. La clave de Django y las contraseñas aparecen censuradas en esta copia de la imagen. Confirmé además que `.env` está incluido en las reglas de `.gitignore`, por lo que no se incorpora al commit.

**Conclusión y aprendizaje:** Aprendí que las variables de entorno permiten mantener la configuración fuera del código fuente y que los valores sensibles no deben publicarse en informes ni evidencias. Si alguna de las credenciales capturadas correspondiera a un servicio real, tendría que cambiarla, pues el original de la imagen la mostraba sin censura.

### Paso 3 - Configuración del motor de base de datos

Creé `config/database.py` para leer el selector `DB_DIALECT`, validar las variables requeridas para el motor seleccionado y producir únicamente la configuración `DATABASES["default"]`. La configuración admite MySQL, PostgreSQL, SQL Server y Oracle, según el contrato definido por el ISS-01.

```python
import os

from django.core.exceptions import ImproperlyConfigured


def _required(name: str) -> str:
    value = os.getenv(name)
    if value is None or not value.strip():
        raise ImproperlyConfigured(f"Falta la variable de entorno requerida: {name}")
    return value.strip()


dialect = _required("DB_DIALECT").lower()

if dialect == "mysql":
    database = {
        "ENGINE": "django.db.backends.mysql",
        "NAME": _required("DB_MYSQL_NAME"),
        "USER": _required("DB_MYSQL_USERNAME"),
        "PASSWORD": _required("DB_MYSQL_PASSWORD"),
        "HOST": _required("DB_MYSQL_HOST"),
        "PORT": _required("DB_MYSQL_PORT"),
    }
elif dialect == "postgres":
    database = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": _required("DB_POSTGRES_NAME"),
        "USER": _required("DB_POSTGRES_USERNAME"),
        "PASSWORD": _required("DB_POSTGRES_PASSWORD"),
        "HOST": _required("DB_POSTGRES_HOST"),
        "PORT": _required("DB_POSTGRES_PORT"),
    }
elif dialect == "mssql":
    database = {
        "ENGINE": "mssql",
        "NAME": _required("DB_MSSQL_NAME"),
        "USER": _required("DB_MSSQL_USERNAME"),
        "PASSWORD": _required("DB_MSSQL_PASSWORD"),
        "HOST": _required("DB_MSSQL_HOST"),
        "PORT": _required("DB_MSSQL_PORT"),
    }
elif dialect == "oracle":
    database = {
        "ENGINE": "django.db.backends.oracle",
        "NAME": _required("DB_ORACLE_CONNECT_STRING"),
        "USER": _required("DB_ORACLE_USERNAME"),
        "PASSWORD": _required("DB_ORACLE_PASSWORD"),
    }
else:
    raise ImproperlyConfigured(
        "DB_DIALECT debe ser mysql, postgres, mssql u oracle"
    )

DATABASES = {"default": database}
```

![EVI-01-04 - Archivo `config/database.py` creado](./Trazabilidad/EVI-01-04-configuracion-database.png)

**Retroalimentación de la evidencia:** En la captura observé `database.py` dentro de `config/` y el comando utilizado para crearlo. Revisé el archivo guardado y confirmé que contiene la configuración de los cuatro dialectos, que falla explícitamente si falta una variable requerida y que solo expone el alias `default`. La captura no incluye valores del archivo `.env`.

**Conclusión y aprendizaje:** Aprendí a separar la selección del motor de la configuración general del proyecto. La validación de variables ayuda a identificar una configuración incompleta y evita crear conexiones para motores que no están seleccionados. La integración de este módulo con `settings.py` y la carga de `.env` se registra en el siguiente paso.
