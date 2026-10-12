# ISS-24 - Semilla RBAC y Swagger con Bearer

> **Referencia PedalLibre.** Semillas de roles y usuarios de PedalLibre, y Swagger con Bearer. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-24/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

ISS-24 — Semilla RBAC y Swagger con Bearer
Objetivo
Cargar la matriz desde las rutas reales y permitir probar el JWT en Swagger.

Requisitos
ISS-23 superado.
Construcción
apps/security/schema.py es nuevo:


cat > apps/security/schema.py <<'EOF'
from drf_spectacular.extensions import OpenApiAuthenticationExtension


class StoreLabJWTScheme(OpenApiAuthenticationExtension):
    target_class = "apps.security.authentication.StoreLabJWTAuthentication"
    name = "bearerAuth"

    def get_security_definition(self, auto_schema):
        return {"type": "http", "scheme": "bearer", "bearerFormat": "JWT"}
EOF
apps/security/apps.py ya existe. El ready carga esa extensión.


ARCHIVO: apps/security/apps.py

DEBAJO DE:
    label = "security"

AGREGAR:

    def ready(self):
        from apps.security import schema  # noqa: F401
El comando es un archivo nuevo. Django descubre management/commands si existen los __init__.py.


mkdir -p apps/security/management/commands
cat > apps/security/management/__init__.py <<'EOF'
EOF
cat > apps/security/management/commands/__init__.py <<'EOF'
EOF
seed_rbac.py es nuevo. Recorre una lista de método + path de muestra, llama resolve(sample).route y hace get_or_create del recurso y de la concesión del rol admin. Si se pasa --username, crea el RoleUser. La lista debe cubrir clients, product-types, products, products/available, sales (GET y POST en la colección; GET y DELETE en el detalle) y el CRUD de users, roles, role-users, resources y resource-roles. No incluya login, refresh, logout ni perfil: esos accesos no son RBAC.


python manage.py seed_rbac
python manage.py seed_rbac --username admin
El comando recorre una lista de métodos y paths de muestra, llama resolve() y hace get_or_create de Resource por (method, route). Crea o reactiva el rol admin y le concede todos esos recursos. Si se pasa --username, crea el RoleUser de ese usuario.

apps/security/schema.py:


class StoreLabJWTScheme(OpenApiAuthenticationExtension):
    target_class = "apps.security.authentication.StoreLabJWTAuthentication"
    name = "bearerAuth"
SecurityConfig.ready() importa ese módulo. En Swagger, Authorize recibe el access token. No se pega la palabra Bearer; el esquema ya es http / bearer.

Dos formas de probar cada tabla
El HTTP de cada tabla ya se corrió en su ISS, con el acceso de esa capa. Esta unidad no lo repite.

Swagger del negocio en OPEN ya se recorrió en el ISS-14. Login, refresh y logout, también en OPEN, en los ISS-17, ISS-18 e ISS-19. Aquí cambia la capa: el negocio y la matriz son JWT con token + RBAC, el perfil es JWT con token, y el botón Authorize ya existe. La semilla concede el rol admin para que esos clics dejen de responder 403.


python manage.py seed_rbac --username admin
python manage.py runserver
El usuario admin tiene que existir antes, por createsuperuser del ISS-13, y su status debe estar active. Abra http://127.0.0.1:8000/api/schema/swagger-ui/.

Ejecute POST /api/auth/login/ sin Authorize. El acceso es OPEN. Copie solo el valor de access.
Pulse Authorize y pegue ese valor. El esquema ya envía Bearer.
Con el admin autorizado, arme un usuario de prueba y no se quede en el CRUD. Cree el rol, asigne ese rol en POST /api/role-users/, cree el recurso GET + api/clients/ y asígnelo en POST /api/resource-roles/. Salga de Authorize, haga login con ese usuario y ejecute GET /api/clients/: responde 200. POST /api/clients/ sigue en 403 si no concedió POST.
Recorra el resto de las tablas de abajo. El orden del negocio es tipo, producto, cliente y entonces la venta.
Tabla	Dónde en Swagger	Acceso	Qué mirar
refresh_tokens	POST /api/auth/login/, luego POST /api/auth/refresh/ y POST /api/auth/logout/	OPEN	No hay CRUD de esta tabla. Login crea la fila. Refresh rota el valor. Logout deja de aceptar ese refresh
clients	/api/clients/	JWT con token + RBAC	POST, GET de la lista, GET del id, PATCH y DELETE. El DELETE deja la fila inactive
product_types	/api/product-types/	JWT con token + RBAC	El mismo CRUD. El alta nace inactive si no se envía status
products	/api/products/ y GET /api/products/available/	JWT con token + RBAC	El cuerpo lleva productTypeId. Available solo lista activos con stock mayor que cero
sales	POST y GET /api/sales/, GET y DELETE /api/sales/{id}/	JWT con token + RBAC	No hay PUT ni PATCH. El cuerpo lleva clientId, saleDate, discounts e items
product_sales	dentro de la respuesta de la venta, en lines	el de la venta	No hay ruta propia. Ahí se ven unitPrice y lineTotal
users	/api/users/	JWT con token + RBAC	POST con password. La respuesta no devuelve la contraseña
roles	/api/roles/	JWT con token + RBAC	CRUD completo
role_users	/api/role-users/	JWT con token + RBAC	Asigna un rol ya creado a un usuario ya creado. Sin este enlace el usuario no hereda permisos
resources	/api/resources/	JWT con token + RBAC	method en mayúsculas y route con el patrón, por ejemplo api/clients/
resource_roles	/api/resource-roles/	JWT con token + RBAC	Asigna ese recurso al rol. Es el permiso. Después, entre con el usuario asignado y ejecute la ruta
perfil	GET y PATCH /api/auth/profile/	JWT con token	El mismo Authorize. No pide una fila de la matriz
Si Authorize está vacío, clientes y el resto de la matriz responden 401. Con token de un usuario sin el rol admin, responden 403. Login, refresh, logout y el esquema siguen abriendo sin token.

Cómo probarlo
Capa Swagger de esta unidad: semilla, Authorize y el acceso que cada ruta tiene ahora. El HTTP que afirma stock, precio, baja lógica y 401 frente a 403 sigue en su ISS.


createsuperuser  →  usuario admin active
        │
        ▼
python manage.py seed_rbac --username admin
        │
        ▼
python manage.py runserver
        │
        ▼
GET /api/schema/swagger-ui/          OPEN, sin token
        │
        ▼
POST /api/auth/login/                copiar access
        │
        ▼
Authorize                            pegar el access, sin escribir Bearer
        │
        ├── OPEN                     refresh, logout y el propio esquema
        ├── JWT con token            /api/auth/profile/
        └── JWT con token + RBAC
              users → roles → role-users          asigna el rol al usuario
              resources → resource-roles          asigna GET api/clients/ al rol
              login de ese usuario
              GET /api/clients/                   200
              POST /api/clients/                  403 si el recurso no incluye POST
              y el resto: product-types, products, available, sales
El negocio sigue el orden tipo, producto, cliente y venta. product_sales se lee en lines. refresh_tokens se observa al encadenar login, refresh y logout. La asignación de arriba es la misma cadena que el HTTP del ISS-23 ya afirmó.

Explicación
Sembrar rutas a mano como texto /api/clients/1/ se rompe en cuanto el convertidor cambia. resolve().route es la misma cadena que verá el permiso en la petición. La semilla y el permiso no pueden divergir.

Swagger queda OPEN para poder abrir la documentación. Las operaciones RBAC, dentro de Swagger, siguen exigiendo el token.

Criterios de aceptación
AC-24-01: seed_rbac termina sin error.
AC-24-02: las rutas guardadas usan <int:pk>.
AC-24-03: spectacular --validate sale con código 0 e incluye el esquema Bearer.
Verificación
Semilla ejecutada sobre storelab_django. Consulta de resources. --validate con exit code 0.

Evidencias
EVI-24-01: mensaje Recursos RBAC sincronizados.
EVI-24-02: 53 filas, patrón api/clients/<int:pk>/.
EVI-24-03: spectacular --validate exit 0.
GATE
AC	Verificación	Evidencia	Resultado
AC-24-01	comando	EVI-24-01	PASS
AC-24-02	SQL de resources	EVI-24-02	PASS
AC-24-03	esquema	EVI-24-03	PASS
✅ GATE de la unidad ISS-24 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-24 · 🧠 Aprender · ↑ Ruta Django · → ISS-25 · 🧠 Aprender
