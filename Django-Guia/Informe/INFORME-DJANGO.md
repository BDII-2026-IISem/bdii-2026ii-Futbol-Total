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
