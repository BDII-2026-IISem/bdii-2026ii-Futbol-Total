# ISS-25 - Pruebas 401 y 403

> **Referencia PedalLibre.** Pruebas 401/403 para usuarios activos y roles existentes. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-25/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

El propio ISS técnico cierra aquí la Fase II — Auth con RBAC (sección «Cierre de la Fase II — Auth con RBAC»). No hay una unidad de cierre aparte.

ISS-25 — Pruebas 401 y 403
Objetivo
Dejar por escrito, en tests, la diferencia entre no tener identidad y no tener permiso.

401 corresponde a OPEN mal credenciado o a un JWT que no identifica un usuario active. 403 corresponde solo al acceso JWT con token + RBAC: el JWT es válido y la concesión no.

Requisitos
ISS-24 superado.
No basta con probarlo una vez en Swagger.
Construcción
AuthFlowTests ya cubre login, refresh, reuso, logout y perfil. Esos métodos se escribieron en el ISS de cada endpoint. Este ISS agrega RbacTests al final de apps/security/tests.py. El usuario está autenticado y, sin concesión, GET /api/clients/ responde 403. Sin identidad, el mismo GET responde 401. Cada eslabón inactive de la cadena (rol, RoleUser, ResourceRole, Resource) vuelve a 403.


ARCHIVO: apps/security/tests.py

AL FINAL DEL ARCHIVO, AGREGAR:

class RbacTests(APITestCase):
    def setUp(self):
        self.user = create_active_user()
        self.client.force_authenticate(user=self.user)

    def test_missing_grant_is_403_and_missing_identity_is_401(self):
        denied = self.client.get("/api/clients/")
        self.assertEqual(denied.status_code, status.HTTP_403_FORBIDDEN)
        self.client.force_authenticate(user=None)
        anonymous = self.client.get("/api/clients/")
        self.assertEqual(anonymous.status_code, status.HTTP_401_UNAUTHORIZED)
El segundo método, test_any_inactive_link_denies, concede GET /api/clients/, comprueba 200 y luego pasa a inactive, uno por uno, el rol, el RoleUser, el ResourceRole y el Resource. Cada uno debe responder 403. Hay que importar grant desde apps.common.testing.

RbacTests cubre:


autenticado sin concesión     → 403
sin autenticar                → 401
rol inactive                  → 403
RoleUser inactive             → 403
ResourceRole inactive         → 403
Resource inactive             → 403

python manage.py test apps
Explicación
401 y 403 no se intercambian para “que se vea un error”. 401 significa que la petición no demostró una identidad vigente. 403 significa que la identidad está vigente y la operación no está concedida. Un usuario inactivo con un JWT bien firmado es 401: la identidad que el token nombra ya no está vigente.

Cómo probarlo
Capa HTTP del cierre. El ISS-23 ya demostró el camino que autoriza: RoleUser más ResourceRole y el GET pasa a 200. Aquí se prueba el camino que niega. python manage.py test apps corre también los ISS anteriores. El caso nuevo es RbacTests, sobre GET /api/clients/.


python manage.py test apps.security.tests.RbacTests
        │
        ▼
GET /api/clients/
        │
        ├── sin identidad                          401
        ├── identidad vigente, sin concesión       403
        ├── concesión active                       200
        └── uno de estos eslabones inactive
              Role · RoleUser · ResourceRole · Resource     403
En Swagger, con la semilla del ISS-24, el mismo corte se ve en GET /api/clients/. El test HTTP es el que apaga cada eslabón. Swagger muestra los dos casos que no piden editar la matriz a mano.


swagger-ui   después de seed_rbac
        │
        ├── sin Authorize                         401
        ├── Authorize de un usuario sin rol admin 403
        └── Authorize del usuario con rol admin   200
Criterios de aceptación
AC-25-01: la suite apps pasa.
AC-25-02: existe un test cuyo resultado esperado es 401.
AC-25-03: existe un test cuyo resultado esperado es 403.
AC-25-04: el 403 no aparece cuando falta el token.
Verificación
Suite completa en PostgreSQL: 30 tests OK, ya con el CRUD HTTP de cada entidad. MySQL y SQL Server quedaron en 24 OK en la corrida anterior, antes de esos casos.

Evidencias
EVI-25-01: Ran 30 tests / OK en PostgreSQL.
EVI-25-02: RbacTests OK en la repetición de PostgreSQL.
GATE
AC	Verificación	Evidencia	Resultado
AC-25-01	suite	EVI-25-01	PASS
AC-25-02	test 401	EVI-25-02	PASS
AC-25-03	test 403	EVI-25-02	PASS
AC-25-04	anónimo no es 403	EVI-25-02	PASS
Cierre de la Fase II — Auth con RBAC
Esta fase agrega identidad y autorización sobre el negocio ya cerrado en el ISS-14. Aquí quedan definidos los tres accesos, y cada endpoint de la API usa uno solo.

Acceso	Endpoints
OPEN	POST /api/auth/login/, /api/auth/refresh/, /api/auth/logout/, esquema y Swagger
JWT con token	GET/PATCH /api/auth/profile/
JWT con token + RBAC	Clientes, catálogo, disponibles, ventas y el CRUD de usuarios, roles, recursos y asignaciones
Qué queda construido
Custom User con hash de Django. Access token no persistido. Refresh con hash, familia, rotación y revocación por reuso. Logout del refresh. Perfil solo con JWT, sin matriz. Matriz Role → Resource. Permiso HasResourceAccess sobre el negocio. 401 sin identidad. 403 con identidad y sin concesión. Semilla tomada de resolve().route. Swagger con Bearer.

Verificación

python manage.py check
python manage.py test apps
python manage.py spectacular --validate
python manage.py seed_rbac
Pieza	Resultado
Login username y email	PASS
Usuario inactive y clave mala = 401	PASS
Rotación y reuso de familia	PASS
Logout 204 y refresh posterior 401	PASS
Perfil JWT con token, y access inválido tras desactivar	PASS
401 frente a 403	PASS
Eslabones inactive	PASS en PostgreSQL para los cuatro eslabones
Esquema OpenAPI	PASS (--validate exit 0)
PostgreSQL	30 tests OK, con el CRUD de cada entidad
MySQL y SQL Server	24 tests OK en la corrida anterior
Oracle	NO VERIFICADO EN ESTE ENTORNO
GATE AUTH/RBAC
AC	Verificación	Evidencia	Resultado
Hash de contraseña y de refresh	tests de login	suite	PASS
OPEN, JWT con token, JWT con token + RBAC	contrato y tests	suite	PASS
Deny by default	RbacTests	suite	PASS
401 distinto de 403	tests explícitos	suite	PASS
Swagger Bearer	extensión OpenAPI	--validate	PASS
Oracle	conexión	ORA-28000 y ORA-01017	NO VERIFICADO
El GATE de esta fase se supera en los tres motores donde la suite corrió. No incluye una ejecución Oracle.

✅ GATE de la unidad ISS-25 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Esta es la última unidad de la ruta.

Navegación de la ruta: ← ISS-25 · 🧠 Aprender · ↑ Ruta Django
