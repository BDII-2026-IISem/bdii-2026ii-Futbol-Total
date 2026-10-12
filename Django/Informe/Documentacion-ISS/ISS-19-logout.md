# ISS-19 - Logout

> **Referencia PedalLibre.** Logout por invalidación de refresh tokens. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


[Guía de aprendizaje y video](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-19-aprendizaje/#video-explicativo) · [GATE](https://tecnogua.com/academic/site/backend2026/django/manual/20-ISS-19-logout/#gate)

## Objetivo

Invalidar el refresh presentado, sin guardar el access token.

## Requisitos

- ISS-18 superado.

## Construcción

`LogoutAPIView` es OPEN y recibe `{"refresh": "..."}`. Se agrega al archivo donde ya viven login y refresh.

```text
ARCHIVO: apps/security/auth_views.py

Ubicar el import de serializers y agregar LogoutSerializer.
Encima de `def _find_user(username, email):`, agregar LogoutAPIView.

hash desconocido       -> 401
token ya reemplazado   -> revoca la familia -> 401
cualquier otro caso   -> status inactive, revoked_at = ahora -> 204
```

El endpoint se publica desde `apps/security/urls.py`:

```python
from apps.security.auth_views import LoginAPIView, LogoutAPIView, RefreshAPIView

urlpatterns = [
    # ...
    path("auth/refresh/", RefreshAPIView.as_view(), name="auth-refresh"),
    path("auth/logout/", LogoutAPIView.as_view(), name="auth-logout"),
]
```

Un segundo logout del mismo token que no fue rotado vuelve a dejarlo inactivo y responde 204.

La prueba sigue en acceso OPEN:

```python
def test_logout_invalidates_refresh(self):
    login = self.client.post(
        "/api/auth/login/",
        {"username": "ana", "password": PASSWORD},
        format="json",
    )
    raw = login.data["refresh"]
    logout = self.client.post("/api/auth/logout/", {"refresh": raw}, format="json")
    self.assertEqual(logout.status_code, status.HTTP_204_NO_CONTENT)
    again = self.client.post("/api/auth/refresh/", {"refresh": raw}, format="json")
    self.assertEqual(again.status_code, status.HTTP_401_UNAUTHORIZED)
```

```bash
python manage.py test apps.security.tests.AuthFlowTests.test_logout_invalidates_refresh
```

## Explicación

Logout no pide access token: la credencial persistida de la sesión es el refresh. Cerrar la sesión de un dispositivo no tiene por qué cerrar otra familia. Un refresh presentado después de ser rotado es reuso; por ello apaga la familia y devuelve 401. No hay tabla de access tokens que limpiar.

```text
login -> refresh R, fila active en refresh_tokens
POST /api/auth/logout/  {refresh: R}  -> 204
POST /api/auth/refresh/ {refresh: R}  -> 401
```

En Swagger, sin Authorize, ejecute login, copie `refresh`, llame a logout y preséntelo de nuevo ante refresh. La última llamada responde 401.

## Criterios de aceptación

- AC-19-01: logout responde 204.
- AC-19-02: ese refresh ya no puede renovar; el siguiente refresh responde 401.

## Verificación y evidencias

`test_logout_invalidates_refresh` produce EVI-19-01 en PASS.

## GATE

| AC | Verificación | Evidencia | Resultado |
| :-- | :-- | :-- | :-- |
| AC-19-01 | HTTP 204 | EVI-19-01 | PASS |
| AC-19-02 | refresh posterior 401 | EVI-19-01 | PASS |

El GATE no añade criterios nuevos. En verde habilita ISS-20.
