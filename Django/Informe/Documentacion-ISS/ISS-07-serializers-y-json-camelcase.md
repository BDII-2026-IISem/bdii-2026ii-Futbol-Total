# ISS-07 - Serializers y JSON camelCase

> **Referencia PedalLibre.** Serializers de las entidades PedalLibre y nombres JSON definidos por la API. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Guía de estudio	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

ISS-07 — Serializers y JSON camelCase
Objetivo
Traducir modelos a JSON sin renombrar los campos Python.

Requisitos
ISS-06 superado.
Terminal con (.venv) activo.
Construcción
Hasta aquí el proyecto solo tiene Django. Estos tres paquetes son la API. Se instalan juntos porque el renderer camelCase y CORS se declaran en el mismo REST_FRAMEWORK.


source .venv/bin/activate
python -m pip install "djangorestframework==3.17.2" "djangorestframework-camel-case==1.4.2" "django-cors-headers==4.9.0"
python -m pip freeze > requirements.txt
djangorestframework aporta serializers, APIView, ModelViewSet y el cliente de pruebas. El import from rest_framework import serializers falla si este paso se salta.
djangorestframework-camel-case convierte created_at del modelo en createdAt del JSON, y al revés en el parser. El campo Python no se renombra.
django-cors-headers inserta CorsMiddleware. Sin él, un navegador en otro origen bloquea la API. El laboratorio permite todos los orígenes; producción debe listarlos.
Settings ya existe. DRF entra ahora, con permiso abierto: la Fase I no tiene JWT. El ISS-22 cambia ese default.


ARCHIVO: config/settings/__init__.py

ENCIMA DE:
    "apps.security.apps.SecurityConfig",

AGREGAR:
    "rest_framework",
    "corsheaders",

ENCIMA DE:
    "django.middleware.security.SecurityMiddleware",

AGREGAR:
    "corsheaders.middleware.CorsMiddleware",

DEBAJO DE:
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

AGREGAR:

CORS_ALLOW_ALL_ORIGINS = os.environ.get("CORS_ALLOW_ALL_ORIGINS", "True").strip().lower() in {
    "1",
    "true",
    "yes",
    "on",
}

REST_FRAMEWORK = {
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.AllowAny",
    ],
    "DEFAULT_RENDERER_CLASSES": [
        "djangorestframework_camel_case.render.CamelCaseJSONRenderer",
        "djangorestframework_camel_case.render.CamelCaseBrowsableAPIRenderer",
    ],
    "DEFAULT_PARSER_CLASSES": [
        "djangorestframework_camel_case.parser.CamelCaseJSONParser",
        "djangorestframework_camel_case.parser.CamelCaseFormParser",
        "djangorestframework_camel_case.parser.CamelCaseMultiPartParser",
    ],
    "DEFAULT_PAGINATION_CLASS": None,
}
Los tres serializers.py no existen: startapp no los crea. sale/serializers.py en este ISS solo lee la venta. El alta transaccional se agrega en el ISS-11.


cat > apps/client/serializers.py <<'EOF'
from rest_framework import serializers

from apps.client.models import Client


class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = [
            "id",
            "name",
            "address",
            "phone",
            "email",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]
        extra_kwargs = {
            "name": {"min_length": 2, "max_length": 150},
            "email": {"required": False, "allow_null": True, "allow_blank": True},
            "address": {"required": False, "allow_null": True, "allow_blank": True},
            "phone": {"required": False, "allow_null": True, "allow_blank": True},
        }

    def validate_email(self, value):
        if value is None or str(value).strip() == "":
            return None
        return value.strip().lower()

    def validate(self, attrs):
        for field in ("address", "phone"):
            if attrs.get(field) == "":
                attrs[field] = None
        return attrs
EOF

cat > apps/product/serializers.py <<'EOF'
from rest_framework import serializers

from apps.product.models import Product, ProductType


class ProductTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductType
        fields = ["id", "name", "description", "status", "created_at", "updated_at"]
        read_only_fields = ["id", "created_at", "updated_at"]
        extra_kwargs = {
            "name": {"min_length": 2, "max_length": 100},
            "description": {"required": False, "allow_null": True, "allow_blank": True},
        }

    def validate_description(self, value):
        if value is None or str(value).strip() == "":
            return None
        return value


class ProductSerializer(serializers.ModelSerializer):
    product_type_id = serializers.PrimaryKeyRelatedField(
        source="product_type",
        queryset=ProductType.objects.all(),
    )
    product_type_name = serializers.CharField(source="product_type.name", read_only=True)

    class Meta:
        model = Product
        fields = [
            "id",
            "product_type_id",
            "product_type_name",
            "name",
            "description",
            "price",
            "stock",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "product_type_name", "created_at", "updated_at"]
        extra_kwargs = {
            "name": {"min_length": 2, "max_length": 120},
            "description": {"required": False, "allow_null": True, "allow_blank": True},
        }

    def validate_description(self, value):
        if value is None or str(value).strip() == "":
            return None
        return value
EOF

cat > apps/sale/serializers.py <<'EOF'
from rest_framework import serializers

from apps.sale.models import ProductSale, Sale


class ProductSaleSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)

    class Meta:
        model = ProductSale
        fields = [
            "id",
            "product",
            "product_name",
            "quantity",
            "unit_price",
            "line_total",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields


class SaleSerializer(serializers.ModelSerializer):
    client_name = serializers.CharField(source="client.name", read_only=True)
    lines = ProductSaleSerializer(many=True, read_only=True)

    class Meta:
        model = Sale
        fields = [
            "id",
            "client",
            "client_name",
            "sale_date",
            "subtotal",
            "tax",
            "discounts",
            "total",
            "status",
            "lines",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields
EOF
ClientSerializer no usa fields = "__all__". validate_email convierte blanco en None. ProductSerializer expone product_type_id escribible y product_type_name de solo lectura. En el cable se ven productTypeId y productTypeName.

Explicación

Python created_at  →  tabla created_at  →  JSON createdAt
El parser hace el camino inverso. Por eso response.data dentro de APIClient vuelve a mostrar created_at: el cliente de prueba parsea la respuesta con el mismo parser. La prueba del contrato lee response.content y exige createdAt.

No se usa djangorestframework-camel-case para imitar otro framework en el modelo. Solo en el borde HTTP.

Criterios de aceptación
AC-07-01: el cuerpo HTTP de un cliente contiene createdAt y no created_at.
AC-07-02: Maria@Example.com se guarda como maria@example.com.
AC-07-03: el producto informa productTypeName sin pedir un segundo query al cliente.
Verificación
ClientApiTests.test_create_defaults_and_persists y ProductApiTests.test_product_crud_and_available_filter.

Evidencias
EVI-07-01: aserción sobre response.content. PASS.
GATE
AC	Verificación	Evidencia	Resultado
AC-07-01	JSON camelCase	EVI-07-01	PASS
AC-07-02	email normalizado	test de cliente	PASS
AC-07-03	nombre del tipo	test de producto	PASS
✅ GATE de la unidad ISS-07 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-07 · 🧠 Aprender · ↑ Ruta Django · → ISS-08 · 🧠 Aprender
