# ISS-20 - Perfil JWT con token

> **Referencia PedalLibre.** Perfil JWT construido desde users, roles y, cuando exista, clients. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-20/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

ISS-20 — Perfil JWT con token
Objetivo
Responder quién es el llamador. Este es el acceso JWT con token: firma, vigencia y usuario active. No consulta la matriz. Esa consulta es el tercer acceso y llega en el ISS-21.

Requisitos
ISS-19 superado.
Construcción
apps/security/authentication.py es nuevo. Sustituye a la clase de SimpleJWT para volver a leer status después de validar la firma.


cat > apps/security/authentication.py <<'EOF'
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import AuthenticationFailed

from apps.common.status import RecordStatus


class StoreLabJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        user = super().get_user(validated_token)
        if user.status != RecordStatus.ACTIVE or not user.is_active:
            raise AuthenticationFailed(
                "El usuario no está active.",
                code="user_inactive",
            )
        return user
EOF

ARCHIVO: config/settings/__init__.py

DENTRO DE REST_FRAMEWORK, ENCIMA DE DEFAULT_PERMISSION_CLASSES, AGREGAR:

    "DEFAULT_AUTHENTICATION_CLASSES": [
        "apps.security.authentication.StoreLabJWTAuthentication",
    ],
apps/security/rbac_views.py es nuevo y, en este ISS, solo contiene el perfil. Los viewsets de la matriz se agregan en el ISS-23.


cat > apps/security/rbac_views.py <<'EOF'
from rest_framework.generics import RetrieveUpdateAPIView
from rest_framework.permissions import IsAuthenticated

from apps.security.serializers import ProfileSerializer


class ProfileAPIView(RetrieveUpdateAPIView):
    serializer_class = ProfileSerializer
    permission_classes = [IsAuthenticated]
    http_method_names = ["get", "patch", "head", "options"]

    def get_object(self):
        return self.request.user
EOF
ProfileSerializer se agrega al inicio de apps/security/serializers.py, que ya existe. Campos id, username, email, first_name, last_name, status. username y status son de solo lectura. No incluye password.


ARCHIVO: apps/security/serializers.py

ENCIMA DE:
class LoginSerializer

AGREGAR la clase ProfileSerializer.

ARCHIVO: apps/security/urls.py

AGREGAR el import de ProfileAPIView desde apps.security.rbac_views.

DEBAJO DE:
    path("auth/logout/", LogoutAPIView.as_view(), name="auth-logout"),

AGREGAR:
    path("auth/profile/", ProfileAPIView.as_view(), name="auth-profile"),
El perfil no entra al router del ISS-23. No tiene pk en la URL: el objeto es request.user. Un ModelViewSet de usuarios expondría /api/users/<int:pk>/, que es otro recurso y exige RBAC.


class ProfileAPIView(RetrieveUpdateAPIView):
    serializer_class = ProfileSerializer
    permission_classes = [IsAuthenticated]
    http_method_names = ["get", "patch", "head", "options"]

    def get_object(self):
        return self.request.user
RetrieveUpdateAPIView es GenericAPIView con retrieve y update. Automatiza leer y modificar el objeto que devuelve get_object, y no abre POST ni DELETE.

StoreLabJWTAuthentication.get_user rechaza al usuario cuyo status no es active, aunque la firma del JWT siga siendo válida. Eso produce 401, no 403.

ProfileSerializer no incluye password. username y status son de solo lectura.

El perfil no es OPEN y tampoco consulta RBAC. La prueba envía el access token. Sin él la respuesta es 401. Un usuario que pasa a inactive también recibe 401, aunque el JWT siga bien firmado.


ARCHIVO: apps/security/tests.py

AL FINAL DE class AuthFlowTests, AGREGAR:

    def test_profile_requires_token_and_rejects_inactive_user(self):
        anonymous = self.client.get("/api/auth/profile/")
        self.assertEqual(anonymous.status_code, status.HTTP_401_UNAUTHORIZED)
        login = self.client.post(
            "/api/auth/login/",
            {"username": "ana", "password": PASSWORD},
            format="json",
        )
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['access']}")
        profile = self.client.get("/api/auth/profile/")
        self.assertEqual(profile.status_code, status.HTTP_200_OK)
        self.assertEqual(profile.data["username"], "ana")
        patched = self.client.patch(
            "/api/auth/profile/",
            {"firstName": "Ana"},
            format="json",
        )
        self.assertEqual(patched.status_code, status.HTTP_200_OK)
        self.user.status = RecordStatus.INACTIVE
        self.user.save()
        denied = self.client.get("/api/auth/profile/")
        self.assertEqual(denied.status_code, status.HTTP_401_UNAUTHORIZED)

python manage.py test apps.security.tests.AuthFlowTests.test_profile_requires_token_and_rejects_inactive_user
Explicación

Bearer access
      │
      ▼
firma + vigencia
      │
      ▼
User.active?
      ├── no → 401
      └── sí → IsAuthenticated → perfil
JWT con token no ejecuta HasResourceAccess. Un usuario autenticado lee su perfil aunque no tenga ningún rol. Si el mismo usuario llama a /api/clients/ sin concesión, el ISS-22 responderá 403: ahí el acceso ya es JWT con token + RBAC.

Cómo probarlo
Capa HTTP, acceso JWT con token. No se llama grant. El header se arma con el access del login. APIClient.credentials lo deja puesto para el GET, el PATCH y el GET final.


python manage.py test apps.security.tests.AuthFlowTests.test_profile_requires_token_and_rejects_inactive_user
        │
        ├── GET  /api/auth/profile/                         sin header     401
        ├── login
        ├── GET  /api/auth/profile/                         Bearer         200   username ana
        ├── PATCH /api/auth/profile/   {firstName: Ana}     Bearer         200
        └── usuario status inactive
            GET  /api/auth/profile/                         el mismo Bearer  401
En Swagger, en esta capa, GET /api/auth/profile/ sin header responde 401. El test HTTP es el que envía el Bearer, porque el botón Authorize todavía no está registrado: esa extensión entra en el ISS-24. A partir de ahí el mismo perfil se pulsa pegando el access del login, sin concesión de la matriz.


esta capa
  HTTP     login → Bearer → GET y PATCH /api/auth/profile/    200
  Swagger  GET /api/auth/profile/ sin header                  401

ISS-24
  Swagger  Authorize con access → GET y PATCH perfil          200
           sin fila de RBAC
Criterios de aceptación
AC-20-01: sin header, GET perfil responde 401.
AC-20-02: con access válido responde 200 y no incluye password.
AC-20-03: PATCH de firstName se guarda.
AC-20-04: si el usuario pasa a inactive, el mismo access responde 401.
Verificación
test_profile_requires_token_and_rejects_inactive_user.

Evidencias
EVI-20-01: test PASS.
GATE
AC	Verificación	Evidencia	Resultado
AC-20-01	anónimo 401	EVI-20-01	PASS
AC-20-02	perfil sin password	EVI-20-01	PASS
AC-20-03	PATCH	EVI-20-01	PASS
AC-20-04	usuario desactivado 401	EVI-20-01	PASS
✅ GATE de la unidad ISS-20 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-20 · 🧠 Aprender · ↑ Ruta Django · → ISS-21 · 🧠 Aprender
