# ISS-09 - Catálogo con ModelViewSet

> **Referencia PedalLibre.** CRUD de estaciones, bicicletas, puntos de anclaje y tarifas. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Guía de estudio	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

ISS-09 — Catálogo con ModelViewSet
Objetivo
Publicar tipos y productos con el mismo criterio de CRUD homogéneo.

Requisitos
ISS-08 superado.
Construcción
apps/product/views.py ya existe. Igual que en clientes, el permiso de esta fase es AllowAny.


cat > apps/product/views.py <<'EOF'
from rest_framework import viewsets
from rest_framework.permissions import AllowAny

from apps.common.status import RecordStatus
from apps.product.models import Product, ProductType
from apps.product.serializers import ProductSerializer, ProductTypeSerializer


class CatalogViewSet(viewsets.ModelViewSet):
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


class ProductTypeViewSet(CatalogViewSet):
    queryset = ProductType.objects.all()
    serializer_class = ProductTypeSerializer


class ProductViewSet(CatalogViewSet):
    queryset = Product.objects.select_related("product_type")
    serializer_class = ProductSerializer
EOF
AvailableProductListAPIView no va en este archivo todavía. El ISS-10 la agrega al final.


cat > apps/product/urls.py <<'EOF'
from rest_framework.routers import SimpleRouter

from apps.product.views import ProductTypeViewSet, ProductViewSet

router = SimpleRouter(use_regex_path=False)
router.register("product-types", ProductTypeViewSet, basename="product-type")
router.register("products", ProductViewSet, basename="product")

urlpatterns = router.urls
EOF

ARCHIVO: config/urls.py

DEBAJO DE:
    path("api/", include("apps.client.urls")),

AGREGAR:
    path("api/", include("apps.product.urls")),
Mismo mecanismo que en clientes: el proyecto no conoce product-types ni products. Solo vuelve a ceder el resto de api/ a otra lista. El router produce cuatro rutas, dos por recurso, con <int:pk> en el detalle. La ruta products/available/ no existe todavía; el ISS-10 la inserta delante de router.urls.

apps/product/tests.py existe desde startapp. Se reescribe en acceso OPEN. El setUp solo crea el tipo en el ORM para poder publicar productos; no autentica. El listado de disponibles se agrega en el ISS-10. El JWT y el grant_crud se agregan en el ISS-22.


cat > apps/product/tests.py <<'EOF'
from decimal import Decimal

from django.db.models.deletion import RestrictedError
from rest_framework.test import APITestCase

from apps.common.status import RecordStatus
from apps.product.models import Product, ProductType


class ProductApiTests(APITestCase):
    def setUp(self):
        self.product_type = ProductType.objects.create(name="Bebida", status=RecordStatus.ACTIVE)

    def test_product_type_crud(self):
        created = self.client.post(
            "/api/product-types/",
            {"name": "Lácteo", "description": "Fríos"},
            format="json",
        )
        self.assertEqual(created.status_code, 201)
        self.assertEqual(created.data["status"], RecordStatus.INACTIVE)
        pk = created.data["id"]
        self.assertEqual(self.client.get("/api/product-types/").status_code, 200)
        detail = self.client.get(f"/api/product-types/{pk}/")
        self.assertEqual(detail.data["name"], "Lácteo")
        updated = self.client.patch(
            f"/api/product-types/{pk}/",
            {"status": "active"},
            format="json",
        )
        self.assertEqual(updated.status_code, 200)
        deleted = self.client.delete(f"/api/product-types/{pk}/")
        self.assertEqual(deleted.status_code, 204)
        self.assertEqual(ProductType.objects.get(pk=pk).status, RecordStatus.INACTIVE)

    def test_product_retrieve_update_and_soft_delete(self):
        created = self.client.post(
            "/api/products/",
            {
                "productTypeId": self.product_type.id,
                "name": "Leche",
                "price": "3.20",
                "stock": 2,
                "status": "active",
            },
            format="json",
        )
        pk = created.data["id"]
        detail = self.client.get(f"/api/products/{pk}/")
        self.assertEqual(detail.status_code, 200)
        updated = self.client.patch(f"/api/products/{pk}/", {"stock": 9}, format="json")
        self.assertEqual(updated.status_code, 200)
        self.assertEqual(updated.data["stock"], 9)
        deleted = self.client.delete(f"/api/products/{pk}/")
        self.assertEqual(deleted.status_code, 204)
        self.assertEqual(Product.objects.get(pk=pk).status, RecordStatus.INACTIVE)

    def test_default_status_and_type_restriction(self):
        created = self.client.post(
            "/api/products/",
            {"productTypeId": self.product_type.id, "name": "Té", "price": "1.00"},
            format="json",
        )
        self.assertEqual(created.status_code, 201)
        self.assertEqual(created.data["status"], "inactive")
        self.assertEqual(created.data["stock"], 0)
        with self.assertRaises(RestrictedError):
            self.product_type.delete()

    def test_duplicate_product_name(self):
        payload = {"productTypeId": self.product_type.id, "name": "Café", "price": "3.00"}
        self.assertEqual(self.client.post("/api/products/", payload, format="json").status_code, 201)
        self.assertEqual(self.client.post("/api/products/", payload, format="json").status_code, 400)
        self.assertEqual(Product.objects.get(name="Café").price, Decimal("3.00"))
EOF

python manage.py test apps.product
Explicación
No se repite la discusión del ISS-08. El catálogo es el mismo tipo de recurso. Extraer CatalogViewSet evita copiar perform_destroy y no inventa una capa nueva: sigue siendo un ModelViewSet.

ProductSerializer exige productTypeId. Si el tipo no existe, DRF responde 400 antes de tocar la base.

Cómo probarlo
Capa HTTP, acceso OPEN. El setUp crea el tipo "Bebida" en el ORM para poder publicar productos. Ese alta de apoyo no pasa por la API. El CRUD del tipo "Lácteo" sí.


python manage.py test apps.product
        │
        ▼
ProductApiTests                sin Bearer
        │
        ├── /api/product-types/     POST GET GET/<id> PATCH DELETE
        │                              alta inactive → activa → baja lógica
        │
        └── /api/products/          POST GET/<id> PATCH DELETE
                                       productTypeId, stock, nombre duplicado = 400
                                       borrar el tipo con hijos = RestrictedError
GET /api/products/available/ todavía no se prueba. Entra en el ISS-10.

Swagger de tipos y productos, en OPEN y con el servidor encendido, es el ISS-14. Este ISS solo afirma el CRUD por HTTP. El mismo clic con token y semilla queda para el ISS-24, después del cierre del ISS-22.

Criterios de aceptación
AC-09-01: crear un producto activo con stock aparece en el catálogo.
AC-09-02: el nombre duplicado responde 400.
AC-09-03: el default de status es inactive y el de stock es 0.
Verificación
ProductApiTests.

Evidencias
EVI-09-01: tests de producto PASS en los tres motores ejecutados.
GATE
AC	Verificación	Evidencia	Resultado
AC-09-01	POST producto	EVI-09-01	PASS
AC-09-02	duplicado	EVI-09-01	PASS
AC-09-03	defaults	EVI-09-01	PASS
✅ GATE de la unidad ISS-09 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Evaluación del cuaderno
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-09 · 🧠 Aprender · ↑ Ruta Django · → ISS-10 · 🧠 Aprender
