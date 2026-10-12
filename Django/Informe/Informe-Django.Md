# Informe de desarrollo del proyecto Django

En este informe registro los pasos que sigo según cada ISS, las evidencias, la retroalimentación de lo observado y lo que aprendo.

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
