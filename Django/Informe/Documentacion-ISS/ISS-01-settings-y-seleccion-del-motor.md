# ISS-01 - Settings y selección del motor

## Objetivo

Configurar el entorno de PedalLibre para Django y seleccionar un único motor de base de datos por ejecución.

## Requisitos

- ISS-00 superado.
- Entorno virtual `.venv` creado y activo.
- Las 21 tablas de PedalLibre creadas con los scripts de [Creacion de Tablas y Registros](./Creacion%20de%20Tablas%20y%20Registros/guia.md).

## 1. Instalar dependencias

En Ubuntu/WSL, MySQL requiere herramientas nativas para compilar `mysqlclient`:

```bash
sudo apt update
sudo apt install build-essential pkg-config default-libmysqlclient-dev python3.12-dev

source .venv/bin/activate
python -m pip install "Django==5.2.17" "python-dotenv==1.2.3"
python -m pip install "mysqlclient==2.3.0"
python -m pip install "psycopg[binary]==3.3.6" "mssql-django==2.0.0" "oracledb==26.0.1"
python -m pip freeze > requirements.txt
```

El error `No such file or directory: 'x86_64-linux-gnu-gcc'` significa que falta el compilador de C. `sudo apt update` solo actualiza la lista de paquetes; el comando `apt install` anterior instala `gcc` y las cabeceras necesarias.

## 2. Crear `.env`

Cree `.env` en la raíz del proyecto. El archivo queda excluido por `.gitignore`.

```dotenv
# ==========================================
# APP
# ==========================================
PORT=3002
NODE_ENV=development

# ==========================================
# DJANGO
# ==========================================
DJANGO_SECRET_KEY=xlmzT51mMezK-_quUUUzOT9j9JI3RuCQHKH_dwHVaI4l0XFqT_JZw6A0gq6eAE-C
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,testserver
CORS_ALLOW_ALL_ORIGINS=True

# ==========================================
# DATABASE
# ==========================================
# Selector del motor en ejecución: mysql | postgres | mssql | oracle
# Cambie solamente DB_DIALECT para seleccionar otro motor.
DB_DIALECT=mysql

# --- MYSQL ---
DB_MYSQL_HOST=172.18.50.255
DB_MYSQL_PORT=3306
DB_MYSQL_USERNAME=admin
DB_MYSQL_PASSWORD=1704
# Texto recibido en la configuración original: -DW
DB_MYSQL_NAME=Pedalibre-Terminal-Dbeaver

# --- POSTGRES ---
DB_POSTGRES_HOST=localhost
DB_POSTGRES_PORT=5432
DB_POSTGRES_USERNAME=admin
DB_POSTGRES_PASSWORD=1704
DB_POSTGRES_NAME=Pedalibre

# --- MSSQL (SQL Server) ---
DB_MSSQL_HOST=localhost
DB_MSSQL_PORT=1433
DB_MSSQL_USERNAME=admin
DB_MSSQL_PASSWORD=1704
DB_MSSQL_NAME=Pedalibre

# --- ORACLE ---
DB_ORACLE_HOST=localhost
DB_ORACLE_PORT=1521
DB_ORACLE_USERNAME=admin
DB_ORACLE_PASSWORD=1704
DB_ORACLE_NAME=Pedalibre
DB_ORACLE_CONNECT_STRING=localhost:1521/Pedalibre
```

Para crear el archivo completo con un solo pegado en WSL, ejecute este comando desde la raíz del proyecto:

```bash
cat > .env <<'EOF'
# ==========================================
# APP
# ==========================================
PORT=3002
NODE_ENV=development

# ==========================================
# DJANGO
# ==========================================
DJANGO_SECRET_KEY=xlmzT51mMezK-_quUUUzOT9j9JI3RuCQHKH_dwHVaI4l0XFqT_JZw6A0gq6eAE-C
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,testserver
CORS_ALLOW_ALL_ORIGINS=True

# ==========================================
# DATABASE
# ==========================================
DB_DIALECT=mysql

# --- MYSQL ---
DB_MYSQL_HOST=172.18.50.255
DB_MYSQL_PORT=3306
DB_MYSQL_USERNAME=admin
DB_MYSQL_PASSWORD=1704
# Texto recibido en la configuración original: -DW
DB_MYSQL_NAME=Pedalibre-Terminal-Dbeaver

# --- POSTGRES ---
DB_POSTGRES_HOST=localhost
DB_POSTGRES_PORT=5432
DB_POSTGRES_USERNAME=admin
DB_POSTGRES_PASSWORD=1704
DB_POSTGRES_NAME=Pedalibre

# --- MSSQL (SQL Server) ---
DB_MSSQL_HOST=localhost
DB_MSSQL_PORT=1433
DB_MSSQL_USERNAME=admin
DB_MSSQL_PASSWORD=1704
DB_MSSQL_NAME=Pedalibre

# --- ORACLE ---
DB_ORACLE_HOST=localhost
DB_ORACLE_PORT=1521
DB_ORACLE_USERNAME=admin
DB_ORACLE_PASSWORD=1704
DB_ORACLE_NAME=Pedalibre
DB_ORACLE_CONNECT_STRING=localhost:1521/Pedalibre
EOF
```

`DB_MYSQL_NAME` usa `Pedalibre-Terminal-Dbeaver`, tal como aparece en los scripts MySQL del proyecto. La línea `-DW` se conserva como comentario porque no tiene formato `CLAVE=VALOR` y no es una variable de entorno válida.

## 3. Configuración de Django

El archivo `config/database.py` debe leer exclusivamente las variables con prefijo `DB_` y crear un único alias `DATABASES["default"]`.

| `DB_DIALECT` | Backend Django | Variables requeridas |
| :-- | :-- | :-- |
| `mysql` | `django.db.backends.mysql` | `DB_MYSQL_HOST`, `PORT`, `USERNAME`, `PASSWORD`, `NAME` |
| `postgres` | `django.db.backends.postgresql` | `DB_POSTGRES_HOST`, `PORT`, `USERNAME`, `PASSWORD`, `NAME` |
| `mssql` | `mssql` | `DB_MSSQL_HOST`, `PORT`, `USERNAME`, `PASSWORD`, `NAME` |
| `oracle` | `django.db.backends.oracle` | `DB_ORACLE_USERNAME`, `PASSWORD`, `CONNECT_STRING` |

No use `DB_ENGINE`, `MYSQL_*`, `POSTGRES_*`, `MSSQL_*` ni `ORACLE_*` sin el prefijo `DB_`: pertenecen al contrato anterior y no aplican a PedalLibre.

## 4. Verificación

El comando correcto es `runserver`, con `r` final:

```bash
python manage.py check
python manage.py runserver
```

Si se cambia a otro motor, actualice únicamente `DB_DIALECT`; Django validará solo el bloque correspondiente. Las tablas son administradas por los scripts SQL de PedalLibre, por lo que los modelos Django deben usar los nombres físicos del esquema y `managed = False`.

## Criterios de aceptación

- AC-01-01: `.env` contiene un `DJANGO_SECRET_KEY` no vacío.
- AC-01-02: `DB_DIALECT=mysql` valida el bloque `DB_MYSQL_*`.
- AC-01-03: `python manage.py check` inicia la configuración sin error de variables faltantes.
- AC-01-04: `python manage.py runserver` usa el comando correcto.

## Referencia

La estructura de tablas, relaciones y reglas de mapeo está en [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md).
