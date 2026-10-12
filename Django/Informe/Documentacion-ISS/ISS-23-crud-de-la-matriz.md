# ISS-23 - CRUD de la matriz

> **Referencia PedalLibre.** Administración de roles existentes; no CRUD de una matriz ResourceRole inexistente. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.

[🧠 Comprender este bloque y ver el video →](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-23-aprendizaje/#video-explicativo) · [✅ GATE de la unidad](https://tecnogua.com/academic/site/backend2026/django/manual/24-ISS-23-crud-de-la-matriz/#gate)
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.
Material de aprendizaje. La elaboración pedagógica y el video F5 están en [🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-23-aprendizaje/#video-explicativo). No forman parte del manual original: material/django/iss/ISS-23/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.
Administrar la matriz y usarla para autorizar: el CRUD crea cada fila, RoleUser asigna el rol al usuario y ResourceRole asigna el recurso al rol. Con los dos enlaces activos, ese usuario puede ejecutar la ruta concedida.
- ISS-22 superado.
SoftDeleteModelViewSet es un ModelViewSet con baja lógica y filtro ?status=. De él heredan UserViewSet, RoleViewSet, RoleUserViewSet, ResourceViewSet y ResourceRoleViewSet.
UserSerializer.password es write_only. create y update llaman set_password(). validate_password usa los validadores de Django y traduce ValidationError de Django al de DRF.
El CRUD se agrega al urls.py que ya tiene login, refresh, logout y perfil. No se crea otro archivo ni otro include.
```
ARCHIVO: apps/security/urls.py

AGREGAR:
from rest_framework.routers import SimpleRouter

y los viewsets de rbac_views.

DEBAJO DE los path("auth/...") y ANTES de cerrar el módulo:

router = SimpleRouter(use_regex_path=False)
router.register("users", UserViewSet, basename="user")
router.register("roles", RoleViewSet, basename="role")
router.register("role-users", RoleUserViewSet, basename="role-user")
router.register("resources", ResourceViewSet, basename="resource")
router.register("resource-roles", ResourceRoleViewSet, basename="resource-role")

urlpatterns += router.urls

```
urlpatterns += router.urls concatena las diez rutas del CRUD (lista y detalle de cada recurso) después de las cuatro de auth/. El prefijo sigue siendo el api/ del include del ISS-17. auth/profile/ queda fuera del router a propósito.
Estos endpoints son JWT con token + RBAC. Crear un rol no es OPEN ni basta con traer el JWT: hace falta la concesión. La prueba nace aquí, ya con grant_crud: no hubo una versión abierta que parchear.
```
ARCHIVO: apps/security/tests.py

AL FINAL DEL ARCHIVO, AGREGAR la clase SecurityMatrixApiTests.
Su setUp concede el CRUD de /api/users/, /api/roles/, /api/role-users/,
/api/resources/ y /api/resource-roles/, y llama force_authenticate.
test_role_crud cubre alta, lista, detalle, PATCH y baja lógica del rol.
test_user_role_resource_chain no se queda en el alta. Después de cada eslabón
entra como el usuario nuevo a GET /api/clients/:
sin rol es 403, con RoleUser y sin recurso es 403, con el recurso suelto es 403,
y con ResourceRole active es 200. POST /api/clients/ sigue en 403: solo se concedió GET.
El método del recurso se envía en mayúsculas: las choices no aceptan "get".
La route es el patrón api/clients/, el mismo que devuelve el resolver.

```
```
python manage.py test apps.security.tests.SecurityMatrixApiTests

```
El CRUD de cada tabla es homogéneo: listar, crear, leer, actualizar y dar de baja. Por eso es ModelViewSet. La contraseña cabe en el serializer: es write_only y pasa por set_password.
Las tablas role_users y resource_roles no son un CRUD más. RoleUser dice qué rol tiene el usuario. ResourceRole dice qué método y qué ruta puede ese rol. HasResourceAccess exige los dos enlaces, y el rol, el recurso y la concesión, en active. Un usuario creado por aquí nace inactive si el cuerpo no envía status. Hasta que alguien lo active, login responde 401.
Capa HTTP, acceso JWT con token + RBAC. El setUp solo abre la matriz, para poder escribirla. La prueba de negocio usa otro usuario, el que el propio POST acaba de crear, y no llama a grant() para él.
```
python manage.py test apps.security.tests.SecurityMatrixApiTests
        │
        ├── roles     POST GET GET/<id> PATCH DELETE     la fila queda inactive
        │
        └── asignación y RBAC
              POST /api/roles/            bodega active
              POST /api/users/            bodega1 active; password no vuelve
              GET  /api/clients/          como bodega1          403
              POST /api/role-users/       rol bodega → bodega1
              GET  /api/clients/          como bodega1          403   falta el recurso
              POST /api/resources/        GET api/clients/
              GET  /api/clients/          como bodega1          403   falta ResourceRole
              POST /api/resource-roles/   ese recurso → rol bodega
              GET  /api/clients/          como bodega1          200
              POST /api/clients/          como bodega1          403   no se concedió POST

```
```
User ── RoleUser ── Role ── ResourceRole ── Resource
 bodega1            bodega                 GET api/clients/
        │
        ▼
HasResourceAccess
        │
        └── los cuatro eslabones active → la ruta responde

```
En Swagger el mismo armado se hace en el ISS-24, con el rol admin ya sembrado para poder llamar a la matriz. Aquí el HTTP crea la concesión y enseguida la usa.
- AC-23-01: el serializer no devuelve password.
- AC-23-02: la contraseña pasa por set_password, no se asigna en claro.
- AC-23-03: DELETE de estas entidades no borra la fila.
- AC-23-04: asignar el rol con RoleUser, sin ResourceRole, deja GET /api/clients/ en 403.
- AC-23-05: con ResourceRole active de GET api/clients/, ese GET responde 200 y el POST sigue en 403.
SecurityMatrixApiTests publica el usuario, asigna el rol, concede solo GET api/clients/ y entra otra vez como ese usuario. Antes del ResourceRole el GET es 403. Después es 200. El POST de clientes sigue en 403.
- EVI-23-01: password = serializers.CharField(write_only=True).
- EVI-23-02: set_password en create y update.
✅ GATE de la unidad ISS-23 — este bloque no añade ningún criterio nuevo.
Las condiciones de cierre son las de esta misma página:
- 📋 Criterios de aceptación → [Criterios de aceptación](https://tecnogua.com/academic/site/backend2026/django/manual/24-ISS-23-crud-de-la-matriz/#criterios-de-aceptacion)
- ✅ GATE → [GATE](https://tecnogua.com/academic/site/backend2026/django/manual/24-ISS-23-crud-de-la-matriz/#gate)
- 🔎 Verificación → [Verificación](https://tecnogua.com/academic/site/backend2026/django/manual/24-ISS-23-crud-de-la-matriz/#verificacion)
- 🧠 Autoevaluación → [Preguntas de Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-23-aprendizaje/#preguntas-de-comprension)
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.
Navegación de la ruta: ← [ISS-23 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-23-aprendizaje/) · [↑ Ruta Django](https://tecnogua.com/academic/site/backend2026/django/) · → [ISS-24 · 🧠 Aprender](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-24-aprendizaje/)
