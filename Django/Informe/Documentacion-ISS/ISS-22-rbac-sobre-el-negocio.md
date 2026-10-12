# ISS-22 - RBAC sobre el negocio

> **Referencia PedalLibre.** Protección de las APIs PedalLibre por el role_id de users. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-22/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

ISS-22 — RBAC sobre el negocio
Objetivo
Pasar el negocio de la Fase I al tercer acceso: JWT con token + RBAC. Hasta aquí esos endpoints no pedían JWT.

Requisitos
ISS-21 superado.
Las pruebas de negocio, que en la Fase I no enviaban token, ahora crean un usuario y llaman grant() o grant_crud().
Construcción
En cada viewset de client, product y sale, y en AvailableProductListAPIView, SaleRegisterAPIView y SaleCollectionAPIView:


ARCHIVO: apps/client/views.py
ARCHIVO: apps/product/views.py
ARCHIVO: apps/sale/views.py

UBICAR:
from rest_framework.permissions import AllowAny

REEMPLAZAR POR:
from rest_framework.permissions import IsAuthenticated

from apps.security.permissions import HasResourceAccess

UBICAR:
permission_classes = [AllowAny]

REEMPLAZAR POR:
permission_classes = [IsAuthenticated, HasResourceAccess]
Ese reemplazo se repite en cada archivo de vistas de negocio. Si un archivo no importa AllowAny porque ya heredó el permiso, se agrega el import de IsAuthenticated y HasResourceAccess y se escribe la misma lista.

En settings, el default deja de ser abierto:


ARCHIVO: config/settings/__init__.py

UBICAR:
        "rest_framework.permissions.AllowAny",

REEMPLAZAR POR:
        "rest_framework.permissions.IsAuthenticated",
Los tests de la Fase I no autenticaban. Ahora el setUp de cada uno crea un usuario y concede la ruta. apps/common/testing.py ya existe desde el ISS-17, con PASSWORD y create_active_user. Aquí se agregan grant y grant_crud, que necesitan Role, Resource y ResourceRole.


ARCHIVO: apps/common/testing.py

UBICAR:
from apps.common.status import RecordStatus
from apps.security.models import User

REEMPLAZAR POR:
from django.urls import resolve

from apps.common.status import RecordStatus
from apps.security.models import Resource, ResourceRole, Role, RoleUser, User

AL FINAL DEL ARCHIVO, DESPUÉS DE create_active_user, AGREGAR:

def grant(user, method, path, role_name=None):
    role, _created = Role.objects.get_or_create(
        name=role_name or f"test-role-{user.pk}",
        defaults={"description": "Rol de prueba", "status": RecordStatus.ACTIVE},
    )
    RoleUser.objects.get_or_create(
        role=role,
        user=user,
        defaults={"status": RecordStatus.ACTIVE},
    )
    match = resolve(path)
    resource, _created = Resource.objects.get_or_create(
        method=method.upper(),
        route=match.route,
        defaults={
            "name": f"{method.upper()} {match.route}",
            "status": RecordStatus.ACTIVE,
        },
    )
    ResourceRole.objects.get_or_create(
        resource=resource,
        role=role,
        defaults={"status": RecordStatus.ACTIVE},
    )
    return role


def grant_crud(user, collection, detail):
    grant(user, "GET", collection)
    grant(user, "POST", collection)
    for method in ("GET", "PUT", "PATCH", "DELETE"):
        grant(user, method, detail)

ARCHIVO: apps/client/tests.py

ENCIMA DE:
from apps.client.models import Client

AGREGAR:
from apps.common.testing import create_active_user, grant_crud

DENTRO DE class ClientApiTests, ENCIMA del primer método:

    def setUp(self):
        self.user = create_active_user()
        grant_crud(self.user, "/api/clients/", "/api/clients/1/")
        self.client.force_authenticate(user=self.user)
El catálogo y la venta reciben el mismo cierre. El setUp que ya creaba datos de negocio se conserva; encima se autentica y se concede.


ARCHIVO: apps/product/tests.py

ENCIMA DE:
from apps.product.models import Product, ProductType

AGREGAR:
from apps.common.testing import create_active_user, grant, grant_crud

DENTRO DE def setUp, ENCIMA DE self.product_type = ...:

        self.user = create_active_user(username="nora", email="nora@storelab.test")
        grant_crud(self.user, "/api/product-types/", "/api/product-types/1/")
        grant_crud(self.user, "/api/products/", "/api/products/1/")
        grant(self.user, "GET", "/api/products/available/")
        self.client.force_authenticate(user=self.user)

ARCHIVO: apps/sale/tests.py

ENCIMA DE:
from apps.client.models import Client

AGREGAR:
from apps.common.testing import create_active_user, grant

DENTRO DE def setUp, ENCIMA DE self.buyer = ...:

        self.user = create_active_user(username="leo", email="leo@storelab.test")
        grant(self.user, "GET", "/api/sales/")
        grant(self.user, "POST", "/api/sales/")
        grant(self.user, "GET", "/api/sales/1/")
        grant(self.user, "DELETE", "/api/sales/1/")
        self.client.force_authenticate(user=self.user)
La venta no concede PUT ni PATCH: el detalle no los publica. Sin esta concesión el POST que en la Fase I respondía 201 ahora responde 401 o 403. Login, refresh, logout y perfil no se tocan aquí.

El permiso global del proyecto también pasa a IsAuthenticated. Los tres accesos quedan así:


OPEN                    login, refresh, logout, esquema
                        AllowAny y authentication_classes vacías

JWT con token           perfil
                        IsAuthenticated

JWT con token + RBAC    client, product, sale
                        IsAuthenticated + HasResourceAccess
apps/common/testing.py crea el rol de prueba, el RoleUser, el Resource a partir de resolve(path).route y el ResourceRole, todos active.

Explicación
Este ISS no cambia la forma de la venta ni del cliente. Cambia quién puede ejecutarla. Un test que antes hacía POST directo ahora falla con 401 o 403 hasta que concede el método y la ruta. Ese fallo es la prueba de que el cierre quedó puesto.


Fase I — solo negocio          Fase II — este ISS
sin JWT                        JWT con token + RBAC
POST /api/clients/             el mismo POST, ahora con concesión
Cómo probarlo
Capa HTTP. Los métodos del ISS-08, ISS-09, ISS-10, ISS-11 e ISS-12 no se reescriben. Cambia el setUp: crea un usuario active, concede la ruta y llama force_authenticate. Sin ese bloque el mismo POST responde 401 o 403.


python manage.py test apps.client apps.product apps.sale
        │
        ▼
setUp
  create_active_user
  grant / grant_crud          resolve(path).route  →  Resource + ResourceRole
  force_authenticate
        │
        ▼
el mismo POST, GET, PATCH o DELETE de la Fase I
        │
        ├── con concesión     el código de la Fase I (201, 200, 204)
        └── sin concesión     403    la prueba de ese caso es RbacTests, en el ISS-25
Perfil no entra en este comando de negocio. Sigue en el ISS-20, solo con Bearer.

Swagger del negocio, que en el ISS-14 respondía sin token, cambia de capa aquí. El mismo clic sin Authorize pasa a 401. Con un token de un usuario sin concesión, a 403. La semilla y el botón Authorize llegan en el ISS-24; hasta entonces la prueba que concede y afirma el CRUD es el HTTP de este ISS.


ISS-14   swagger sin token     POST /api/clients/     201
ISS-22   swagger sin token     POST /api/clients/     401
         swagger con token
         y sin grant                                  403
         HTTP con grant_crud                          201
ISS-24   swagger con semilla
         y Authorize                                  201
Criterios de aceptación
AC-22-01: los tests de cliente, producto y venta siguen PASS con usuario concedido.
AC-22-02: sin concesión, clientes responde 403.
AC-22-03: perfil sigue sin consultar la matriz.
Verificación
Suite apps y RbacTests.

Evidencias
EVI-22-01: la suite apps queda en 30 tests. En PostgreSQL, OK. MySQL y SQL Server tenían 24 OK antes de estos casos de CRUD.
EVI-22-02: test_missing_grant_is_403_and_missing_identity_is_401.
GATE
AC	Verificación	Evidencia	Resultado
AC-22-01	negocio con RBAC	EVI-22-01	PASS
AC-22-02	deny by default	EVI-22-02	PASS
AC-22-03	perfil sigue en JWT con token	ProfileAPIView.permission_classes	PASS
✅ GATE de la unidad ISS-22 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-22 · 🧠 Aprender · ↑ Ruta Django · → ISS-23 · 🧠 Aprender
