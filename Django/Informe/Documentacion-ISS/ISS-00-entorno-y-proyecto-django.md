# ISS-00 - Entorno y proyecto Django

> **Referencia PedalLibre.** Proyecto Django PedalLibre y entorno aislado. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


## Objetivo

Crear el entorno aislado y el proyecto Django `config`, sin modelos todavía.

## Requisitos

- Python 3.12.
- El directorio del proyecto vacío.
- Red para instalar Django 5.2.17.

## Construcción

La CLI crea el entorno y el proyecto. No se escribe `manage.py` a mano. `python3 -m venv` usa el Python del sistema una sola vez para crear `.venv`; todos los comandos posteriores usan el `python` del entorno.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install "Django==5.2.17"
django-admin startproject config .
python -m pip freeze > requirements.txt
python -m django --version
```

`pip` siempre se ejecuta con el entorno activo: `source .venv/bin/activate` y después `python -m pip`. Un `python3 -m pip` del sistema instala paquetes fuera del proyecto.

`startproject config .` deja `manage.py` en la raíz y el paquete de configuración en `config/`; no crea una carpeta `storelab/storelab/`. Cree también este archivo nuevo:

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

## Explicación

- `Django==5.2.17` aporta el ORM, el admin, `startproject` y `manage.py`. DRF, dotenv y drivers se incorporan después.
- `.venv` aísla pip del sistema y deja el prompt como `(.venv)`.
- `django-admin` es la CLI del Django instalado, antes de que exista `manage.py`.
- `manage.py` fija `DJANGO_SETTINGS_MODULE=config.settings`. El ISS-01 incorpora dotenv y el salto al intérprete de `.venv`.
- `config/urls.py` es la entrada de cada petición. `startproject` deja `ROOT_URLCONF = "config.urls"` y `path("admin/", admin.site.urls)`; `startapp` no crea `urls.py`.

```text
ISS-00
  manage.py
  config/settings.py     # archivo generado; ISS-01 lo convierte en paquete
  config/urls.py         # solo admin/
  config/wsgi.py
  config/asgi.py
```

## Criterios de aceptación

- AC-00-01: `python -m django --version` imprime 5.2.17.
- AC-00-02: existen `manage.py` y `config/urls.py`.
- AC-00-03: no hay modelos de negocio.

## Verificación

```bash
python -m django --version
python manage.py check
```

En este ISS, `check` todavía puede usar SQLite, el valor por defecto de `startproject`. ISS-01 lo reemplaza.

## Evidencias

- EVI-00-01: Django 5.2.17 instalado en `.venv`.
- EVI-00-02: árbol `config/` generado por la CLI.

## GATE

| AC | Verificación | Evidencia | Resultado |
| :-- | :-- | :-- | :-- |
| AC-00-01 | versión de Django | EVI-00-01 | PASS |
| AC-00-02 | archivos del proyecto | EVI-00-02 | PASS |
| AC-00-03 | ausencia de modelos de negocio | inspección del árbol | PASS |

Las condiciones de cierre no añaden criterios nuevos. Con el GATE en verde queda habilitado ISS-01.
