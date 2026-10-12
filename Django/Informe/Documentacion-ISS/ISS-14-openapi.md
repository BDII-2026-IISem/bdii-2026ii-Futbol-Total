# ISS-14 - OpenAPI

> **Referencia PedalLibre.** OpenAPI de clientes, estaciones, bicicletas, reservas, alquileres y pagos. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-14/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

El propio ISS técnico cierra aquí la Fase I — Business (sección «Cierre de la Fase I — Business»). No hay una unidad de cierre aparte.

ISS-14 — OpenAPI
Objetivo
Publicar el contrato en un esquema que se genere desde las vistas, no desde un YAML escrito a mano.

Requisitos
ISS-13 superado.
drf-spectacular 0.30.
Construcción
drf-spectacular lee las vistas y escribe OpenAPI. La versión queda fijada: sin pin, pip puede subir a una serie que ya no cubre DRF 3.17.


source .venv/bin/activate
python -m pip install "drf-spectacular==0.30.0"
python -m pip freeze > requirements.txt
El paquete se llama drf-spectacular en pip y drf_spectacular en Python. Settings y las rutas usan el nombre con guion bajo.

Settings ya existe. En este momento REST_FRAMEWORK todavía no tiene JWT: eso es el ISS-15 y el ISS-20. Aquí solo se registra el esquema.


ARCHIVO: config/settings/__init__.py

DEBAJO DE:
    "rest_framework",

AGREGAR:
    "drf_spectacular",

DENTRO DE REST_FRAMEWORK, DEBAJO DE la lista DEFAULT_PARSER_CLASSES, AGREGAR:
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",

AL FINAL DEL ARCHIVO, AGREGAR:

SPECTACULAR_SETTINGS = {
    "TITLE": "StoreLab API",
    "DESCRIPTION": "API REST de StoreLab.",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "COMPONENT_SPLIT_REQUEST": True,
    "CAMELIZE_NAMES": True,
    "POSTPROCESSING_HOOKS": [
        "drf_spectacular.hooks.postprocess_schema_enums",
        "drf_spectacular.contrib.djangorestframework_camel_case.camelize_serializer_fields",
    ],
    "SERVE_PERMISSIONS": ["rest_framework.permissions.AllowAny"],
    "SWAGGER_UI_SETTINGS": {"persistAuthorization": True},
}
SERVE_PERMISSIONS deja el esquema en acceso abierto. camelize_serializer_fields alinea el YAML con el JSON createdAt. SERVE_INCLUDE_SCHEMA en falso evita duplicar el esquema dentro de Swagger.

El esquema no pertenece a una app de negocio, así que sus rutas se parchean en el URLconf raíz, no en apps/*/urls.py.


ARCHIVO: config/urls.py

DEBAJO DE:
from django.urls import include, path

AGREGAR:
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

DEBAJO DE:
    path("admin/", admin.site.urls),

AGREGAR, ANTES de los include("apps...."):
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path(
        "api/schema/swagger-ui/",
        SpectacularSwaggerView.as_view(url_name="schema"),
        name="swagger-ui",
    ),
    path(
        "api/schema/redoc/",
        SpectacularRedocView.as_view(url_name="schema"),
        name="redoc",
    ),
Quedan delante de los include de las apps. Esas tres rutas son literales y no chocan con clients ni products, pero vivir en el proyecto deja claro que documentan la API completa y no un recurso de client o product.

El CRUD de cada tabla ya quedó afirmado por HTTP en su ISS, en acceso OPEN. Swagger nace aquí y se recorre sobre esa misma capa: sin login, sin Authorize y sin semilla.


GET /api/schema/
GET /api/schema/swagger-ui/
GET /api/schema/redoc/
SERVE_PERMISSIONS de spectacular queda en AllowAny. En la Fase I eso solo significa que el esquema se puede abrir: todavía no hay JWT. En la Fase II esta documentación permanece en el acceso OPEN. El permiso global del proyecto, cuando la Fase II lo fije, será IsAuthenticated; estas tres rutas no lo heredan.

El hook camelize_serializer_fields alinea el esquema con el JSON camelCase.


python manage.py spectacular --file /tmp/storelab-schema.yml --validate
Explicación
Spectacular lee serializers, queryset y extend_schema. Una APIView que construye el serializer por dentro no se adivina: login, refresh, logout y la colección de ventas declaran extend_schema. Sin eso, --validate reportaba errores de serializer.

La clase StoreLabJWTAuthentication necesita OpenApiAuthenticationExtension en apps/security/schema.py, cargada desde SecurityConfig.ready(). SimpleJWT solo registra su propia clase, no las subclases. Ese botón Authorize se usa desde el ISS-24. En esta capa no hay JWT.

Cómo probarlo
Capa Swagger, acceso OPEN. Hace falta el servidor. Las aserciones de stock, precio y baja lógica siguen siendo los tests HTTP de los ISS-08 a ISS-12.


python manage.py runserver
Abra http://127.0.0.1:8000/api/schema/swagger-ui/. No pulse Authorize: todavía no hay token.


swagger-ui                         sin token
        │
        ├── /api/clients/              POST, GET, GET/{id}, PATCH, DELETE
        ├── /api/product-types/        el mismo CRUD
        ├── /api/products/             el mismo CRUD
        ├── GET /api/products/available/
        └── /api/sales/                POST y GET
            GET y DELETE /api/sales/{id}/
                    │
                    └── lines          product_sales, sin ruta propia
El orden es tipo, producto, cliente y entonces la venta. Un producto disponible pide status active y stock mayor que cero. El alta de cliente y de tipo nace inactive si el cuerpo no envía status.

Cuando el ISS-22 cambie estas rutas a JWT con token + RBAC, este mismo clic sin token dejará de responder 201. El recorrido con semilla y Authorize es el ISS-24.

Criterios de aceptación
AC-14-01: spectacular --validate termina sin errores.
AC-14-02: Swagger y el esquema son accesibles sin Bearer.
AC-14-03: el esquema describe el cuerpo camelCase.
Verificación
python manage.py spectacular --validate salió con código 0 después de los extend_schema y de la extensión Bearer.

Evidencias
EVI-14-01: exit code 0 de --validate.
GATE
AC	Verificación	Evidencia	Resultado
AC-14-01	validate	EVI-14-01	PASS
AC-14-02	SERVE_PERMISSIONS AllowAny	settings de spectacular	PASS
AC-14-03	hook camelCase	SPECTACULAR_SETTINGS	PASS
Cierre de la Fase I — Business
Esta fase es solo negocio. No hay login, no hay JWT y no hay RBAC. Los tres accesos de la API se definen en la Fase II.

Qué queda construido
Clientes, tipos, productos, ventas y detalles. Relaciones RESTRICT. Precio histórico. Stock dentro de transaction.atomic(). Baja lógica. Admin de inspección. OpenAPI del negocio.

Durante la construcción, los endpoints de client, product y sale quedan en AllowAny. Quien sigue el manual no les pone token. El repositorio publicado ya pasó por el ISS-22, así que esas mismas rutas exigen JWT con token + RBAC. El GATE de esta fase, corrido sobre ese código, usa un usuario de prueba con la concesión correspondiente. Comprueba las reglas de negocio. No certifica la autenticación: eso es el cierre de la Fase II, al final del ISS-25.

Verificación integral

python manage.py check
python manage.py migrate
python manage.py test apps.client apps.product apps.sale
La suite completa, que también incluye seguridad, dio 24 tests OK en PostgreSQL, MySQL y SQL Server.

Pieza	Resultado
Client CRUD y baja lógica	PASS
ProductType / Product y RestrictedError	PASS
Disponibles	PASS
Venta, tax 0, precio histórico, rollback, anulación	PASS
Migraciones en storelab_django	PASS
spectacular --validate	PASS
Oracle extremo a extremo	NO VERIFICADO EN ESTE ENTORNO
GATE BUSINESS
AC	Verificación	Evidencia	Resultado
Modelos y relaciones	migraciones y tests	suite	PASS
Transacción y stock	SaleTransactionTests	suite	PASS
Serializers y camelCase	test de response.content	suite	PASS
Tres estilos de vista usados con motivo	ISS-08, ISS-10, ISS-11	código	PASS
Multidialecto ejecutado	PostgreSQL, MySQL, SQL Server	multidialect.md	PASS en tres motores
Oracle	conexión real	ORA-28000 / ORA-01017	NO VERIFICADO
El GATE de negocio se considera superado para los motores ejecutados. No autoriza a decir que Oracle ya corrió el laboratorio. No se abre la Fase II si este GATE tiene algún FAIL.

✅ GATE de la unidad ISS-14 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-14 · 🧠 Aprender · ↑ Ruta Django · → ISS-15 · 🧠 Aprender
