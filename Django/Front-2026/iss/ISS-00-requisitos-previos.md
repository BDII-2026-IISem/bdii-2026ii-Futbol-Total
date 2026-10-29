# ISS-00 · Requisitos previos de PedalLibre

> **Proyecto:** Frontend de PedalLibre
> **Capa:** Construir
> **Estado:** Completada; se puede avanzar a ISS-01

## Objetivo

Dejar listo el entorno para iniciar el frontend de PedalLibre con Angular. En esta ISS preparo las herramientas y ubico el backend existente. La implementación y las pruebas de integración con la API se realizan en las ISS que las necesiten; no son un requisito para comenzar ISS-01.

## Contexto del proyecto

- El backend Django del repositorio está desarrollado para PedalLibre.
- El frontend se trabajará dentro de `Front-2026/`.
- El backend contempla clientes, bicicletas, tarifas, autenticación y permisos RBAC.
- Rutas del backend identificadas para el frontend:
  - `GET /api/clients/`
  - `GET /api/bicycles/available/`
  - `GET /api/rates/`
  - `POST /api/auth/login/`
  - `GET /api/auth/profile/`
  - `GET /api/auth/permissions/`
- El login usa `POST` y devuelve un token de acceso. El backend actual no implementa refresh token.
- Las rutas de negocio deben respetar los permisos RBAC del usuario autenticado. No se debe cambiar la configuración de seguridad para hacer que una comprobación de desarrollo pase.

La guía original se conserva después de esta sección de PedalLibre. No elimino los pasos que no aplican: agrego **(EXENTO EN PEDALIBRE)** al título de cada sección que no se utilizará. Las secciones exentas se conservan como referencia y no son tareas pendientes.

## Criterios de aceptación

- [x] **0.1 — Node y npm:** Node cumple los requisitos de Angular CLI y npm responde.
- [x] **0.2 — Angular CLI:** está instalado Angular CLI 22 y `ng version` lo identifica.
- [x] **0.3 — Herramientas:** el proyecto se abre en VS Code y se puede usar su terminal integrada; hay un navegador disponible.
- [x] **0.4 — Backend disponible:** se ejecutaron `python manage.py check` y `python manage.py runserver`; Django inició sin errores y `/admin/` cargó.
- [x] **0.5 — Espacio de trabajo:** existe `Front-2026/` con la documentación de las ISS y la trazabilidad; el código Angular se creará en la siguiente ISS.

Las pruebas de login, permisos, CORS y respuestas de los endpoints no bloquean esta ISS. Se harán cuando el paso de desarrollo correspondiente requiera consumir la API. No es necesario repetir una petición que exponga datos personales solo para cerrar los requisitos del entorno.

## 0.1 · Node y npm

Verifiqué las versiones y los requisitos de Angular CLI:

```bash
node --version
npm --version
npm view @angular/cli version engines --json
```

En las capturas de esta ISS aparecen Node `v24.21.0`, npm `12.2.1` después de su actualización y Angular CLI `22.2.5`. El rango de Node publicado para Angular CLI incluye la versión instalada.

## 0.2 · Angular CLI

Instalé Angular CLI y comprobé la versión y la ruta del ejecutable:

```bash
npm install -g @angular/cli
ng version
command -v ng
```

La comprobación identificó Angular CLI `22.2.5`. La creación y configuración del proyecto Angular corresponden a ISS-01.

## 0.3 · Editor y navegador

Abrí el proyecto en VS Code y utilicé la terminal integrada para los comandos. El navegador está disponible para revisar la aplicación durante su desarrollo. Las comprobaciones con DevTools se harán cuando haya una pantalla o una petición del frontend que inspeccionar.

## 0.4 · Backend Django

El backend PedalLibre se encuentra en el proyecto Django. Ejecuté:

```bash
python manage.py check
python manage.py runserver
```

El servidor inició en `http://127.0.0.1:8000/` y pude abrir el formulario de acceso de `/admin/`. Esto confirma que el backend inicia; no implica que haya validado desde el frontend el login ni los permisos de la API.

La base de la API que utilizará el frontend es `http://localhost:8000/api`. Al integrar cada recurso, verificaré su ruta, método, respuesta y permisos contra el backend PedalLibre. Las listas y los importes se tiparán según las respuestas reales de cada endpoint, sin asumir el contrato de otro proyecto.

## 0.5 · Seguridad y datos de prueba

- No registraré contraseñas ni tokens en el código, capturas o bitácora.
- No guardaré capturas que expongan información personal de clientes.
- No cambiaré RBAC ni permisos del backend para simplificar el desarrollo.
- La validación de login, perfil, permisos y CORS se documentará cuando corresponda al trabajo de integración.

## Evidencias

Las capturas y su explicación están insertadas en la sección **ISS-00 · Requisitos previos** de la [guía paso a paso](../trazabilidad/docs/guia-paso-a-paso.md):

- Versiones de Node/npm y requisitos de Angular CLI.
- Instalación y versión de Angular CLI 22.
- Inicio del backend Django y carga de `/admin/`.
- Intento de login desde terminal que terminó con `EOF when reading a line`; no se considera una autenticación validada y no bloquea ISS-01.

La captura de `/api/clients/` no se guarda en el repositorio porque muestra datos personales. La respuesta se podrá volver a comprobar de forma resumida si una ISS posterior lo requiere.

## Resultado y siguiente paso

El entorno y las herramientas necesarias para iniciar el frontend están preparados. ISS-00 queda **completada** y habilita **ISS-01**. Las pruebas de integración con los endpoints PedalLibre se realizarán más adelante, junto con la funcionalidad que los consuma.

---

# ISS-00 original · Requisitos previos

> **Capa:** Construir
> **Referencia:** texto original compartido para ISS-00. Se conserva debajo de la adaptación PedalLibre.
> Los títulos marcados **(EXENTO EN PEDALIBRE)** señalan instrucciones que no se ejecutan en este proyecto; el contenido original se mantiene.

## Contexto mínimo original (EXENTO EN PEDALIBRE)

Este contexto describe el proyecto StoreLab original, no PedalLibre. Se conserva para mantener la ISS fuente:

- **Proyecto:** `front-storelab-django` — Angular 22 (standalone + signals), PrimeNG 22 en modo styled con Aura y Tailwind CSS 4. Sin CSS propio ni PrimeFlex.
- **Backend de referencia:** `pry-django` — Django 5.2 + Django REST Framework. Sus ISS están en `docs/manual/`; el contrato de API está en `docs/manual/contrato-api.md`.
- **Recorrido de una petición:** Componente → Service → HttpClient → Interceptor → API → Vista DRF → Serializer → Modelo → BD. La UI no conoce el ORM ni la base de datos.
- **Contrato REST original:** `http://localhost:8000/api`, listas en arreglo plano, importes como string decimal y login `{access, refresh, tokenType, accessExpiresIn}`.
- **Interruptor original:** `API_ACCESS=open` publica el negocio sin JWT (Fase I); `API_ACCESS=rbac` exige identidad y concesión (Fase II). Equivale a `AUTH_ENABLED` del laboratorio Express.
- **Patrón visual y convenciones:** `PATRON-VISUAL.md`.
- **Plantilla de las ISS:** `README.md`.

## Ficha original

| Campo | Descripción original |
|---|---|
| **ISS** | Requisitos previos |
| **Feature / tabla** | — |
| **API** | Comprobación de `/api/clients/`, `/api/products/available/`, Swagger y, para la Fase II, `/api/auth/` |
| **Depende de** | Ninguno (es el primero) |
| **Habilita** | ISS-01 — Bootstrap Angular 22 con CLI |

## Criterios de aceptación originales

- [ ] **0.1** `node --version` cumple `engines.node` de `@angular/cli` y `npm --version` responde.
- [ ] **0.2** `ng version` identifica Angular CLI 22.x y `command -v ng` apunta a la instalación npm.
- [ ] **0.3** Hay editor con terminal integrada y navegador con DevTools (`F12`).
- [ ] **0.4** `python manage.py runserver` deja el puerto 8000 escuchando.
- [ ] **0.4** Con `API_ACCESS=open`, `GET /api/clients/` responde 200 y el cuerpo empieza por `[`. **(EXENTO EN PEDALIBRE: modo `open`)**
- [ ] **0.6** `GET /api/schema/swagger-ui/` responde 200. **(EXENTO EN PEDALIBRE)**
- [ ] **0.6** `GET /api/products/available/` responde 200 y `price` es un string decimal. **(EXENTO EN PEDALIBRE)**
- [ ] **0.7** Queda escrito por qué una lista es un arreglo plano y un importe es texto.
- [ ] **0.8** `POST /api/auth/login/` con `admin / Admin123!` devuelve `access`, `refresh`, `tokenType` y `accessExpiresIn`. **(EXENTO EN PEDALIBRE: credenciales y refresh)**
- [ ] **0.8** `GET /api/auth/permissions/` con ese token devuelve `permissions` con rol `ADMIN`.
- [ ] **0.9** `seller / Seller123!` inicia sesión y `/api/auth/permissions/` devuelve solo los GET del negocio con rol `SELLER`. **(EXENTO EN PEDALIBRE)**
- [ ] **0.9** `seed_rbac --username admin` ejecutado dos veces deja el mismo conteo de recursos y concesiones. **(EXENTO EN PEDALIBRE: matriz StoreLab y sus conteos)**
- [ ] **0.10** La carpeta del frontend existe y está vacía de código: sin `src/` ni `package.json`. **(EXENTO EN PEDALIBRE: ruta de workspace StoreLab; se conserva como criterio original)**

Estos son los criterios tal como aparecen en la ISS original. Para saber qué aplica al trabajo, se usa la sección PedalLibre al inicio del documento.

## 0.1 Node, npm y engines del CLI

**Criterios del subítem**

- [ ] `node --version` cumple `engines.node` de `@angular/cli`.
- [ ] `npm --version` responde.
- [ ] La consulta de `engines` se hizo antes de forzar una instalación.

```bash
node --version
npm --version
npm view @angular/cli version engines --json
```

`npm view @angular/cli version engines --json` imprime el rango de Node que exige el CLI publicado. La consulta del 24 de octubre de 2026 reportó:

```json
{
  "version": "22.2.4",
  "engines": {
    "node": "^22.22.3 || ^24.15.0 || >=26.0.0",
    "npm": "^6.11.0 || ^7.5.6 || >=8.0.0"
  }
}
```

Sirve Node 22.22.3 o superior de la línea 22, Node 24.15.0 o superior de la línea 24, o Node 26 en adelante. Si la versión instalada queda fuera de ese rango, se actualiza Node dentro de una línea admitida. No se usa `--force` para ignorar `engines`.

`npm` se instala junto con Node. La misma regla de `engines` vale para este frontend y para `front-storelab-express-ii`: ambos consumen el CLI de Angular, no el runtime del backend.

## 0.2 Angular CLI 22

**Criterios del subítem**

- [ ] `ng version` muestra el bloque Angular CLI 22.x.
- [ ] `command -v ng` apunta a la instalación npm y no a otro programa.

```bash
npm install -g @angular/cli
ng version
command -v ng
```

`npm install -g @angular/cli` instala la versión publicada como `latest`, sin fijar una versión mayor. `ng version` debe imprimir `Angular CLI:` con 22.x. En algunos sistemas existe otro programa llamado `ng`; si el comando abre un editor o falla antes de mostrar la versión, se revisa `command -v ng` y el `PATH`.

El CLI global se usa para `ng new` en ISS-01. Dentro del proyecto, `ng` delega en el CLI local de `node_modules/`.

> Antes de ISS-01 todavía no existe `package.json`, así que `npm run ng` no aplica. La comprobación del CLI local se hace después de `ng new`.

## 0.3 Editor, terminal y navegador

**Criterios del subítem**

- [ ] La terminal integrada ejecuta los comandos de esta ISS.
- [ ] DevTools (`F12`) tiene Console y Network.
- [ ] Hay una segunda terminal para `runserver`.

Editor con terminal integrada: ahí se ejecutan los comandos y se crean los archivos. Navegador con DevTools (`F12`) → pestañas Console y Network. En la Fase II se comprueba el encabezado `Authorization`.

Se necesita una segunda terminal para el backend: `runserver` ocupa su terminal mientras se construye. Desactiva bloqueadores para `localhost` si el login de la Fase II falla sin motivo en el navegador.

Los bloques de comandos usan sintaxis de shell (`bash`). En Windows se ejecutan en Ubuntu WSL o en Git Bash. La carpeta del proyecto y las rutas de la API son las mismas.

## 0.4 Backend Django y el interruptor `API_ACCESS` (PARCIALMENTE EXENTO EN PEDALIBRE)

Los pasos de `manage.py check` y `runserver` se conservan como referencia general de Django. El interruptor `API_ACCESS` y sus modos no describen el backend PedalLibre.

**Criterios del subítem original**

- [ ] `python manage.py check` responde sin issues.
- [ ] `runserver` deja el puerto 8000 escuchando.
- [ ] `API_ACCESS` del `.env` está leído: `open` para esta comprobación de negocio. **(EXENTO EN PEDALIBRE)**

El frontend consume la API en `http://localhost:8000/api`. Backend de referencia original:

```bash
cd ~/ia-lab/projects/dw/pry-django
source .venv/bin/activate
python manage.py check
python manage.py runserver
```

La salida de un arranque nuevo incluye `Starting development server at http://127.0.0.1:8000/`. Si el puerto ya está ocupado por otro `runserver` de este proyecto, se reutiliza esa instancia: un segundo proceso responde `That port is already in use`.

| Puerto | Quién lo ocupa | Para qué |
|---:|---|---|
| 8000 | `python manage.py runserver` | API Django (`/api/`), admin y Swagger |
| 4200 | `ng serve` | Aplicación Angular en el navegador |
| 5432 | Contenedor `postgres-server` | Motor cuando `DB_ENGINE=postgresql` |

### Los dos modos del backend (EXENTO EN PEDALIBRE)

| `API_ACCESS` | Qué exige el negocio | Cuándo se usa en StoreLab |
|---|---|---|
| `open` | Nada | Fase I (ISS-03 a ISS-07) y los `curl` de negocio de esta ISS |
| `rbac` | Access token + concesión `(method, path)` | Fase II (ISS-08 a ISS-11) |

Login, refresh, logout, el esquema y Swagger permanecen abiertos en los dos modos. Perfil y permisos propios exigen JWT. Con `rbac`, el CRUD de negocio y el de administración exigen JWT y concesión.

```bash
curl -i http://127.0.0.1:8000/api/clients/
```

| Respuesta | Lectura original |
|---|---|
| `200` y un arreglo `[ … ]` | `API_ACCESS=open`, o el backend todavía en Fase I |
| `401` y `{"detail":"…"}` | `API_ACCESS=rbac`: correcto para la Fase II, se retoma al llegar a ISS-08 |
| `404` y `{"detail":"No encontrado."}` | Revisar la barra final y el prefijo `/api/` |
| `curl: (7) Failed to connect` | El backend no escucha en 8000 |

> No ejecutes una base de datos de prueba ni borres datos del laboratorio. Con `API_ACCESS=open` cualquiera de las comprobaciones de escritura puede crear o anular filas reales. `seed_rbac` es idempotente y no vacía el negocio.

## 0.5 Puertos y CORS

**Criterios del subítem**

- [ ] La base se escribe `http://localhost:8000/api`, sin barra final.
- [ ] Una petición con `Origin: http://localhost:4200` recibe `access-control-allow-origin`.

Angular se sirve en 4200 y la API en 8000: son orígenes distintos. El backend del laboratorio envía CORS con `django-cors-headers`. En la configuración original la respuesta incluye `access-control-allow-origin: *`, así que Angular no necesita proxy.

| Situación | Qué ocurre | Qué hacer |
|---|---|---|
| 4200 ocupado | `ng serve` ofrece otro puerto (4201) | Se acepta si CORS permite el origen |
| Origen sin cabeceras CORS | El navegador descarta la respuesta | Revisar `INSTALLED_APPS` y `MIDDLEWARE` del backend y reiniciarlo |
| `ECONNREFUSED` | El backend no escucha en 8000 | Volver a 0.4 |

Todas las rutas del contrato original terminan en `/`.

## 0.6 Comprobaciones del contrato con `curl` (PARCIALMENTE EXENTAS EN PEDALIBRE)

La comprobación de clientes es una referencia del contrato original. Swagger y la ruta de productos disponibles no se usan como endpoints de PedalLibre.

**Criterios del subítem original**

- [ ] `GET /api/clients/` responde 200 y el cuerpo empieza por `[`.
- [ ] `GET /api/schema/swagger-ui/` responde 200. **(EXENTO EN PEDALIBRE)**
- [ ] `GET /api/products/available/` responde 200 y `price` va entre comillas. **(EXENTO EN PEDALIBRE)**

```bash
curl -s -o /dev/null -w "clients   %{http_code}\n" \
  http://127.0.0.1:8000/api/clients/
curl -s -o /dev/null -w "swagger   %{http_code}\n" \
  http://127.0.0.1:8000/api/schema/swagger-ui/
curl -s -o /dev/null -w "available %{http_code}\n" \
  http://127.0.0.1:8000/api/products/available/
```

Con `API_ACCESS=open`, las tres líneas imprimen 200. Después se mira la forma del cuerpo:

```bash
curl -s http://127.0.0.1:8000/api/clients/ | head -c 400; echo
curl -s http://127.0.0.1:8000/api/products/available/ | head -c 400; echo
```

`GET /api/clients/` responde un arreglo plano. Cada elemento trae `id`, `name`, `address`, `phone`, `email`, `status`, `createdAt` y `updatedAt`.

`GET /api/products/available/` responde el mismo tipo de arreglo, limitado a productos `active` con existencia y tipo activo. La lectura agrega `productTypeName` y el precio llega como texto (`"516.10"` en los datos actuales del laboratorio; el contrato ilustra el mismo tipo con `"12.50"`).

Un arreglo vacío (`[]`) también es válido: significa que no hay filas activas, no que la ruta esté mal.

## 0.7 Arreglo plano e importes como texto (PARCIALMENTE EXENTO EN PEDALIBRE)

El concepto general de arreglo plano y de importes como string se conserva. Los nombres de modelos, campos y rutas de StoreLab se eximen; en PedalLibre se consultará el contrato del backend antes de tipar cada recurso.

**Criterios del subítem original**

- [ ] La lista se tipará `Client[]` / `Product[]` / `Sale[]`, leyendo el JSON tal como llega.
- [ ] `price` y el resto de importes se tiparán `string`.

Las listas son un arreglo plano. `GET /api/clients/` es `[ … ]`. El arreglo llega completo, sin paginación. Un servicio escribe `http.get<Client[]>(url)` y la pantalla asigna el resultado a su lista.

```text
GET /api/clients/          → Client[]
GET /api/products/         → Product[]
GET /api/sales/            → Sale[] (cada venta con su arreglo items)
```

Los importes son string decimal. `price`, `discounts`, `subtotal`, `total`, `unitPrice` y `lineTotal` llegan como `"12.50"`, que conserva los dos decimales del tipo `decimal(12,2)`. En el frontend el campo es `string`; la suma usa `Number(...)` y la pantalla muestra el texto tal como llega.

| Dato | Forma en el JSON | Consecuencia en el código |
|---|---|---|
| Lista | `[ … ]` | `http.get<Client[]>()`; el cuerpo es la lista |
| Importe | `"12.50"` | Campo `string`; `Number(price)` solo para calcular |
| Fecha | `2026-09-30T15:00:00-05:00` | Se envía ISO-8601; el `DatePicker` produce ese valor |
| Identificador | Entero (`1`) | `id: number`; las FK también enteros (`productTypeId`) |
| Campos | camelCase (`minStock`) | El nombre del control del formulario es el del JSON |
| Permiso | `GET /api/clients` | Clave MÉTODO/ruta, con `:id` en el detalle y sin barra final |

## 0.8 Login, perfil y permisos (PARCIALMENTE EXENTO EN PEDALIBRE)

Las rutas de perfil y permisos existen también en PedalLibre, pero los detalles del contrato original —incluido `refresh`— no deben asumirse para el backend PedalLibre. Se conservan aquí como parte de la ISS original.

**Criterios del subítem original**

- [ ] El login devuelve `access`, `refresh`, `tokenType` y `accessExpiresIn`.
- [ ] `GET /api/auth/profile/` devuelve el usuario directo.
- [ ] `GET /api/auth/permissions/` devuelve `{ permissions: [...] }`.
- [ ] `admin` recibe filas con `roleName: ADMIN`.

El login original devuelve solo el par de tokens. El perfil y los permisos se piden aparte. Es el mismo corte que en Express (`access_token` / `refresh_token` allí; `access` / `refresh` aquí).

```bash
curl -s -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}'
```

Respuesta original:

```json
{
  "access": "<jwt>",
  "refresh": "<opaco>",
  "tokenType": "Bearer",
  "accessExpiresIn": 3600
}
```

```bash
curl -s http://127.0.0.1:8000/api/auth/profile/ \
  -H "Authorization: Bearer <access>"

curl -s http://127.0.0.1:8000/api/auth/permissions/ \
  -H "Authorization: Bearer <access>"
```

`GET /api/auth/profile/` devuelve el usuario sin envoltorio (`id`, `username`, `email`, `avatar`, `status`, `createdAt`, `updatedAt`).

`GET /api/auth/permissions/` devuelve una fila por permiso efectivo:

```json
{
  "permissions": [
    {
      "method": "GET",
      "path": "/api/clients",
      "roleId": 1,
      "roleName": "ADMIN"
    }
  ]
}
```

Esa forma es la que consumirá el almacén de sesión en ISS-08. El frontend original no recibe `user`, `roles` ni `resources` dentro del login. La clave de permiso es MÉTODO/ruta, con `:id` en el detalle y sin barra final.

## 0.9 Credenciales de laboratorio (EXENTO EN PEDALIBRE)

Esta sección describe usuarios de StoreLab, que no se utilizarán en PedalLibre. Se conserva íntegra como referencia original; no se deben ejecutar sus comandos ni usar esas credenciales en este proyecto.

**Criterios originales**

- [ ] `admin / Admin123!` inicia sesión con rol `ADMIN`.
- [ ] `seller / Seller123!` inicia sesión con rol `SELLER` y solo lecturas del negocio.
- [ ] Dos ejecuciones de `seed_rbac` dejan el mismo conteo.

```bash
cd ~/ia-lab/projects/dw/pry-django
source .venv/bin/activate
python manage.py seed_rbac --username admin
python manage.py seed_rbac --username admin
```

- `admin` ya existe en este laboratorio (`admin@storelab.test`, contraseña `Admin123!`). Si faltara, se crea con `python manage.py createsuperuser` usando ese correo y esa contraseña.
- `seed_rbac --username admin` asegura los roles `ADMIN` y `SELLER`, escribe los recursos desde las rutas reales y asigna `ADMIN` al usuario indicado. Es idempotente.
- `seller` se crea si no existe, con correo `seller@storelab.test`, contraseña `Seller123!` y el rol `SELLER`. El rol solo recibe las lecturas del negocio (`GET` de clientes, tipos, productos, disponibles y ventas, colección y detalle).

| Usuario | Contraseña | Rol | Qué demuestra | Dónde queda |
|---|---|---|---|---|
| `admin` | `Admin123!` | `ADMIN` | Negocio y matriz RBAC | `createsuperuser` + `seed_rbac --username admin` |
| `seller` | `Seller123!` | `SELLER` | Autenticado con solo lecturas | Alta de usuario + asignación del rol |

Los permisos se leen de `GET /api/auth/permissions/`. Un usuario sin rol se autentica y, con `API_ACCESS=rbac`, recibe 403 en las rutas de negocio: la sesión y el permiso son dos comprobaciones distintas. El conteo de filas lo fija el backend (en este laboratorio, 54 para `admin` y 9 para `seller`); el frontend no lo escribe a mano.

## 0.10 Estructura de trabajo (EXENTO EN PEDALIBRE)

Las rutas y el comando siguientes pertenecen al workspace original StoreLab. Se conservan, pero no se deben ejecutar para PedalLibre.

**Criterios originales**

- [ ] La carpeta del frontend existe.
- [ ] No contiene `src/` ni `package.json` antes de ISS-01.
- [ ] Contiene `docs/` con las guías del recorrido.

El proyecto original se crea dentro de la carpeta existente:

```text
~/ia-lab/projects/dw/front-storelab-django
```

No se crea una subcarpeta adicional. En ISS-01 el comando original es `ng new front-storelab-django --directory .`. `ng new .` falla en Angular CLI 22 porque el CLI valida el nombre como paquete npm.

> **Workspace original:** todas las ISS usan esa carpeta. Antes de cada bloque de comandos: `cd ~/ia-lab/projects/dw/front-storelab-django`.

## Verificación original del ISS (PARCIALMENTE EXENTA EN PEDALIBRE)

Los comandos y credenciales de esta verificación son los originales de StoreLab. Se conservan como estaban planteados; no se ejecutan contra PedalLibre.

```bash
# 1. Versiones
node --version && npm --version && ng version && command -v ng
npm view @angular/cli version engines --json

# 2. Backend StoreLab vivo (200 = API_ACCESS=open, 401 = rbac)
curl -s -o /dev/null -w "clients   %{http_code}\n" http://127.0.0.1:8000/api/clients/
curl -s -o /dev/null -w "swagger   %{http_code}\n" http://127.0.0.1:8000/api/schema/swagger-ui/
curl -s -o /dev/null -w "available %{http_code}\n" http://127.0.0.1:8000/api/products/available/

# 3. Login + permisos de admin
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access"])')

curl -s http://127.0.0.1:8000/api/auth/permissions/ \
  -H "Authorization: Bearer $TOKEN" | head -c 300; echo

# 4. Permisos de seller
STOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"seller","password":"Seller123!"}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access"])')

curl -s http://127.0.0.1:8000/api/auth/permissions/ \
  -H "Authorization: Bearer $STOKEN" | head -c 300; echo
```

## Resultado original en el workspace (24-oct-2026) (EXENTO EN PEDALIBRE)

Estos resultados pertenecen al laboratorio StoreLab y se conservan como parte de la ISS original.

| Comprobación | Resultado original |
|---|---|
| `node --version` | `v24.20.0` — cumple `^24.15.0` |
| `npm --version` | `11.19.1` — cumple `>=8.0.0` |
| `engines` de `@angular/cli@22.2.4` | Node `^22.22.3 || ^24.15.0 || >=26.0.0` |
| `ng version` | Angular CLI 22.2.4 |
| `command -v ng` | `~/.nvm/versions/node/v24.20.0/bin/ng` |
| `python manage.py check` | System check identified no issues |
| `runserver` | Ya escuchaba en `127.0.0.1:8000` (WSGIServer, CPython 3.12.3, Django 5.2.17) |
| `GET /api/clients/` | 200, arreglo de 11 clientes |
| `GET /api/schema/swagger-ui/` | 200 |
| `GET /api/products/available/` | 200, 20 productos; `price` string (`"516.10"`) y `productTypeName` presente |
| CORS | `access-control-allow-origin: *` con `Origin: http://localhost:4200` |
| Login `admin` | `access` (231), `refresh` (64), `tokenType=Bearer`, `accessExpiresIn=3600` |
| Perfil `admin` | `admin@storelab.test`, `status=active` |
| Permisos `admin` | 54 filas, rol ADMIN |
| Login `seller` | Creado en esa ejecución; access + refresh |
| Permisos `seller` | 9 filas, todas GET del negocio, rol SELLER |
| `seed_rbac` × 2 | Ambas veces: 54 recursos y 63 concesiones |
| `src/` y `package.json` | Ausentes; listo para ISS-01 |
| DevTools | Pendiente de abrir F12 |

`API_ACCESS` del `.env` de referencia estaba en `open`. Por eso el negocio respondía 200 aunque el código de la Fase II ya estuviera construido. Al empezar ISS-08 ese valor pasaba a `rbac`.

## Cierre original del ISS (EXENTO EN PEDALIBRE)

El cierre original dice que el entorno StoreLab está listo, que el primer archivo se crea en ISS-01 con `ng new front-storelab-django --directory .`, que el backend puede seguir en 8000 y que las ISS que consumen HTTP empiezan en ISS-02. Se conserva como texto de referencia; para el estado de PedalLibre se debe usar el cierre al inicio de este documento.

## Correspondencia original con el código (EXENTA EN PEDALIBRE)

Este ISS original no produce archivos de `src/`. Las comprobaciones pertenecen a `~/ia-lab/projects/dw/pry-django`; el primer archivo del frontend StoreLab era `package.json`, creado en ISS-01.

| Pieza original | Dónde vive en StoreLab |
|---|---|
| Contrato de listas, importes y auth | `pry-django/docs/manual/contrato-api.md` |
| Interruptor `API_ACCESS` | `pry-django/.env` y `config/settings/__init__.py` |
| Semilla RBAC | `python manage.py seed_rbac` |
| Carpeta que ISS-01 va a llenar | `~/ia-lab/projects/dw/front-storelab-django` |

## GATE original (EXENTO EN PEDALIBRE)

```text
TODOS los AC de entorno y contrato = PASS → se puede avanzar a ISS-01
ALGÚN AC = FAIL → se corrige y se repite
```

| AC | Comprobación original | Resultado original |
|---|---|---|
| 0.1 | Node 24.20.0 dentro de engines y npm 11.19.1 | PASS |
| 0.2 | Angular CLI 22.2.4, `ng` resuelve a nvm | PASS |
| 0.3 | Terminal del workspace usada; DevTools del navegador sin captura | Pendiente (navegador) |
| 0.4 | API en :8000, check sin issues, `API_ACCESS=open` | PASS |
| 0.6 | clients, swagger y available en 200; `price` string | PASS |
| 0.7 | Sección 0.7 de la guía | PASS |
| 0.8 | Login admin, perfil y 54 permisos ADMIN | PASS |
| 0.9 | seller con 9 GET, doble `seed_rbac` en 54/63 | PASS |
| 0.10 | Sin `src/` ni `package.json` | PASS |

El GATE original indicaba que el único punto abierto era abrir DevTools cuando se sirviera la primera pantalla y que, con el resto en PASS, se podía avanzar. Para PedalLibre, prevalecen los criterios de aceptación y el estado indicados en las primeras secciones.
