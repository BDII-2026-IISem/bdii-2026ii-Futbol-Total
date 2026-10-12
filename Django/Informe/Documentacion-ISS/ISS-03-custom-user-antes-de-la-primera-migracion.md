# ISS-03 - Custom User antes de la primera migración

> **Referencia PedalLibre.** Autenticación sobre users y roles existentes; clients no almacena contraseñas. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


## Objetivo

Definir el usuario de StoreLab sobre `django.contrib.auth` y fijar `AUTH_USER_MODEL` antes de migrar.

## Requisitos

- ISS-02 superado.
- Decisión explícita entre `AbstractUser` y `AbstractBaseUser`.

## Construcción

`apps/common` no es una app y no se registra. Cree `apps/common/__init__.py` y `apps/common/status.py`:

```python
from django.db import models


class RecordStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    INACTIVE = "inactive", "Inactive"
```

La app de seguridad sí sale de la CLI:

```bash
mkdir -p apps/security
python manage.py startapp security apps/security
```

En `apps/security/apps.py`, use `name = "apps.security"` y `label = "security"`. Reemplace `apps/security/models.py` por:

```python
from django.contrib.auth.models import AbstractUser, UserManager
from django.db import models

from apps.common.status import RecordStatus


class StoreUserManager(UserManager):
    def create_user(self, username, email=None, password=None, **extra_fields):
        extra_fields.setdefault("status", RecordStatus.INACTIVE)
        return super().create_user(username, email, password, **extra_fields)

    def create_superuser(self, username, email=None, password=None, **extra_fields):
        extra_fields.setdefault("status", RecordStatus.ACTIVE)
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return super().create_superuser(username, email, password, **extra_fields)


class User(AbstractUser):
    email = models.EmailField("correo electrónico", max_length=150, unique=True)
    status = models.CharField(max_length=8, choices=RecordStatus.choices, default=RecordStatus.INACTIVE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = StoreUserManager()

    class Meta:
        db_table = "users"
        verbose_name = "usuario"
        verbose_name_plural = "usuarios"
        constraints = [models.CheckConstraint(
            condition=models.Q(status__in=RecordStatus.values),
            name="users_status_valid",
        )]

    def save(self, *args, **kwargs):
        if self.email:
            self.email = self.email.strip().lower()
        self.is_active = self.status == RecordStatus.ACTIVE
        super().save(*args, **kwargs)
```

Agregue `"apps.security.apps.SecurityConfig"` antes de las apps de negocio y, debajo de `DATABASES`, declare:

```python
AUTH_USER_MODEL = "security.User"
```

Escriba `DatabaseSelectionTests` en `apps/security/tests.py` para comprobar cada motor, un valor de motor inválido, una variable vacía y el `SERVICE_NAME` de Oracle. Los tests construyen diccionarios completos de entorno y llaman a `database_from_environ`, sin conectar a una base de datos.

Solo ahora se migra:

```bash
python manage.py makemigrations security
python manage.py migrate
python manage.py test apps.security.tests.DatabaseSelectionTests
```

No migre antes: Django crearía las tablas del usuario por defecto y cambiar `AUTH_USER_MODEL` después obligaría a borrarlas.

## Explicación

`AbstractUser` se prefiere a `AbstractBaseUser`: ya provee hash, validadores, `set_password()`, `check_password()` y el admin. `status` manda sobre `is_active`, que se conserva para DRF y SimpleJWT. `create_user` deja el usuario inactivo; `create_superuser` lo mantiene activo.

```text
AbstractUser + status + created_at / updated_at + email único
                         |
                         v
              AUTH_USER_MODEL = security.User
```

## Criterios de aceptación

- AC-03-01: `AUTH_USER_MODEL` apunta a `security.User`.
- AC-03-02: `Client` no tiene `password`.
- AC-03-03: un usuario inactivo no inicia sesión.
- AC-03-04: clave incorrecta responde 401 y la correcta no devuelve el hash.

## Evidencias y GATE

- EVI-03-01: migración `security.0001_initial` aplicada en PostgreSQL.
- EVI-03-02: login por username y email en PASS.

Los criterios cierran con settings, el modelo Client y `AuthFlowTests` en PASS.
