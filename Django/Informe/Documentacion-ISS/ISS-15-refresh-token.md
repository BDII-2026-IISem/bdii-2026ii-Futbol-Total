# ISS-15 - RefreshToken

> **Referencia PedalLibre.** Refresh tokens de la capa Django sin crear tablas de negocio ajenas al esquema. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-15/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

ISS-15 — RefreshToken
Objetivo
Persistir la sesión de refresh sin guardar el token en claro y sin usar la blacklist de SimpleJWT como almacén.

Requisitos
Cierre de negocio, al final del ISS-14, superado en el motor que se esté usando.
User ya existe desde el ISS-03.
Construcción
apps/security/tokens.py es nuevo:

cat > apps/security/tokens.py <<'EOF'
import hashlib
import secrets


def generate_refresh_value():
    return secrets.token_urlsafe(48)


def hash_token(raw_token):
    return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
EOF
apps/security/models.py ya tiene User. La clase RefreshToken se pega al final. No se reescribe el usuario.


class RefreshToken(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.RESTRICT,
        related_name="refresh_tokens",
        db_column="user_id",
    )
    token_hash = models.CharField(max_length=64, unique=True)
    family_id = models.UUIDField(default=uuid.uuid4, editable=False, db_index=True)
    expires_at = models.DateTimeField()
    revoked_at = models.DateTimeField(null=True, blank=True)
    replaced_by = models.ForeignKey(
        "self",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="replacements",
    )
    status = models.CharField(
        max_length=8,
        choices=RecordStatus.choices,
        default=RecordStatus.ACTIVE,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "refresh_tokens"
        ordering = ["-created_at"]
        constraints = [
            models.CheckConstraint(
                condition=models.Q(status__in=RecordStatus.values),
                name="refresh_tokens_status_valid",
            )
        ]

    def __str__(self):
        return f"{self.user} {self.family_id}"

    @property
    def is_usable(self):
        return (
            self.status == RecordStatus.ACTIVE
            and self.revoked_at is None
            and self.replaced_by_id is None
            and self.expires_at > timezone.now()
        )

    @classmethod
    def lifetime(cls):
        return settings.SIMPLE_JWT["REFRESH_TOKEN_LIFETIME"]

    @classmethod
    def default_expiry(cls):
        return timezone.now() + cls.lifetime()

ARCHIVO: apps/security/models.py

ENCIMA DE:
from django.contrib.auth.models import AbstractUser, UserManager

AGREGAR:
import uuid

from django.conf import settings
from django.utils import timezone

AL FINAL DEL ARCHIVO, DESPUÉS DE LA CLASE User, AGREGAR la clase RefreshToken.
SimpleJWT entra aquí, antes del login. Solo emite y verifica el access token. No se instala rest_framework_simplejwt.token_blacklist: el refresh de StoreLab vive en la tabla refresh_tokens, no en esa app.


source .venv/bin/activate
python -m pip install "djangorestframework-simplejwt==5.5.1"
python -m pip freeze > requirements.txt
El paquete pip es djangorestframework-simplejwt. En INSTALLED_APPS el nombre es rest_framework_simplejwt. PyJWT llega como dependencia; no se instala aparte. Settings ya existe.


ARCHIVO: config/settings/__init__.py

ENCIMA DE:
import os

AGREGAR:
from datetime import timedelta

DEBAJO DE:
    "rest_framework",

AGREGAR:
    "rest_framework_simplejwt",

AL FINAL DEL ARCHIVO, AGREGAR:

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=60),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=1),
    "ROTATE_REFRESH_TOKENS": False,
    "BLACKLIST_AFTER_ROTATION": False,
    "UPDATE_LAST_LOGIN": True,
    "ALGORITHM": "HS256",
    "SIGNING_KEY": SECRET_KEY,
    "AUTH_HEADER_TYPES": ("Bearer",),
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
}
No instale token_blacklist. La rotación es la de StoreLab.


python manage.py makemigrations security
python manage.py migrate
Se agrega RefreshToken en apps/security/models.py y se migra de nuevo:


python manage.py makemigrations security
python manage.py migrate
Campos: user, token_hash (64, único), family_id (UUID), expires_at, revoked_at, replaced_by, status, created_at, updated_at. Tabla refresh_tokens.

apps/security/tokens.py genera el valor con secrets.token_urlsafe y guarda sha256 en hexadecimal.

El default de status aquí es active. Es la excepción del diccionario: el token acaba de nacer de un login válido. El resto de entidades sigue naciendo inactive.

No se instala rest_framework_simplejwt.token_blacklist. ROTATE_REFRESH_TOKENS y BLACKLIST_AFTER_ROTATION quedan en False porque la rotación es nuestra.

Explicación
El access token es un JWT. Se verifica con la firma y la expiración; no hace falta una fila. El refresh tiene que poder revocarse, así que necesita estado en la base. Guardar el refresh en claro permitiría usar la tabla como si fuera la sesión. El hash no se puede invertir: hace falta el valor que solo vio el cliente.


refresh en claro  --solo en la respuesta--
        │
        ▼
SHA-256 → refresh_tokens.token_hash
Criterios de aceptación
AC-15-01: después del login hay una fila y su token_hash no es el refresh devuelto.
AC-15-02: el hash coincide con SHA-256 del valor devuelto.
AC-15-03: la respuesta no contiene password.
Verificación
AuthFlowTests.test_login_with_username_and_email.

Evidencias
EVI-15-01: test PASS.
GATE
AC	Verificación	Evidencia	Resultado
AC-15-01	fila distinta del claro	EVI-15-01	PASS
AC-15-02	SHA-256	EVI-15-01	PASS
AC-15-03	sin password en JSON	EVI-15-01	PASS
✅ GATE de la unidad ISS-15 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-15 · 🧠 Aprender · ↑ Ruta Django · → ISS-16 · 🧠 Aprender
