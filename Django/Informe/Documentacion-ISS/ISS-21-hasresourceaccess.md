# ISS-21 - HasResourceAccess

> **Referencia PedalLibre.** Permisos por rol sin introducir tablas RBAC que el esquema no define. Consulte [PEDALIBRE-REFERENCIA-PROYECTO.md](./PEDALIBRE-REFERENCIA-PROYECTO.md). El contenido StoreLab que mencione products, sales, product_sales, RoleUser, Resource o ResourceRole queda sustituido por esta referencia y no debe ejecutarse.


[Guía de aprendizaje y video](https://tecnogua.com/academic/site/backend2026/django/aprendizaje/ISS-21-aprendizaje/#video-explicativo) · [GATE](https://tecnogua.com/academic/site/backend2026/django/manual/22-ISS-21-hasresourceaccess/#gate)

## Objetivo

Autorizar por método y patrón de ruta, con negación por defecto. La clase es la mitad de autorización del acceso JWT con token + RBAC: el JWT primero identifica al usuario.

## Requisitos

- ISS-20 superado.
- Los modelos de ISS-16 existen.

## Construcción

`apps/security/permissions.py` es nuevo. Recorre la cadena de autorización completa y exige que todos sus elementos estén activos:

```python
from rest_framework.permissions import BasePermission

from apps.common.status import RecordStatus
from apps.security.models import ResourceRole


class HasResourceAccess(BasePermission):
    message = "No tiene autorización para ejecutar esta operación."

    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated:
            return False
        if getattr(user, "status", None) != RecordStatus.ACTIVE:
            return False
        if request.method.upper() == "OPTIONS":
            return True

        match = request.resolver_match
        if match is None:
            return False
        method = request.method.upper()
        if method == "HEAD":
            method = "GET"
        return ResourceRole.objects.filter(
            status=RecordStatus.ACTIVE,
            resource__status=RecordStatus.ACTIVE,
            resource__method=method,
            resource__route=match.route,
            role__status=RecordStatus.ACTIVE,
            role__assignments__user=user,
            role__assignments__status=RecordStatus.ACTIVE,
        ).exists()
```

`HEAD` se evalúa como `GET`. `OPTIONS`, una vez autenticado el usuario, no busca un recurso porque es el preflight y no una operación de negocio.

## Explicación

DRF devuelve 401 cuando ninguno de los authenticators identificó al usuario y 403 cuando hay usuario autenticado pero falla el permiso. La comparación usa `request.resolver_match.route`; para un detalle es `api/clients/<int:pk>/`, no la URL concreta como `/api/clients/15/`.

```text
Request -> JWT -> usuario activo? -> método + ruta -> todos los eslabones activos?
                                                   no -> 403
                                                   sí -> endpoint
```

Si no se encuentra una cadena activa completa, `exists()` es falso: no hay permisos implícitos.

## Criterios de aceptación

- AC-21-01: usuario autenticado sin concesión recibe 403 en `GET /api/clients/`.
- AC-21-02: el mismo request sin usuario recibe 401.
- AC-21-03: con una concesión activa, la lista responde 200.
- AC-21-04: apagar Role, RoleUser, ResourceRole o Resource devuelve 403.

## Verificación y evidencias

`RbacTests` verifica los casos en PostgreSQL, incluyendo el recurso inactivo ejecutado al final. EVI-21-01: `RbacTests` PASS.

## GATE

| AC | Verificación | Evidencia | Resultado |
| :-- | :-- | :-- | :-- |
| AC-21-01 | 403 | EVI-21-01 | PASS |
| AC-21-02 | 401 | EVI-21-01 | PASS |
| AC-21-03 | concesión activa | EVI-21-01 | PASS |
| AC-21-04 | cada eslabón inactivo | EVI-21-01 | PASS |

El GATE no añade criterios nuevos. En verde habilita ISS-22.
