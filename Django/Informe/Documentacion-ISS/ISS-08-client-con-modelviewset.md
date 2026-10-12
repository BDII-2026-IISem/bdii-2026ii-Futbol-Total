# ISS-08 - Client con ModelViewSet

> **Referencia PedalLibre.** CRUD de clientes PedalLibre y vínculo opcional con users. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Guía de estudio	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

ISS-08 — Client con ModelViewSet
Objetivo
Publicar el CRUD de clientes con el tipo de vista que corresponde a un recurso homogéneo.

Requisitos
ISS-07 superado.
Esta unidad es Fase I. El CRUD se publica sin JWT: permission_classes = [AllowAny]. Los tres accesos no existen todavía. El repositorio publicado ya pasó por el ISS-22 y ese mismo CRUD quedó en JWT con token + RBAC. Quien construye paso a paso aplica ese cierre recién en la Fase II.
Construcción
apps/client/views.py ya existe. En la Fase I el permiso es AllowAny. El ISS-22 lo reemplaza por IsAuthenticated y HasResourceAccess. No importe nada de apps.security todavía.


cat > apps/client/views.py <<'EOF'
from rest_framework import viewsets
from rest_framework.permissions import AllowAny

from apps.client.models import Client
from apps.client.serializers import ClientSerializer
from apps.common.status import RecordStatus


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    permission_classes = [AllowAny]
    lookup_value_converter = "int"

    def get_queryset(self):
        queryset = super().get_queryset()
        status_value = self.request.query_params.get("status")
        if status_value:
            queryset = queryset.filter(status=status_value)
        return queryset

    def perform_destroy(self, instance):
        instance.status = RecordStatus.INACTIVE
        instance.save(update_fields=["status", "updated_at"])
EOF
apps/client/tests.py también existe. Se reescribe en acceso OPEN: no hay setUp, no hay usuario y no hay grant. El ISS-22 agrega el setUp con JWT y RBAC. Hasta entonces POST, GET, PATCH y DELETE salen sin token.


cat > apps/client/tests.py <<'EOF'
import json

from rest_framework import status
from rest_framework.test import APITestCase

from apps.client.models import Client
from apps.common.status import RecordStatus


class ClientApiTests(APITestCase):
    def test_create_defaults_and_persists(self):
        response = self.client.post(
            "/api/clients/",
            {"name": "María García", "email": "Maria@Example.com", "phone": "3001234567"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["status"], RecordStatus.INACTIVE)
        self.assertEqual(response.data["email"], "maria@example.com")
        wire = json.loads(response.content)
        self.assertIn("createdAt", wire)
        self.assertNotIn("created_at", wire)
        stored = Client.objects.get(pk=response.data["id"])
        self.assertEqual(stored.name, "María García")

    def test_invalid_name_and_duplicate_email(self):
        invalid = self.client.post("/api/clients/", {"name": "A"}, format="json")
        self.assertEqual(invalid.status_code, status.HTTP_400_BAD_REQUEST)
        self.client.post(
            "/api/clients/",
            {"name": "Ana Ruiz", "email": "ana@example.com"},
            format="json",
        )
        duplicate = self.client.post(
            "/api/clients/",
            {"name": "Otra Ana", "email": "ana@example.com"},
            format="json",
        )
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)

    def test_soft_delete_keeps_the_row(self):
        created = self.client.post("/api/clients/", {"name": "Pedro León"}, format="json")
        deleted = self.client.delete(f"/api/clients/{created.data['id']}/")
        self.assertEqual(deleted.status_code, status.HTTP_204_NO_CONTENT)
        stored = Client.objects.get(pk=created.data["id"])
        self.assertEqual(stored.status, RecordStatus.INACTIVE)
        self.assertEqual(Client.objects.count(), 1)

    def test_list_retrieve_and_update(self):
        created = self.client.post(
            "/api/clients/",
            {"name": "Luisa Mora", "phone": "111"},
            format="json",
        )
        pk = created.data["id"]
        listed = self.client.get("/api/clients/")
        self.assertEqual(listed.status_code, status.HTTP_200_OK)
        detail = self.client.get(f"/api/clients/{pk}/")
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.data["name"], "Luisa Mora")
        updated = self.client.patch(
            f"/api/clients/{pk}/",
            {"phone": "222", "status": "active"},
            format="json",
        )
        self.assertEqual(updated.status_code, status.HTTP_200_OK)
        self.assertEqual(updated.data["status"], "active")
EOF

python manage.py test apps.client
Estas cuatro peticiones cubren el CRUD del cliente: alta, listado, detalle, actualización y baja lógica. El acceso de esta fase es OPEN.

La app no trae urls.py. Se crea ahora, porque es el primer endpoint.


cat > apps/client/urls.py <<'EOF'
from rest_framework.routers import SimpleRouter

from apps.client.views import ClientViewSet

router = SimpleRouter(use_regex_path=False)
router.register("clients", ClientViewSet, basename="client")

urlpatterns = router.urls
EOF
config/urls.py ya existe. No se regenera.


ARCHIVO: config/urls.py

UBICAR:
from django.urls import path

REEMPLAZAR POR:
from django.urls import include, path

DEBAJO DE:
    path("admin/", admin.site.urls),

AGREGAR:
    path("api/", include("apps.client.urls")),
El proyecto solo entrega el prefijo api/. La app entrega el recurso clients. Django concatena ambos: api/ + clients/ = /api/clients/.

SimpleRouter.register genera las dos rutas del CRUD y las deja en router.urls:


clients/              list, create
clients/<int:pk>/     retrieve, update, partial_update, destroy
use_regex_path=False pide convertidores de path(), no una expresión regular. lookup_value_converter = "int" del viewset convierte el segmento en <int:pk>. basename="client" nombra las rutas (client-list, client-detail) porque el queryset todavía no se usa para inferir el nombre.

No se usa DefaultRouter. Además de esas dos rutas publicaría una raíz de API, y cada app incluida en el mismo api/ intentaría ocupar esa raíz.

Explicación
ModelViewSet automatiza list, create, retrieve, update, partial_update y destroy. El único comportamiento propio es la baja lógica, y el punto de extensión idiomático es perform_destroy, no reescribir delete().

Se descartó APIView porque no hay una regla que el CRUD genérico no exprese. Se descartó partir el recurso en dos GenericAPIView: sería el mismo CRUD con más archivos.


GET/POST /api/clients/
GET/PUT/PATCH/DELETE /api/clients/<int:pk>/
        │
        ▼
   ClientViewSet
        │
        ▼
   ClientSerializer
        │
        ▼
   clients
El query ?status= filtra. Sin query se listan también los inactivos.

Cómo probarlo
Capa HTTP, acceso OPEN. No hace falta runserver. APITestCase llama la ruta dentro del proceso y Django crea una base de prueba que borra al terminar.


python manage.py test apps.client
        │
        ▼
ClientApiTests                 sin usuario, sin Bearer, sin grant
        │
        ├── POST   /api/clients/           201   status inactive, email en minúsculas
        ├── GET    /api/clients/           200   la fila aparece en la lista
        ├── GET    /api/clients/<id>/      200   el detalle conserva el nombre
        ├── PATCH  /api/clients/<id>/      200   phone y status cambian
        └── DELETE /api/clients/<id>/      204   la fila sigue, status inactive
Swagger todavía no existe: drf-spectacular entra en el ISS-14. Allí esta misma tabla se pulsa en acceso OPEN, sin token. Cuando el ISS-22 la cierre, ese clic pasa a pedir semilla y Authorize; ese segundo recorrido es el ISS-24.

Criterios de aceptación
AC-08-01: POST válido responde 201.
AC-08-02: el registro queda en la tabla.
AC-08-03: DELETE responde 204 y la fila sigue, con status=inactive.
AC-08-04: el cuerpo inválido responde 400.
Verificación
ClientApiTests.

Evidencias
EVI-08-01: tests de cliente PASS en PostgreSQL, MySQL y SQL Server.
GATE
AC	Verificación	Evidencia	Resultado
AC-08-01	POST	EVI-08-01	PASS
AC-08-02	Client.objects.get	EVI-08-01	PASS
AC-08-03	DELETE lógico	EVI-08-01	PASS
AC-08-04	nombre inválido	EVI-08-01	PASS
✅ GATE de la unidad ISS-08 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Evaluación del cuaderno
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-08 · 🧠 Aprender · ↑ Ruta Django · → ISS-09 · 🧠 Aprender
