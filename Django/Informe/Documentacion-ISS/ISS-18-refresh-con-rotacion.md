# ISS-18 - Refresh con rotación

> **Referencia PedalLibre.** Rotación de refresh tokens de autenticación. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.

[🧠 Comprender este bloque y ver el video →](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-18-aprendizaje/#video-explicativo) · [✅ GATE de la unidad](https://tecnogua.com/academic/site/backend2026/django/manual/19-ISS-18-refresh-con-rotacion/#gate)
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.
Material de aprendizaje. La elaboración pedagógica y el video F5 están en [🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-18-aprendizaje/#video-explicativo). No forman parte del manual original: material/django/iss/ISS-18/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.
Cambiar el refresh en cada uso y tratar la reutilización como revocación de la familia.
- ISS-17 superado.
RefreshAPIView también es OPEN y APIView. Busca la fila por hash dentro de select_for_update().
```
ARCHIVO: apps/security/urls.py

UBICAR:
from apps.security.auth_views import LoginAPIView

REEMPLAZAR POR:
from apps.security.auth_views import LoginAPIView, RefreshAPIView

DEBAJO DE:
    path("auth/login/", LoginAPIView.as_view(), name="auth-login"),

AGREGAR:
    path("auth/refresh/", RefreshAPIView.as_view(), name="auth-refresh"),

```
config/urls.py no se toca. El include del ISS-17 ya entrega api/ a esta lista.
La vista también se agrega al archivo que ya existe, encima de _find_user. Hace falta importar transaction y RefreshSerializer.
```
ARCHIVO: apps/security/auth_views.py

UBICAR:
from django.utils import timezone

REEMPLAZAR POR:
from django.db import transaction
from django.utils import timezone

UBICAR:
from apps.security.serializers import LoginSerializer, TokenPairSerializer

REEMPLAZAR POR:
from apps.security.serializers import LoginSerializer, RefreshSerializer, TokenPairSerializer

ENCIMA DE:
def _find_user(username, email):

AGREGAR la clase RefreshAPIView: OPEN, APIView, busca por hash con select_for_update,
revoca la familia si el token ya fue rotado, y si está vigente emite otro par
de la misma familia marcando el anterior con replaced_by.

```
```
no existe                         → 401
ya rotado, revocado o inactivo    → revoca la familia → 401
vencido                           → inactiva ese token → 401
usuario inactive                  → inactiva ese token → 401
vigente                           → emite otro par de la misma familia
                                    marca el anterior replaced_by

```
La prueba sigue en OPEN y entra en la clase AuthFlowTests del ISS-17.
```
ARCHIVO: apps/security/tests.py

AL FINAL DE class AuthFlowTests, AGREGAR:

    def test_refresh_rotates_and_reuse_revokes_family(self):
        login = self.client.post(
            "/api/auth/login/",
            {"username": "ana", "password": PASSWORD},
            format="json",
        )
        first = login.data["refresh"]
        rotated = self.client.post("/api/auth/refresh/", {"refresh": first}, format="json")
        self.assertEqual(rotated.status_code, status.HTTP_200_OK)
        second = rotated.data["refresh"]
        self.assertNotEqual(first, second)
        reused = self.client.post("/api/auth/refresh/", {"refresh": first}, format="json")
        self.assertEqual(reused.status_code, status.HTTP_401_UNAUTHORIZED)
        after_reuse = self.client.post("/api/auth/refresh/", {"refresh": second}, format="json")
        self.assertEqual(after_reuse.status_code, status.HTTP_401_UNAUTHORIZED)

```
```
python manage.py test apps.security.tests.AuthFlowTests.test_refresh_rotates_and_reuse_revokes_family

```
Rotar sin detectar reuso deja vivo el token robado. Si el token viejo vuelve a presentarse, se asume que alguien más lo tiene y se apagan todos los de esa family_id, incluido el que acaba de emitirse al cliente legítimo. Ese cliente tendrá que volver a login. Es la política elegida; no es la blacklist de SimpleJWT.
El vencimiento no revoca la familia: un token expirado no prueba que se haya copiado.
Capa HTTP, acceso OPEN. El test hace login para obtener un refresh y no guarda el access. Tres POST siguen a la misma ruta.
```
python manage.py test apps.security.tests.AuthFlowTests.test_refresh_rotates_and_reuse_revokes_family
        │
        ▼
login  →  refresh A
        │
        ▼
POST /api/auth/refresh/   {refresh: A}     200   devuelve B, A queda replaced_by
        │
        ▼
POST /api/auth/refresh/   {refresh: A}     401   reuso: se apaga la familia
        │
        ▼
POST /api/auth/refresh/   {refresh: B}     401   B también murió con la familia

```
En Swagger, en esta misma capa y sin Authorize: haga login, copie refresh y llame tres veces a POST /api/auth/refresh/ con A, otra vez con A y luego con B. El resultado visual es 200, 401 y 401.
```
swagger-ui   OPEN
  login → refresh A
  POST /api/auth/refresh/  A    200  → B
  POST /api/auth/refresh/  A    401
  POST /api/auth/refresh/  B    401

```
- AC-18-01: el segundo refresh es distinto del primero y el primero responde 200 la primera vez.
- AC-18-02: reusar el primero responde 401.
- AC-18-03: el segundo, ya comprometida la familia, también responde 401.
test_refresh_rotates_and_reuse_revokes_family.
- EVI-18-01: test PASS.
✅ GATE de la unidad ISS-18 — este bloque no añade ningún criterio nuevo.
Las condiciones de cierre son las de esta misma página:
- 📋 Criterios de aceptación → [Criterios de aceptación](https://tecnogua.com/academic/site/backend2026/django/manual/19-ISS-18-refresh-con-rotacion/#criterios-de-aceptacion)
- ✅ GATE → [GATE](https://tecnogua.com/academic/site/backend2026/django/manual/19-ISS-18-refresh-con-rotacion/#gate)
- 🔎 Verificación → [Verificación](https://tecnogua.com/academic/site/backend2026/django/manual/19-ISS-18-refresh-con-rotacion/#verificacion)
- 🧠 Autoevaluación → [Preguntas de Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-18-aprendizaje/#preguntas-de-comprension)
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.
Navegación de la ruta: ← [ISS-18 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-18-aprendizaje/) · [↑ Ruta Django](https://tecnogua.com/academic/site/backend2026/django/) · → [ISS-19 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-19-aprendizaje/)
