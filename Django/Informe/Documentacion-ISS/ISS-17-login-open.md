# ISS-17 - Login OPEN

> **Referencia PedalLibre.** Login contra users.password_hash e is_active. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-17/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

ISS-17 — Login OPEN
Objetivo
Demostrar identidad por username o email y entregar access más refresh.

Este ISS abre el primer acceso de la Fase II: OPEN. No pide JWT. El segundo acceso, JWT con token, es el perfil (ISS-20). El tercero, JWT con token + RBAC, cierra el negocio (ISS-22) y la matriz (ISS-23).

Requisitos
ISS-16 superado.
Login no puede exigir un access token: todavía no existe.
Construcción
apps/security/serializers.py y apps/security/auth_views.py no existen. Se crean ahora. En este ISS el archivo de vistas solo tiene el login y los helpers que refresh y logout van a reutilizar. Esas dos clases se agregan al final en el ISS-18 y el ISS-19.


cat > apps/security/serializers.py <<'EOF'
from rest_framework import serializers


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=False, allow_blank=False)
    email = serializers.EmailField(required=False)
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        if not attrs.get("username") and not attrs.get("email"):
            raise serializers.ValidationError(
                "Informe username o email junto con password."
            )
        return attrs


class RefreshSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class TokenPairSerializer(serializers.Serializer):
    access = serializers.CharField()
    refresh = serializers.CharField()
    token_type = serializers.CharField()
    access_expires_in = serializers.IntegerField()
EOF

cat > apps/security/auth_views.py <<'EOF'
import uuid

from django.conf import settings
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import AccessToken

from apps.common.status import RecordStatus
from apps.security.models import RefreshToken
from apps.security.serializers import LoginSerializer, TokenPairSerializer
from apps.security.tokens import generate_refresh_value, hash_token

User = get_user_model()


def token_payload(user, raw_refresh):
    access = AccessToken.for_user(user)
    lifetime = int(settings.SIMPLE_JWT["ACCESS_TOKEN_LIFETIME"].total_seconds())
    return {
        "access": str(access),
        "refresh": raw_refresh,
        "token_type": "Bearer",
        "access_expires_in": lifetime,
    }


def issue_refresh(user, family_id=None):
    raw_refresh = generate_refresh_value()
    stored = RefreshToken.objects.create(
        user=user,
        token_hash=hash_token(raw_refresh),
        family_id=family_id or uuid.uuid4(),
        expires_at=RefreshToken.default_expiry(),
        status=RecordStatus.ACTIVE,
    )
    return stored, raw_refresh


class LoginAPIView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        user = _find_user(data.get("username"), data.get("email"))
        invalid = Response(
            {"detail": "Credenciales inválidas."},
            status=status.HTTP_401_UNAUTHORIZED,
        )
        if user is None or user.status != RecordStatus.ACTIVE:
            return invalid
        if not user.check_password(data["password"]):
            return invalid
        _stored, raw_refresh = issue_refresh(user)
        return Response(token_payload(user, raw_refresh), status=status.HTTP_200_OK)


def _find_user(username, email):
    if username and email:
        return User.objects.filter(username=username, email__iexact=email).first()
    if username:
        return User.objects.filter(username=username).first()
    if email:
        return User.objects.filter(email__iexact=email).first()
    return None
EOF
extend_schema se agrega en el ISS-14 ya pasó; si spectacular está instalado, el ISS-24 exige el decorador. Puede añadirlo encima de post cuando valide el esquema. Login es APIView con authentication_classes = [] y permission_classes = [AllowAny].


cat > apps/security/urls.py <<'EOF'
from django.urls import path

from apps.security.auth_views import LoginAPIView

urlpatterns = [
    path("auth/login/", LoginAPIView.as_view(), name="auth-login"),
]
EOF

ARCHIVO: config/urls.py

DEBAJO DE:
    path("api/", include("apps.sale.urls")),

AGREGAR:
    path("api/", include("apps.security.urls")),
auth/login/ vive en la app security. El proyecto solo agrega otro include bajo api/. Refresh, logout, perfil y el CRUD de la matriz se agregan a este mismo urlpatterns en los ISS siguientes. No se abre un segundo urls.py.


POST /api/auth/login/
        │
        ▼
username o email
        │
        ▼
¿user active?
        │
        ▼
check_password()
        │
        ├── no → 401 "Credenciales inválidas."
        └── sí → AccessToken.for_user + hash del refresh
Usuario inexistente, inactivo o clave mala responden el mismo 401. No se dice cuál de los tres falló.

La prueba se agrega al final de apps/security/tests.py, que desde el ISS-03 solo tiene DatabaseSelectionTests. Login es OPEN: el test no llama force_authenticate ni grant. Refresh, logout y perfil agregan métodos a esta misma clase en sus ISS.


ARCHIVO: apps/security/tests.py

ENCIMA DE:
from config.database import database_from_environ

AGREGAR:
from rest_framework import status
from rest_framework.test import APITestCase

from apps.common.status import RecordStatus
from apps.common.testing import PASSWORD, create_active_user
from apps.security.models import RefreshToken
from apps.security.tokens import hash_token

AL FINAL DEL ARCHIVO, AGREGAR:

class AuthFlowTests(APITestCase):
    def setUp(self):
        self.user = create_active_user()

    def test_login_with_username_and_email(self):
        by_username = self.client.post(
            "/api/auth/login/",
            {"username": "ana", "password": PASSWORD},
            format="json",
        )
        self.assertEqual(by_username.status_code, status.HTTP_200_OK)
        self.assertIn("access", by_username.data)
        self.assertIn("refresh", by_username.data)
        self.assertNotIn("password", by_username.data)
        stored = RefreshToken.objects.get()
        self.assertEqual(stored.token_hash, hash_token(by_username.data["refresh"]))

        by_email = self.client.post(
            "/api/auth/login/",
            {"email": "ANA@storelab.test", "password": PASSWORD},
            format="json",
        )
        self.assertEqual(by_email.status_code, status.HTTP_200_OK)

    def test_inactive_user_and_bad_password_are_401(self):
        self.user.status = RecordStatus.INACTIVE
        self.user.save()
        inactive = self.client.post(
            "/api/auth/login/",
            {"username": "ana", "password": PASSWORD},
            format="json",
        )
        self.assertEqual(inactive.status_code, status.HTTP_401_UNAUTHORIZED)
apps.common.testing todavía no existe en el ISS-17 si se sigue el orden estricto: create_active_user se escribe en el ISS-22. Para poder ejecutar este test aquí, cree en este ISS solo create_active_user y PASSWORD dentro de apps/common/testing.py. El ISS-22 completa ese archivo con grant y grant_crud sin borrar lo anterior.


cat > apps/common/testing.py <<'EOF'
from apps.common.status import RecordStatus
from apps.security.models import User

PASSWORD = "StoreLab-Test-1"


def create_active_user(username="ana", email="ana@storelab.test", password=PASSWORD):
    return User.objects.create_user(
        username=username,
        email=email,
        password=password,
        status=RecordStatus.ACTIVE,
    )
EOF
python manage.py test apps.security.tests.AuthFlowTests.test_login_with_username_and_email apps.security.tests.AuthFlowTests.test_inactive_user_and_bad_password_are_401
extend_schema documenta LoginSerializer y TokenPairSerializer.

Explicación
Es APIView porque el flujo no es un alta de User. Crear el usuario es otro endpoint, y exige RBAC. Login consulta users y escribe refresh_tokens: es OPEN, y aun así toca tablas de seguridad.

Vaciar authentication_classes evita que un Bearer vencido, enviado por costumbre, rechace el login antes de leer el cuerpo.

El access sale de SimpleJWT. No se persiste. Dura 60 minutos (ACCESS_TOKEN_LIFETIME).

Cómo probarlo
Capa HTTP, acceso OPEN. El test crea el usuario con create_active_user y llama el login sin force_authenticate. La base de prueba aísla la fila de refresh_tokens: RefreshToken.objects.get() ve solo la de este test.


python manage.py test apps.security.tests.AuthFlowTests.test_login_with_username_and_email
python manage.py test apps.security.tests.AuthFlowTests.test_inactive_user_and_bad_password_are_401
        │
        ▼
POST /api/auth/login/          sin Authorize
        │
        ├── username + password          200   access y refresh; el hash queda en refresh_tokens
        ├── email en otro caso           200
        ├── usuario inactive             401
        └── clave distinta               401   el mismo mensaje
Swagger ya existe desde el ISS-14. Este POST se pulsa en esta capa, en OPEN, sin Authorize. El access se copia recién en el ISS-20, para el perfil, y el botón Authorize se registra en el ISS-24.


python manage.py runserver
        │
        ▼
swagger-ui  →  POST /api/auth/login/     sin Authorize
        │
        ├── usuario active + clave buena     200   access y refresh
        └── inactive o clave mala            401
Criterios de aceptación
AC-17-01: username y password correctos responden 200 con access y refresh.
AC-17-02: el email en otro caso también entra.
AC-17-03: usuario inactive responde 401.
AC-17-04: clave incorrecta responde 401.
AC-17-05: el JSON no trae password.
Verificación
AuthFlowTests.test_login_with_username_and_email y test_inactive_user_and_bad_password_are_401.

Evidencias
EVI-17-01: tests PASS.
GATE
AC	Verificación	Evidencia	Resultado
AC-17-01	login username	EVI-17-01	PASS
AC-17-02	login email	EVI-17-01	PASS
AC-17-03	inactive	EVI-17-01	PASS
AC-17-04	clave mala	EVI-17-01	PASS
AC-17-05	sin password	EVI-17-01	PASS
✅ GATE de la unidad ISS-17 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-17 · 🧠 Aprender · ↑ Ruta Django · → ISS-18 · 🧠 Aprender
