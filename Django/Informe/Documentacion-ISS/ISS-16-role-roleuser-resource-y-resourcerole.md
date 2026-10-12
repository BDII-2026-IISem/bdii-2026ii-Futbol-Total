# ISS-16 - Role, RoleUser, Resource y ResourceRole

> **Referencia PedalLibre.** Autorización basada en roles.user.role_id; las tablas RoleUser, Resource y ResourceRole no existen. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


🧠 Comprender este bloque y ver el video → · ✅ GATE de la unidad

Capa	Página	Para qué
🧠 Aprender	Elaboración pedagógica y video	comprender, explicar y relacionar
🛠 Construir	esta página	ejecutar, programar y verificar
✅ GATE	Condiciones de cierre	condición para pasar al bloque siguiente
Esta es la guía ejecutable. El cuerpo de abajo es el ISS técnico verbatim: comandos, rutas, versiones, verificaciones y criterios, sin simplificar.

Material de aprendizaje. La elaboración pedagógica y el video F5 están en 🧠 Aprender. No forman parte del manual original: material/django/iss/ISS-16/aprendizaje/ no trae cuaderno. Esta página conserva el ISS técnico.

ISS-16 — Role, RoleUser, Resource y ResourceRole
Objetivo
Modelar la matriz de autorización sin usar Groups ni Permissions como regla de la API.

Requisitos
ISS-15 superado.
Construcción
apps/security/models.py ya tiene User y RefreshToken. Estas cuatro clases se agregan al final. No se reescribe lo anterior.


ARCHIVO: apps/security/models.py

AL FINAL DEL ARCHIVO, AGREGAR HttpMethod, Role, RoleUser, Resource y ResourceRole.
Tablas roles, role_users, resources y resource_roles. Todos con status default inactive. Las parejas (role, user), (resource, role) y (method, route) son únicas. Las FK usan RESTRICT. Resource.route guarda el patrón (api/clients/<int:pk>/), no el path con el id ya sustituido.


class HttpMethod(models.TextChoices):
    GET = "GET", "GET"
    POST = "POST", "POST"
    PUT = "PUT", "PUT"
    PATCH = "PATCH", "PATCH"
    DELETE = "DELETE", "DELETE"


class Role(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.CharField(max_length=255, null=True, blank=True)
    status = models.CharField(
        max_length=8, choices=RecordStatus.choices, default=RecordStatus.INACTIVE
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "roles"
        constraints = [
            models.CheckConstraint(
                condition=models.Q(status__in=RecordStatus.values),
                name="roles_status_valid",
            )
        ]

    def __str__(self):
        return self.name


class RoleUser(models.Model):
    role = models.ForeignKey(Role, on_delete=models.RESTRICT, related_name="assignments")
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.RESTRICT, related_name="role_links"
    )
    status = models.CharField(
        max_length=8, choices=RecordStatus.choices, default=RecordStatus.INACTIVE
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "role_users"
        constraints = [
            models.UniqueConstraint(fields=["role", "user"], name="role_user_unique"),
            models.CheckConstraint(
                condition=models.Q(status__in=RecordStatus.values),
                name="role_users_status_valid",
            ),
        ]


class Resource(models.Model):
    name = models.CharField(max_length=150)
    method = models.CharField(max_length=10, choices=HttpMethod.choices)
    route = models.CharField(max_length=255)
    status = models.CharField(
        max_length=8, choices=RecordStatus.choices, default=RecordStatus.INACTIVE
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "resources"
        constraints = [
            models.UniqueConstraint(fields=["method", "route"], name="resource_method_route_uniq"),
            models.CheckConstraint(
                condition=models.Q(status__in=RecordStatus.values),
                name="resources_status_valid",
            ),
        ]

    def __str__(self):
        return f"{self.method} {self.route}"


class ResourceRole(models.Model):
    resource = models.ForeignKey(Resource, on_delete=models.RESTRICT, related_name="grants")
    role = models.ForeignKey(Role, on_delete=models.RESTRICT, related_name="grants")
    status = models.CharField(
        max_length=8, choices=RecordStatus.choices, default=RecordStatus.INACTIVE
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "resource_roles"
        constraints = [
            models.UniqueConstraint(fields=["resource", "role"], name="resource_role_unique"),
            models.CheckConstraint(
                condition=models.Q(status__in=RecordStatus.values),
                name="resource_roles_status_valid",
            ),
        ]
Resource.method es un TextChoices HTTP. Resource.route guarda el patrón, no el path con el id sustituido. El comando seed_rbac lo obtiene con resolve(path).route. En este proyecto el patrón real quedó, por ejemplo, api/clients/<int:pk>/.


python manage.py makemigrations security
python manage.py migrate
Explicación
Django ya tiene grupos. StoreLab pide otra pregunta: dado un método y un patrón de ruta, ¿la cadena usuario → rol → recurso está toda activa? Esa cadena no se expresa con auth_permission.


User → RoleUser → Role → ResourceRole → Resource(method, route)
Un eslabón que nace inactive no autoriza. Hay que activarlo a propósito. Esa es la forma de negar por defecto también en los datos, no solo en el código.

Criterios de aceptación
AC-16-01: las cuatro tablas existen.
AC-16-02: no se puede repetir la pareja rol-usuario ni recurso-rol.
AC-16-03: seed_rbac graba la ruta que resolve() devuelve, no el ejemplo /api/clients/1/.
Verificación
python manage.py seed_rbac contra storelab_django insertó 53 recursos. La consulta SQL mostró api/clients/<int:pk>/, no el path de ejemplo.

Evidencias
EVI-16-01: 53 filas en resources después de la semilla.
EVI-16-02: tests RBAC que dependen de estas tablas PASS.
GATE
AC	Verificación	Evidencia	Resultado
AC-16-01	migración	security.0001 en el repo final	PASS
AC-16-02	UniqueConstraint	modelos	PASS
AC-16-03	rutas con <int:pk>	consulta a resources	PASS
✅ GATE de la unidad ISS-16 — este bloque no añade ningún criterio nuevo.

Las condiciones de cierre son las de esta misma página:

📋 Criterios de aceptación → Criterios de aceptación
✅ GATE → GATE
🔎 Verificación → Verificación
🧠 Autoevaluación → Preguntas de Aprender
Con el GATE en verde queda habilitado el bloque siguiente de la ruta.

Navegación de la ruta: ← ISS-16 · 🧠 Aprender · ↑ Ruta Django · → ISS-17 · 🧠 Aprender
