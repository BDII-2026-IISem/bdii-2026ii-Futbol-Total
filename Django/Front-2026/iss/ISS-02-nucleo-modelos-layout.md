

---
# ISS-02 · Núcleo, modelos y layout

> **Proyecto:** Frontend de PedalLibre
> **Capa:** Construir
> **Depende de:** ISS-01B · Menú PrimeNG y primera interacción
> **Habilita:** ISS-03 · CRUD de clientes
> **Estado:** Pendiente

## Objetivo para PedalLibre

Preparar la base compartida del frontend: configuración del endpoint, modelos que reflejen los serializadores reales de Django, servicios para los recursos que corresponden a esta fase, utilidades de mensajes y filtros, componentes reutilizables y el Shell de navegación. Esta ISS deja listas las fronteras entre presentación y API; no implementa todavía el CRUD de clientes de ISS-03.

La API del proyecto es PedalLibre, no StoreLab. Los recursos identificados para el frontend son clientes, bicicletas disponibles, tarifas y autenticación. No crear modelos ni rutas de StoreLab como productos, tipos de producto, ventas o líneas de venta.

## Contexto

- El frontend Angular vive en `Front-2026/` y usa Angular 22, PrimeNG 22 con Aura y Tailwind CSS 4.
- ISS-01B creó la pantalla local `Construir`, el menú y las rutas del prototipo.
- Las rutas de negocio conocidas del backend se registran en [ISS-00](./ISS-00-requisitos-previos.md). Antes de fijar propiedades, tipos o métodos HTTP, contrastaré el código con los serializers y URLs de PedalLibre.
- No habilitaré autenticación, guards, interceptores ni permisos en esta ISS; se trabajan en las ISS de autenticación/RBAC.
- No ejecutaré pruebas automatizadas como requisito para completar esta ISS.

## Criterios de aceptación para PedalLibre

- [ ] **02.1** Existe configuración de entorno para `http://localhost:8000/api`, sin slash final, con reemplazo de archivo para desarrollo.
- [ ] **02.2** Los modelos de cliente, bicicleta y tarifa reflejan los serializers reales del backend; camelCase y tipos coinciden con la conversión acordada en el frontend.
- [ ] **02.3** Los servicios de los recursos de PedalLibre construyen sus URLs desde una única base y respetan las rutas reales, métodos y slash finales.
- [ ] **02.4** `NotificationService` ofrece `success`, `info`, `warn` y `error` sobre `MessageService`.
- [ ] **02.5** `toApiMessage` presenta errores de red y respuestas Django de forma comprensible sin ocultar fallos.
- [ ] **02.6** `filterRows` filtra en memoria sin depender del DOM ni de Angular y no muta el arreglo recibido.
- [ ] **02.7** `Shell` contiene Header, Aside, el outlet de rutas y Footer una sola vez; la ruta del prototipo ISS-01B se conserva.
- [ ] **02.8** Existen componentes compartidos adecuados para estado, encabezado de página y estado vacío.
- [ ] `ng build` termina correctamente. No ejecutar pruebas automatizadas para cerrar esta ISS.

## 02.1 · Environment: una sola base para la API

Desde `Front-2026/`, generar la configuración si no existe:

```bash
npx ng generate environments
```

Configurar `src/environments/environment.ts` y `environment.development.ts` con la URL del backend de PedalLibre. `apiUrl` debe ser `http://localhost:8000/api` sin slash final; cada servicio agrega el recurso y su slash final de acuerdo con las rutas del backend. En `angular.json`, el build de desarrollo reemplaza el environment base por el de desarrollo.

No añadir a este objeto banderas de autenticación, secretos ni claves de licencia. Las decisiones de autenticación pertenecen a sus ISS correspondientes.

## 02.2 · Modelos: reflejar el contrato real de PedalLibre

Crear la carpeta de modelos:

```bash
mkdir -p src/app/core/models
```

Antes de escribir interfaces, consultar los serializers y las rutas de Django. Los modelos a preparar son:

- **Cliente:** propiedades de lectura y payload de escritura correspondientes al serializer de clientes.
- **Bicicleta:** propiedades de la respuesta de bicicletas disponibles; no inventar campos de StoreLab.
- **Tarifa:** propiedades y tipos que realmente entrega el endpoint de tarifas.
- **Tipos compartidos de API:** únicamente estados, fechas, importes y errores que estén presentes en el contrato real.

Usar nombres camelCase en TypeScript cuando el frontend convierta la respuesta; si la API entrega snake_case, documentar y realizar la conversión explícitamente en una frontera compartida, sin declarar tipos que no coincidan con el JSON recibido.

No asumir `status: 'active' | 'inactive'`, `Money = string`, nombres de relaciones ni campos de timestamps por similitud con StoreLab. Confirmar cada uno en el serializer PedalLibre. Los modelos y payloads no deben contener contraseñas que no se envían desde el formulario ni datos sensibles innecesarios.

### Contrato y tipos (SOLO DIDÁCTICO EN PEDALIBRE)

La explicación de por qué se separan modelos de respuesta y payloads, cómo se traducen nombres entre API y TypeScript y cómo se tipan decimales ayuda a entender el contrato. No agregar campos ni conversores hasta que correspondan a una diferencia observada en el backend.

## 02.3 · Servicios por recurso

Crear servicios para clientes, bicicletas disponibles y tarifas según las operaciones publicadas por el backend. El servicio encapsula `HttpClient`, la URL y los tipos de respuesta; no conoce componentes, señales de pantalla ni elementos PrimeNG.

Ejemplo de estructura:

```text
src/app/features/
├── clients/client-api.ts
├── bicycles/bicycle-api.ts
└── rates/rate-api.ts
```

Cada `base` se deriva de `environment.apiUrl` y del recurso real. Confirmar las rutas y métodos antes de escribir los métodos del servicio. No incluir `product-types`, `products`, `sales` ni `product-sales`: no son recursos de PedalLibre.

La respuesta se tipa según el serializer. Si el endpoint devuelve un arreglo plano, modelar un arreglo; no desenvolver objetos inventados como `{ clients: [...] }`. No ejecutar peticiones desde esta ISS solo para completar el documento; la integración de pantalla y las comprobaciones necesarias se harán en la ISS que consuma el recurso.

### Flujo pantalla → servicio → HttpClient → API (SOLO DIDÁCTICO EN PEDALIBRE)

Esta cadena explica dónde debe quedar cada responsabilidad y sirve para razonar sobre el diseño. Por sí sola no agrega una función: la conexión real de una pantalla se implementa en la ISS correspondiente.

## 02.4 · NotificationService

Crear `src/app/core/services/notification.service.ts` como una envoltura pequeña de `MessageService` con métodos `success`, `info`, `warn` y `error`. Registrar `MessageService` en los providers existentes y montar un solo `<p-toast />` en el Shell. No ocultar errores ni presentar un fallo como resultado exitoso.

Los mensajes describen acciones y errores de PedalLibre. No copiar textos que mencionen ventas, productos StoreLab o permisos que aún no estén implementados.

## 02.5 · toApiMessage

Crear una utilidad tipada, por ejemplo `src/app/core/utils/to-api-message.ts`, que reciba `unknown` y maneje al menos:

- errores de conexión (estado 0);
- respuestas con `detail`;
- mensajes de validación por campo;
- respuestas no reconocidas, sin inventar éxito ni descartar información útil.

El texto final de estados 401 y 403 debe ser coherente con la configuración de autenticación y permisos de PedalLibre. No afirmar que existe refresh token ni copiar la estrategia de StoreLab.

## 02.6 · filterRows

Crear `src/app/core/utils/filter-rows.ts` como función pura para filtrar filas locales. Debe devolver una copia cuando la búsqueda esté vacía, no mutar los datos originales y no consultar el DOM ni inyectar Angular. La pantalla consumidora decidirá qué propiedades incluir en su búsqueda.

### Por qué una función pura facilita el filtro (SOLO DIDÁCTICO EN PEDALIBRE)

La separación permite razonar sobre reutilización y mutabilidad, pero esta explicación no implica que exista paginación ni un buscador de servidor.

## 02.7 · Shell y rutas

Crear el Shell en `src/app/layout/shell/` para reutilizar las regiones de layout. Debe mostrar Header, Aside, `<router-outlet />` para sus páginas hijas y Footer una sola vez. Las entradas del menú deben corresponder a PedalLibre y a rutas que realmente existan; la pantalla de `Construir` se conserva en su ruta actual, fuera del Shell si así lo requiere el prototipo de ISS-01B.

`app.routes.ts` monta el Shell con `loadComponent`, declara rutas placeholder para las pantallas que se implementarán en ISS posteriores y redirige la ruta vacía a la pantalla inicial acordada. No conectar todavía `ClientList` ni presentar CRUD completo: eso pertenece a ISS-03.

No añadir rutas de StoreLab (`product-types`, `products`, `sales`, `detalle-ventas` o dashboard) salvo que una ISS PedalLibre posterior las defina explícitamente.

## 02.8 · Componentes compartidos de interfaz

Crear en `src/app/shared/ui/` solo componentes que las pantallas PedalLibre vayan a reutilizar:

- **StatusTag:** presentar un estado que exista en el contrato real.
- **PageHeader:** mostrar el título, descripción y acciones de una pantalla.
- **EmptyState:** presentar una lista sin resultados; no sustituye el estado de error.

Se pueden generar con Angular CLI:

```bash
npx ng generate component shared/ui/status-tag --skip-tests --defaults
npx ng generate component shared/ui/page-header --skip-tests --defaults
npx ng generate component shared/ui/empty-state --skip-tests --defaults
```

No introducir componentes para ventas, productos o roles de StoreLab si no forman parte del frontend PedalLibre.

## 02.9 · Arranque y cierre

Desde la carpeta del frontend, compilar:

```bash
npm run build
```

Registrar el resultado real del build y confirmar visualmente que las rutas muestran el Shell previsto. Las pruebas automatizadas y peticiones directas a la API no son requisitos para avanzar según esta adaptación.

### Resultado

Pendiente de implementar. Los campos, tipos y operaciones se completan después de contrastar el contrato real de Django; no inferirlos del contenido original de StoreLab.

## Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** implementar environment, modelos y servicios PedalLibre, utilidades, Shell y componentes compartidos; compilar.
- **Estado final:** Pendiente.
- **Siguiente:** ISS-03 · CRUD de clientes.

## Correspondencia con el código

- `src/environments/environment.ts`
- `src/environments/environment.development.ts`
- `src/app/core/models/`
- `src/app/core/services/notification.service.ts`
- `src/app/core/utils/to-api-message.ts`
- `src/app/core/utils/filter-rows.ts`
- `src/app/features/clients/client-api.ts`
- `src/app/features/bicycles/bicycle-api.ts`
- `src/app/features/rates/rate-api.ts`
- `src/app/layout/shell/`
- `src/app/shared/ui/`
- `src/app/app.routes.ts`

---

# ISS-02 original · Núcleo: environment, modelos, servicios y layout (EXENTO EN PEDALIBRE: StoreLab)

> El contenido original se conserva íntegro a continuación como referencia. Las entidades, endpoints, campos y resultados propios de StoreLab no son requisitos de PedalLibre. Las explicaciones conceptuales que no describen una función de PedalLibre se conservan solo como material didáctico.

🛠 Unidad ISS-02 · Núcleo, modelos y layout — capa 🛠 CONSTRUIR🧠 Comprender este bloque → · ↑ Ruta Frontend-DjangoCapaPáginaPara qué🧠 AprenderNúcleo, modelos y layoutcomprender, explicar y relacionar🛠 Construiresta páginaejecutar, verificar y entregarISS-02 · Núcleo: environment, modelos, servicios y layoutContexto mínimo (autosuficiente). Si abres este archivo aislado —o lo llevas a otra IA—, esto es lo que hay que saber antes de ejecutarlo. - Proyecto: front-storelab-django — Angular 22 (standalone + zoneless + signals), PrimeNG 22 en modo styled con Aura y Tailwind CSS 4. Sin CSS de negocio ni PrimeFlex. - Backend: pry-django en http://localhost:8000/api. Listas planas, importes string, rutas con barra final. El interruptor de fases es API_ACCESS del backend, no una bandera del frontend. - Estado al terminar ISS-01B: features/construir tiene el prototipo, App es solo &lt;router-outlet /&gt; y / redirige a /construir. No hay HTTP ni modelos. - Patrón visual: PATRON-VISUAL.md.Este ISSTítuloNúcleo: environment, modelos, servicios y layoutFeature / tablacore/models, core/services, core/utils, un feature/*-api por entidad, shared/ui, layout/shellAPIcontrato REST (se declara; las pantallas de negocio todavía no lo consumen, salvo el reemplazo de /clientes en ISS-03)Depende deISS-01B — Menú PrimeNG e interacciónHabilitaISS-03 — CRUD de clientesMisma estructura que Express. Environment, modelos, servicios, toApiMessage, NotificationService, tres componentes compartidos y Shell. Cambia el contrato: puerto 8000, listas planas (no hay { clients } que desenvolver), campos en camelCase, barra final en cada ruta y API_ACCESS en el backend en lugar de requireAuth / AUTH_ENABLED.Evidencia de aprendizaje: dibujas la cadena pantalla → servicio → HttpClient → API Django → respuesta y explicas por qué apiUrl no lleva barra final y por qué un importe viaja como string.ObjetivoLa aplicación ya tiene layout y menú, pero todo lo que muestra es local. Esta ISS construye la capa que la convierte en cliente de la API Django: una sola URL, los modelos que copian el contrato, un servicio por entidad, el servicio de avisos, dos utilidades y las rutas que meten las pantallas de Fase I dentro del Shell.Ninguna pantalla de negocio está terminada: las rutas se montan con un componente provisional para recorrer el layout sin inventar tablas. Lo que sí queda cerrado es el contrato —campos, tipos, rutas y forma de las respuestas—; cambiarlo después obliga a tocar cada pantalla.Encaje en las dos fases. No hay login, guards, Authorization ni permisos: la Fase I consume el negocio abierto. Contra el backend consolidado verás un 401 en el p-message: es el comportamiento correcto y se resuelve en ISS-08/ISS-09. Aquí todavía no se hace ninguna petición HTTP real.Requisitos[ ] 02.1 environment.apiUrl === 'http://localhost:8000/api', sin barra final, y angular.json aplica fileReplacements[ ] 02.2 Los siete modelos usan camelCase, importes string, fechas string y status: 'active' | 'inactive'[ ] 02.3 Cada servicio arma sus URL desde this.base, que no lleva barra final[ ] 02.4 NotificationService envuelve MessageService con success, info, warn y error[ ] 02.5 toApiMessage traduce detail, errores por campo y los códigos 400/401/403/404/409[ ] 02.6 filterRows filtra en memoria, sin DOM ni Angular[ ] 02.7 app.routes.ts monta Shell con loadComponent y las pantallas de Fase I como hijas[ ] 02.8 ng build termina con código 0 y la prueba del servicio de clientes queda en verdeConstrucción02.1 environment: una sola URL para todo el frenteng generate environments
environment.ts es el base (lo usa ng build); environment.development.ts es el que Angular importa con ng serve y ng test gracias a fileReplacements.src/environments/environment.ts/**
 * `apiUrl` termina en `/api` SIN barra final: cada servicio añade la suya
 * (`${base}/`) porque todas las rutas del contrato terminan en `/`.
 */
export const environment = {
  production: true,
  appName: 'StoreLab',
  apiUrl: 'http://localhost:8000/api',
  /** Clave Community de PrimeUI. `''` deja el aviso en consola; la app funciona. */
  primeUiLicense: '',
};
environment.development.ts repite el objeto con production: false. Si los dos apiUrl se separan, la aplicación deja de apuntar al mismo backend.angular.json → projects.&lt;proyecto&gt;.architect.build.configurations.development"development": {
  "optimization": false,
  "sourceMap": true,
  "fileReplacements": [
    {
      "replace": "src/environments/environment.ts",
      "with": "src/environments/environment.development.ts"
    }
  ]
}
La barra final no es cosmética. Con .../api/, la petición saldría como .../api//clients/: Django no resuelve esa ruta y responde 404 con el recurso existiendo. La prueba de §02.3 fija el valor con expect(environment.apiUrl.endsWith('/api')).toBe(true).02.2 Modelos: la forma del contrato, no la de la baseng generate interface core/models/api --type=model --defaults
ng generate interface core/models/client --type=model --defaults
ng generate interface core/models/product-type --type=model --defaults
ng generate interface core/models/product --type=model --defaults
ng generate interface core/models/sale --type=model --defaults
ng generate interface core/models/product-sale --type=model --defaults
ng generate interface core/models/auth --type=model --defaults
Cada comando deja un *.model.ts con una interfaz vacía. Reemplaza su contenido, no su nombre: el archivo es client.model.ts y el export es Client.src/app/core/models/api.model.ts — lo que comparten todos./** Estado único del contrato: la baja es lógica, nunca borra la fila. */
export type Status = 'active' | 'inactive';

/** Importe tal como viaja: string decimal ("12.50"). Nunca se opera con float. */
export type Money = string;

/** Métodos de `resources.method` (Fase II). */
export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

/** Fechas del contrato: ISO-8601 con zona. */
export interface Timestamps { createdAt?: string; updatedAt?: string; }

/** Cuerpo de error: `{ "detail": "..." }` o `{ "campo": ["mensaje"] }`. */
export interface ApiError { detail?: string; }

/** Importe del contrato a número, para sumar o comparar en el dashboard. */
export function toNumber(value: Money | number | null | undefined): number {
  const parsed = Number(value ?? 0);
  return Number.isFinite(parsed) ? parsed : 0;
}
client.model.ts y product-type.model.tsimport { Status, Timestamps } from './api.model';

/** Tabla `clients` — /api/clients/. `password` es de solo escritura y la UI no lo pide. */
export interface Client extends Timestamps {
  id: number; name: string; address: string | null; phone: string | null;
  email: string | null; status: Status;
}

/** Cuerpo de `POST` y `PATCH`: sin `id` y sin `status` (lo cambia la baja). */
export interface ClientPayload {
  name: string; address: string | null; phone: string | null; email: string | null;
}
import { Status, Timestamps } from './api.model';

/** Tabla `product_types` — /api/product-types/. `name` NO es único. */
export interface ProductType extends Timestamps {
  id: number; name: string; description: string | null; status: Status;
}

export interface ProductTypePayload { name: string; description: string | null; }
product.model.ts — productTypeId al escribir; productTypeName solo al leer.import { Money, Status, Timestamps } from './api.model';

/** Tabla `products` — /api/products/. */
export interface Product extends Timestamps {
  id: number; productTypeId: number; productTypeName?: string;
  name: string; brand: string; price: Money;
  minStock: number;  // umbral de reposición
  quantity: number;  // existencia actual
  status: Status;
}

export interface ProductPayload {
  productTypeId: number; name: string; brand: string;
  price: Money; minStock: number; quantity: number;
}
product-sale.model.ts y sale.model.ts — la venta y sus líneas.import { Money, Status, Timestamps } from './api.model';

/** Tabla `product_sales`: una fila es una línea de venta. */
export interface ProductSale extends Timestamps {
  id: number; saleId: number; productId: number; quantity: number;
  unitPrice: Money;  // copia del precio vigente: inmutable
  lineTotal: Money;  // quantity × unitPrice; lo calcula el servidor
  status: Status;
}

/** Línea tal como llega dentro de `sale.items`. */
export type SaleItemLine = Pick&lt;
  ProductSale, 'productId' | 'quantity' | 'unitPrice' | 'lineTotal'
&gt;;

/** Línea que envía el cliente: solo producto y cantidad. */
export interface SaleItemInput { productId: number; quantity: number; }
import { Money, Status, Timestamps } from './api.model';
import { SaleItemInput, SaleItemLine } from './product-sale.model';

/** Tabla `sales` — /api/sales/. El listado ya trae `items`: el detalle no repite la llamada. */
export interface Sale extends Timestamps {
  id: number; clientId: number; saleDate: string;
  subtotal: Money; tax: Money; discounts: Money; total: Money;
  status: Status; items?: SaleItemLine[];
}

/** POST /api/sales/: el servidor calcula importes, totales y stock. */
export interface SaleCreatePayload {
  clientId: number; saleDate: string; discounts: Money; items: SaleItemInput[];
}
auth.model.ts — usuario, tokens y permiso efectivo. Se consumen en ISS-08.import { HttpMethod, Status, Timestamps } from './api.model';

/** GET /api/auth/profile/: el usuario llega directo, sin envoltorio `user`. */
export interface User extends Timestamps {
  id: number; username: string; email: string; avatar: string | null; status: Status;
}

/** Login y refresh comparten cuerpo; el refresh rota en cada uso. */
export interface SessionTokens {
  access: string; refresh: string; tokenType: 'Bearer'; accessExpiresIn: number;
}

/** Una fila de `GET /api/auth/permissions/`. La clave es `method + ' ' + path`. */
export interface EffectivePermission {
  method: HttpMethod; path: string; roleId: number; roleName: string;
}
DecisiónConsecuenciaUna sola URL: environment.apiUrlCambiar de backend es editar un archivoListas planas: Client[], no { clients: [] }El servicio no desenvuelve nada; la tabla recibe el arregloImportes string: "12.50"Se muestran tal cual y se suman con toNumber()status como uniónrow.status === 'active' se valida al compilar02.3 Servicios por entidadng generate service features/clients/client-api --skip-tests --defaults
ng generate service features/product-types/product-type-api --skip-tests --defaults
ng generate service features/products/product-api --skip-tests --defaults
ng generate service features/sales/sale-api --skip-tests --defaults
ng generate service features/product-sales/product-sale-api --skip-tests --defaults
src/app/features/clients/client-api.ts es el patrón: base una sola vez, sin barra final, y un método por caso del contrato.import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Status } from '../../core/models/api.model';
import { Client, ClientPayload } from '../../core/models/client.model';

/** Único punto de contacto con `/api/clients/`. */
@Injectable({ providedIn: 'root' })
export class ClientApi {
  private readonly http = inject(HttpClient);
  /** Sin barra final: el sufijo `/` se agrega en cada método, a la vista. */
  private readonly base = `${environment.apiUrl}/clients`;

  list(): Observable&lt;Client[]&gt; {
    return this.http.get&lt;Client[]&gt;(`${this.base}/`);
  }

  get(id: number): Observable&lt;Client&gt; {
    return this.http.get&lt;Client&gt;(`${this.base}/${id}/`);
  }

  /** El alta envía `status: 'active'`: en la base el registro nace `inactive`. */
  create(payload: ClientPayload &amp; { status: Status }): Observable&lt;Client&gt; {
    return this.http.post&lt;Client&gt;(`${this.base}/`, payload);
  }

  /** PATCH: el formulario envía solo los campos que cambiaron. */
  update(id: number, payload: Partial&lt;ClientPayload&gt;): Observable&lt;Client&gt; {
    return this.http.patch&lt;Client&gt;(`${this.base}/${id}/`, payload);
  }

  /** DELETE: baja lógica, responde 204 sin cuerpo. */
  remove(id: number): Observable&lt;void&gt; {
    return this.http.delete&lt;void&gt;(`${this.base}/${id}/`);
  }
}
Los otros cuatro archivos copian la misma estructura —imports, @Injectable, http y base— cambiando entidad y tipos. Lo único que añaden o cambian es esto:// product-type-api.ts — `status` es opcional como filtro
private readonly base = `${environment.apiUrl}/product-types`;
list(status?: Status): Observable&lt;ProductType[]&gt; {
  const options = status ? { params: { status } } : {};
  return this.http.get&lt;ProductType[]&gt;(`${this.base}/`, options);
}

// product-api.ts — GET /products/available/: active, quantity &gt; 0 y tipo active
private readonly base = `${environment.apiUrl}/products`;
available(): Observable&lt;Product[]&gt; {
  return this.http.get&lt;Product[]&gt;(`${this.base}/available/`);
}

// sale-api.ts — POST transaccional y DELETE que anula
private readonly base = `${environment.apiUrl}/sales`;
create(payload: SaleCreatePayload): Observable&lt;Sale&gt; {
  return this.http.post&lt;Sale&gt;(`${this.base}/`, payload);
}
/** DELETE /sales/{id}/: anula la venta y repone el stock una sola vez. */
voidSale(id: number): Observable&lt;void&gt; {
  return this.http.delete&lt;void&gt;(`${this.base}/${id}/`);
}
SaleApi no lleva update ni remove: el contrato no publica PUT/PATCH /sales/{id}/. Corregir una venta es anularla y registrarla de nuevo.product-sale-api.ts — la línea no tiene recurso propio: viaja dentro de la venta.import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import { SaleItemLine } from '../../core/models/product-sale.model';
import { Sale } from '../../core/models/sale.model';

/** No existe `/product-sales/`: las líneas se leen de cada venta. */
@Injectable({ providedIn: 'root' })
export class ProductSaleApi {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/sales`;

  /** Todas las líneas, aplanadas para la tabla de detalle. */
  list(): Observable&lt;SaleItemLine[]&gt; {
    return this.http.get&lt;Sale[]&gt;(`${this.base}/`).pipe(map((s) =&gt; s.flatMap((v) =&gt; v.items ?? [])));
  }

  /** Líneas de una venta concreta, sin una segunda llamada al servidor. */
  bySale(saleId: number): Observable&lt;SaleItemLine[]&gt; {
    return this.http.get&lt;Sale&gt;(`${this.base}/${saleId}/`).pipe(map((s) =&gt; s.items ?? []));
  }
}
ArchivobaseEntidadclient-api.ts/clientsClientproduct-type-api.ts/product-types + ?status=ProductTypeproduct-api.ts/products + available()Productsale-api.ts/sales + create/voidSaleSaleproduct-sale-api.ts/sales (solo lectura)SaleItemLinePor qué el servicio no conoce componentes. ClientApi no sabe que existe una tabla, un diálogo ni un signal: recibe datos y devuelve Observable&lt;Client&gt;.client-list.html → client-list.ts → ClientApi.list() → HttpClient → GET /api/clients/ → Django
                                    ↑ el servicio solo traduce contrato: URL, método y tipo
Esa frontera permite usar el mismo servicio en la tabla, el detalle y el dashboard sin duplicar URL, y probarlo con HttpTestingController sin montar la pantalla.Falta habilitar HttpClient en src/app/app.config.ts, junto a MessageService:import { provideHttpClient } from '@angular/common/http';

// dentro de `providers`:
provideHttpClient(), // sin interceptores: el de sesión llega en ISS-08
Prueba del servicio. src/app/features/clients/client-api.spec.tsimport { provideHttpClient } from '@angular/common/http';
import {
  HttpTestingController,
  provideHttpClientTesting,
} from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../../environments/environment';
import { Client } from '../../core/models/client.model';
import { ClientApi } from './client-api';

const CLIENTE: Client = {
  id: 1, name: 'Ana Torres', address: 'Calle 10 # 20-30', phone: '3001234567',
  email: 'ana@storelab.test', status: 'active',
};

describe('ClientApi', () =&gt; {
  let api: ClientApi;
  let http: HttpTestingController;

  beforeEach(() =&gt; {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    api = TestBed.inject(ClientApi);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() =&gt; http.verify());

  it('should read the flat array from http://localhost:8000/api/clients/', () =&gt; {
    expect(environment.apiUrl.endsWith('/api')).toBe(true);

    let resultado: Client[] | undefined;
    api.list().subscribe((clients) =&gt; (resultado = clients));

    const peticion = http.expectOne('http://localhost:8000/api/clients/');
    expect(peticion.request.method).toBe('GET');
    peticion.flush([CLIENTE]); // arreglo plano: no hay `{ clients: [...] }`

    expect(resultado).toEqual([CLIENTE]);
  });
});
http.verify() falla si quedó una petición sin responder, así que la prueba también detecta llamadas de más.02.4 NotificationServiceimport { Injectable, inject } from '@angular/core';
import { MessageService } from 'primeng/api';

/** Azúcar sobre MessageService: la duración de un aviso se decide una sola vez. */
@Injectable({ providedIn: 'root' })
export class NotificationService {
  private readonly messages = inject(MessageService);

  success(summary: string, detail?: string): void {
    this.messages.add({ severity: 'success', summary, detail, life: 3000 });
  }

  info(summary: string, detail?: string): void {
    this.messages.add({ severity: 'info', summary, detail, life: 4000 });
  }

  warn(summary: string, detail?: string): void {
    this.messages.add({ severity: 'warn', summary, detail, life: 4500 });
  }

  error(summary: string, detail?: string): void {
    this.messages.add({ severity: 'error', summary, detail, life: 6000 });
  }
}
El &lt;p-toast /&gt; que lo muestra se monta una sola vez, en el Shell de ISS-01A. warn es el aviso de la baja lógica: la operación salió bien y el registro sigue existiendo.02.5 toApiMessage: el error de Django en una fraseimport { HttpErrorResponse } from '@angular/common/http';
import { ApiError } from '../models/api.model';

/** Texto de respaldo cuando el cuerpo no trae nada útil. */
const POR_CODIGO: Record&lt;number, string&gt; = {
  400: 'Revisa los datos del formulario.',
  401: 'La sesión no es válida. Vuelve a iniciar sesión.',
  403: 'No tienes autorización para esta operación.',
  404: 'El registro ya no existe.',
  409: 'Ese dato ya está registrado.',
};

/** Traduce el error HTTP del contrato a un mensaje legible. */
export function toApiMessage(error: unknown): string {
  if (!(error instanceof HttpErrorResponse)) {
    return error instanceof Error ? error.message : 'Error inesperado';
  }
  if (error.status === 0) {
    return 'No se pudo conectar con la API. Verifica que Django esté en http://localhost:8000.';
  }

  const body: unknown = error.error;
  const detail = body &amp;&amp; typeof body === 'object' ? (body as ApiError).detail : null;
  if (typeof detail === 'string' &amp;&amp; detail.trim()) {
    return detail.trim();
  }

  // 400 de serializer: `{ "campo": ["mensaje"] }` → "campo: mensaje".
  if (body &amp;&amp; typeof body === 'object' &amp;&amp; !Array.isArray(body)) {
    for (const [campo, valor] of Object.entries(body as Record&lt;string, unknown&gt;)) {
      const mensaje = Array.isArray(valor) ? valor[0] : valor;
      if (typeof mensaje === 'string' &amp;&amp; mensaje.trim()) {
        return `${campo}: ${mensaje.trim()}`;
      }
    }
  }

  return POR_CODIGO[error.status] ?? error.message;
}
status === 0 tiene rama propia porque no es un fallo del servidor sino de red o CORS; buscar el error en el formulario cuando el backend está apagado cuesta media clase. El 401 lo resuelve el interceptor de ISS-08 —refresca una vez— y el 403 de RBAC muestra el detail opaco que Django envía a propósito, sin revelar qué permiso falta.02.6 filterRows: el buscador de la tablaPrimeNG 22 ya no expone globalFilter en p-table, así que se filtra el arreglo antes de entregarlo a [value]. Al ser una función pura se prueba sin montar nada./**
 * Filtro local para las tablas. `pick` decide qué campos se comparan y `[...rows]`
 * devuelve una copia: el llamador no muta el signal original.
 */
export function filterRows&lt;T&gt;(
  rows: readonly T[],
  query: string,
  pick: (row: T) =&gt; Array&lt;string | number | null | undefined&gt;,
): T[] {
  const term = query.trim().toLowerCase();
  if (!term) return [...rows];
  return rows.filter((row) =&gt;
    pick(row).some((value) =&gt; (value ?? '').toString().toLowerCase().includes(term)));
}
Uso previsto: [value]="filterRows(clients(), term(), (c) =&gt; [c.name, c.email])". El filtro es local porque los listados llegan completos: no hay paginación en el servidor.02.7 Rutas: el layout recibe sus pantallasISS-01B dejó el prototipo en /construir, con su propio layout. Desde aquí Shell es la ruta raíz de Fase I: Header, Aside, &lt;router-outlet /&gt; y Footer se montan una sola vez. El prototipo sigue en su ruta, fuera del Shell. El menú vive en Shell.items (Express aplaza nav.config.ts a la Fase II).&lt;!-- src/app/app.html --&gt;
&lt;router-outlet /&gt;
src/app/features/placeholder/placeholder.ts ocupa las rutas hasta que cada ISS escriba su pantalla. Se sustituye, no se amplía.import { Component } from '@angular/core';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';

@Component({
  selector: 'app-placeholder',
  imports: [CardModule, TagModule],
  template: `
    &lt;p-tag value="Fase I" severity="warn" [rounded]="true" /&gt;
    &lt;p-card header="Pantalla en construcción" class="mt-4"&gt;
      &lt;p class="m-0 text-slate-600"&gt;El layout ya está montado; esta pantalla llega en su ISS.&lt;/p&gt;
    &lt;/p-card&gt;
  `,
})
export class Placeholder {}
src/app/app.routes.tsimport { Routes } from '@angular/router';

/** Una sola entrada provisional para todas las pantallas de Fase I. */
const provisional = () =&gt;
  import('./features/placeholder/placeholder').then((m) =&gt; m.Placeholder);

export const routes: Routes = [
  {
    path: 'construir',
    loadComponent: () =&gt; import('./features/construir/construir').then((m) =&gt; m.Construir),
  },
  {
    path: '',
    loadComponent: () =&gt; import('./layout/shell/shell').then((m) =&gt; m.Shell),
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'clientes' },
      { path: 'clientes', title: 'Clientes · StoreLab', loadComponent: provisional },
      { path: 'tipos-producto', title: 'Tipos · StoreLab', loadComponent: provisional },
      { path: 'productos', title: 'Productos · StoreLab', loadComponent: provisional },
      { path: 'ventas', title: 'Ventas · StoreLab', loadComponent: provisional },
      { path: 'detalle-ventas', title: 'Líneas · StoreLab', loadComponent: provisional },
      { path: 'dashboard', title: 'Panel · StoreLab', loadComponent: provisional },
    ],
  },
  { path: '**', redirectTo: 'construir' },
];
loadComponent mantiene cada pantalla en su chunk: el bundle inicial no arrastra tablas ni formularios. Cada ISS de Fase I reemplaza una línea: clientes en ISS-03, tipos-producto en ISS-04, productos en ISS-05 y ventas/detalle-ventas/dashboard en ISS-06 e ISS-07. En este workspace, cerradas ISS-02 e ISS-03, clientes ya carga ClientList; el resto sigue en el placeholder.02.8 Componentes compartidos de interfazLas pantallas de la Fase I repiten tres piezas. Se crean una sola vez, aquí, para que ISS-03 en adelante no invente su propia versión:ng generate component shared/ui/status-tag --skip-tests --defaults
ng generate component shared/ui/page-header --skip-tests --defaults
ng generate component shared/ui/empty-state --skip-tests --defaults
src/app/shared/ui/status-tag/status-tag.tsimport { Component, computed, input } from '@angular/core';
import { TagModule } from 'primeng/tag';
import { Status } from '../../../core/models/api.model';

/** Estado de un registro: `active` o `inactive`. No conoce la API. */
@Component({
  selector: 'app-status-tag',
  imports: [TagModule],
  template: `&lt;p-tag [value]="label()" [severity]="severity()" /&gt;`,
  host: { class: 'inline-block' },
})
export class StatusTag {
  readonly status = input.required&lt;Status&gt;();
  readonly label = computed(() =&gt; (this.status() === 'active' ? 'Activo' : 'Inactivo'));
  readonly severity = computed(() =&gt; (this.status() === 'active' ? 'success' : 'danger'));
}
src/app/shared/ui/page-header/page-header.tsimport { Component, input } from '@angular/core';

/** Título, descripción y acciones de una pantalla. Proyecta los botones. */
@Component({
  selector: 'app-page-header',
  template: `
    &lt;header class="flex flex-col gap-2 md:flex-row md:items-end md:justify-between"&gt;
      &lt;div class="flex flex-col gap-1"&gt;
        &lt;h1 class="text-2xl font-semibold text-slate-900"&gt;{{ title() }}&lt;/h1&gt;
        @if (subtitle()) { &lt;p class="text-sm text-slate-500"&gt;{{ subtitle() }}&lt;/p&gt; }
      &lt;/div&gt;
      &lt;div class="flex flex-wrap gap-2"&gt;&lt;ng-content /&gt;&lt;/div&gt;
    &lt;/header&gt;
  `,
  host: { class: 'block' },
})
export class PageHeader {
  readonly title = input.required&lt;string&gt;();
  readonly subtitle = input('');
}
src/app/shared/ui/empty-state/empty-state.tsimport { Component, input } from '@angular/core';

/** Lista vacía o sin coincidencias. Nunca sustituye al mensaje de error. */
@Component({
  selector: 'app-empty-state',
  template: `
    &lt;div class="flex flex-col items-center gap-2 py-10 text-center"&gt;
      &lt;i [class]="icon() + ' text-4xl text-slate-300'"&gt;&lt;/i&gt;
      &lt;p class="font-medium text-slate-600"&gt;{{ title() }}&lt;/p&gt;
      &lt;p class="text-sm text-slate-500"&gt;{{ message() }}&lt;/p&gt;
    &lt;/div&gt;
  `,
})
export class EmptyState {
  readonly icon = input('pi pi-inbox');
  readonly title = input.required&lt;string&gt;();
  readonly message = input('');
}
Los tres son standalone, no inyectan servicios y no consultan la API. status-tag traduce el estado, page-header compone la cabecera y empty-state cubre el caso sin filas.02.9 Arranqueng build
ng test --watch=false
ng serve
ng build termina con código 0 y lista un chunk shell. En http://localhost:4200 se ve el Header, el menú lateral, la tarjeta «Pantalla en construcción» y el Footer. A 400 px el Aside desaparece y el botón del Header abre el Drawer.Cómo probarlocurl -s http://localhost:8000/api/clients/ devuelve [{...}]: arreglo plano, sin envoltorio.ng test --watch=false: la prueba de ClientApi pasa; si una URL se rompe, el mensaje muestra la esperada y la recibida.En Network, recorre el menú: todavía no hay peticiones /api.grep -rn "localhost:8000" src/app no devuelve nada: el host solo vive en environment.Criterios de aceptaciónAC-02-01: environment.apiUrl es http://localhost:8000/api (sin barra final), existe environment.development.ts y angular.json aplica fileReplacements.AC-02-02: los siete modelos existen y usan camelCase, importes string, fechas string y status como unión.AC-02-03: Product incluye brand, minStock, quantity, productTypeId y productTypeName de solo lectura.AC-02-04: Sale incluye items y la línea describe unitPrice y lineTotal.AC-02-05: cada servicio arma sus URL desde this.base, que no lleva barra final.AC-02-06: list() devuelve arreglo plano y la prueba lo comprueba sobre http://localhost:8000/api/clients/.AC-02-07: available() llama a /products/available/ y voidSale() hace DELETE en /sales/{id}/.AC-02-08: toApiMessage traduce detail, errores por campo y los códigos 400/401/403/404/409.AC-02-09: filterRows no usa DOM, no muta la entrada y devuelve copia sin término.AC-02-10: NotificationService expone success, info, warn y error sobre MessageService.AC-02-11: app.routes.ts monta Shell con loadComponent y las seis pantallas de Fase I como hijas.AC-02-12: ng build termina con código 0 y ng test --watch=false queda en verde.AC-02-13: los tres componentes compartidos (app-status-tag, app-page-header, app-empty-state) existen como standalone, usan input() y computed() y ng build los resuelve sin advertencias.Verificación del ISSResultado en este workspace (24-oct-2026)Medido al cerrar ISS-02 junto con ISS-03 (la ruta clientes ya apunta a ClientList).ComprobaciónResultadong buildcódigo 0; Initial total 549.65 kB (main 521.50 kB + estilos 28.15 kB)Chunks diferidosshell 60.64 kB, client-list 566.22 kB, construir 2.73 kB, placeholder 681 bytesng test --watch=false9 archivos, 23 pruebasGET /api/clients/arreglo plano; el primer objeto trae id, name, status, createdAt/Entra al Shell y redirige a /clientes/tipos-productoMisma cáscara; tarjeta «Pantalla en construcción»; título Tipos · StoreLab/construirPrototipo de ISS-01B, sin app-shell y sin peticiones /apiprovideHttpClient()Registrado en app.config.ts, sin interceptoresACComprobaciónResultadoAC-02-01apiUrl es http://localhost:8000/api y angular.json aplica fileReplacementsPASSAC-02-02Siete modelos en core/models, camelCase, importes stringPASSAC-02-03Product incluye brand, minStock, quantity, productTypeId, productTypeNamePASSAC-02-04Sale.items y la línea con unitPrice y lineTotalPASSAC-02-05Cada servicio arma la URL desde this.basePASSAC-02-06ClientApi espera http://localhost:8000/api/clients/ y un arreglo planoPASSAC-02-07available() y voidSale() en los servicios de productos y ventasPASSAC-02-08toApiMessage cubre detail, errores por campo y 400/401/403/404/409PASSAC-02-09filterRows devuelve copia y no muta la entradaPASSAC-02-10NotificationService expone las cuatro severidadesPASSAC-02-11Shell con loadComponent y las seis hijas de Fase IPASSAC-02-12ng build 0 y 23 pruebas en verdePASSAC-02-13app-status-tag, app-page-header y app-empty-statePASSEvidenciasEVI-02-01: captura de src/environments/ y del fileReplacements de angular.json.EVI-02-02: captura de api.model.ts y de product.model.ts con los campos del contrato.EVI-02-03: captura de ng test --watch=false con la prueba de ClientApi en verde.EVI-02-04: captura de ng build con el chunk shell y de /clientes con el layout.EVI-02-05: diagrama propio de pantalla → servicio → API con el eslabón donde se desenvuelve la respuesta y la razón por la que los importes son string.GATETODOS los AC = PASS  → se puede avanzar a ISS-03
ALGÚN AC = FAIL       → se corrige y se repite
Siguiente: ISS-03 — CRUD de clientes usa ClientApi en la primera pantalla real, hija de Shell, y reemplaza el placeholder de /clientes.Navegación de la ruta: ← ISS-01B · 🛠 Construir · ↑ Ruta Frontend-Django · → ISS-03 · 🛠 Construir
