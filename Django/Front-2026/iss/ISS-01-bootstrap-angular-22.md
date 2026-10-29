# ISS-01 · Bootstrap Angular 22 con CLI

> **Proyecto:** Frontend de PedalLibre
> **Capa:** Construir
> **Depende de:** ISS-00 · Requisitos previos
> **Habilita:** ISS-01A · Esqueleto Header/Aside/Footer
> **Estado:** Pendiente de ejecutar

## Objetivo

Crear la aplicación Angular 22 dentro de `Front-2026/`, instalar Tailwind CSS 4 y PrimeNG 22 con Aura y dejar una pantalla de demostración local funcionando. Esta ISS prepara la estructura y el estilo iniciales: todavía no conecta con la API de PedalLibre, no configura autenticación y no cambia RBAC.

## Contexto de PedalLibre

- El backend es PedalLibre y está desarrollado en Django. La API y sus entidades reales se consultarán al implementar las ISS que consuman datos.
- El código Angular se creará directamente dentro de `Front-2026/`, conservando las carpetas `iss/` y `trazabilidad/`.
- El ejercicio de esta ISS es una demostración local de Angular, no una pantalla de negocio ni una llamada a `/api/`.
- La demostración se nombrará con términos neutrales de PedalLibre; no se usarán nombres, productos, precios o cuentas de StoreLab como si fueran datos reales.
- El patrón visual y las convenciones se consultan en `PATRON-VISUAL.md`; la plantilla del recorrido está en `README.md`.
- ISS-00 está completada. No hay requisito de volver a ejecutar pruebas de autenticación o API para iniciar esta ISS.

## Criterios de aceptación para PedalLibre

- [ ] **1.1** Angular 22 se crea directamente en `Front-2026/`; `angular.json`, `package.json` y `src/main.ts` quedan en esa carpeta y no en una subcarpeta adicional.
- [ ] **1.1** Angular genera `src/app/app.routes.ts` y `provideRouter` queda registrado en `app.config.ts`.
- [ ] **1.2** Tailwind CSS 4 y su plugin PostCSS quedan instalados y configurados.
- [ ] **1.3** `src/styles.css` carga Tailwind y PrimeIcons con el orden de capas establecido.
- [ ] **1.4** PrimeNG 22 usa Aura; se registran `MessageService` y `ConfirmationService`, y se configura el modo oscuro.
- [ ] **1.5** La aplicación inicial muestra un componente de demostración local, sin solicitudes HTTP; `app.routes.ts` no enruta todavía a pantallas de negocio.
- [ ] **1.6** `index.html` usa idioma español y título del frontend PedalLibre.
- [ ] **1.7** El presupuesto inicial de compilación queda en 750 kB de advertencia y 1 MB de error.
- [ ] **1.8** La aplicación inicia en `http://127.0.0.1:4200/`; se ejecutan build y pruebas y se registran sus resultados reales.
- [ ] **1.9** La demostración ilustra `signal`, `computed` y `effect` con un objeto local, sin afirmar que representa datos cargados desde PedalLibre.

La demostración concreta de StoreLab y sus valores de muestra no son parte del frontend PedalLibre. Se conservan en la sección original más abajo y se marcan como exentos; en PedalLibre se usa una demostración local neutral.

## 1.1 · Crear el proyecto en `Front-2026/`

Desde la raíz del repositorio:

```bash
cd Front-2026
ng new pedalibre-frontend \
  --directory . \
  --style=css \
  --routing \
  --ssr=false \
  --skip-git \
  --package-manager=npm \
  --defaults
```

`--directory .` crea los archivos en la carpeta actual. `--skip-git` evita inicializar un repositorio anidado, porque `Front-2026/` está dentro del repositorio existente. No borraré las carpetas `iss/` ni `trazabilidad/`.

Verifico que `angular.json`, `package.json`, `src/main.ts`, `src/app/app.config.ts` y `src/app/app.routes.ts` quedaron dentro de `Front-2026/`.

## 1.2 · Tailwind CSS 4 con PostCSS

```bash
npm install tailwindcss @tailwindcss/postcss postcss
```

El archivo `.postcssrc.json` debe declarar el plugin:

```json
{
  "plugins": {
    "@tailwindcss/postcss": {}
  }
}
```

Tailwind CSS 4 se configura con el plugin de PostCSS; no requiere `tailwind.config.js` para esta configuración inicial.

## 1.3 · Estilos globales

`src/styles.css` es la hoja global. Debe cargar las capas y los estilos requeridos:

```css
@layer theme, base, primeng, utilities;
@import "tailwindcss";
@import "primeicons/primeicons.css";
```

Las utilidades de Tailwind se colocan después de la capa de PrimeNG para que puedan prevalecer cuando corresponda. Los estilos globales no deben sobreescribir selectores internos `.p-*` ni usar `::ng-deep`.

## 1.4 · PrimeNG 22 con Aura

```bash
npm install primeng@^22 @primeuix/themes primeicons @angular/cdk@^22
```

La configuración de `providePrimeNG` debe usar Aura, `ripple: true`, `inputVariant: 'outlined'`, `darkModeSelector: '.app-dark'` y la capa `primeng` en el orden `theme, base, primeng, utilities`. `MessageService` y `ConfirmationService` se registran en `app.config.ts`.

`provideHttpClient()` se agrega en la ISS que establezca el consumo HTTP, no en esta ISS. Si PrimeNG muestra un aviso de licencia, lo registro como aviso del componente y no como fallo de compilación; no agrego claves privadas a archivos, capturas ni repositorio.

## 1.5 · Pantalla inicial y demostración local

`App` presenta el componente de demostración local. No se integra `HttpClient`, no se consulta la base de datos y no se presenta la demostración como una bicicleta disponible real.

La demostración permite observar un estado local, un valor derivado con `computed` y un `effect`. Los datos de muestra se etiquetan como demostrativos. No se reutiliza el nombre de producto `Café molido 500 g`, los textos de venta ni los endpoints de StoreLab.

La aplicación inicia con esta composición:

```text
index.html → <app-root> → App → componente de demostración local
```

El router queda disponible, pero `routes` permanece vacío en esta ISS. El Shell de navegación corresponde a ISS-01A.

## 1.6 · `index.html`

Configuro `lang="es"`, una descripción del frontend de PedalLibre y un título identificable, por ejemplo:

```html
<title>PedalLibre · Angular 22</title>
```

Las clases del `body` pueden usar utilidades Tailwind para márgenes, fondo y tipografía. No se utiliza el título StoreLab en la versión PedalLibre.

## 1.7 · Presupuesto de compilación

En `angular.json`, el presupuesto `initial` se configura con `maximumWarning: "750kB"` y `maximumError: "1MB"`. Registraré el tamaño que produzca el build, sin asumir el resultado del proyecto de referencia.

## 1.8 · Primera ejecución

```bash
ng serve
```

Abro `http://127.0.0.1:4200/` y verifico la pantalla inicial. Después ejecuto:

```bash
ng build
npm test -- --watch=false
```

Registro en la bitácora la salida real del servidor, build y pruebas. Si los comandos o el runner de pruebas difieren por la versión de Angular generada, documento y uso los scripts que existan en `package.json`; no anoto una prueba como aprobada sin ejecutarla.

## 1.9 · `signal`, `computed` y `effect`

- `signal` guarda el estado local de la demostración.
- `computed` deriva un valor a partir del estado.
- `effect` observa cambios para mostrar el mecanismo; no se usa para llamar a la API.
- Las actualizaciones reemplazan o actualizan el valor del signal de forma que Angular pueda detectar el cambio.
- El componente de demostración no es una ruta de negocio ni se incluye en el menú.

## Verificación y cierre de PedalLibre

Esta ISS se cierra cuando los criterios aplicables anteriores se hayan ejecutado y sus resultados reales estén documentados. No se presupone que los checks ya pasaron: el estado permanece **Pendiente de ejecutar** hasta que se cree el proyecto.

La ISS-01A podrá comenzar después de verificar la estructura base y la primera ejecución. La integración con Django, el login y los permisos RBAC se realizan en sus ISS correspondientes.

---

# ISS-01 original · Bootstrap Angular 22 con CLI

> **Referencia:** texto original compartido para ISS-01. Se conserva debajo de la adaptación PedalLibre.
> Los títulos marcados **(EXENTO EN PEDALIBRE)** identifican instrucciones que no se usan como requisitos del proyecto; su contenido se conserva.

## Contexto mínimo original (PARCIALMENTE EXENTO EN PEDALIBRE)

- **Proyecto:** `front-storelab-django` — Angular 22 (standalone + signals), PrimeNG 22 en modo styled con Aura y Tailwind CSS 4. Sin CSS propio ni PrimeFlex.
- **Backend de referencia:** `pry-django` en `http://localhost:8000/api`. Esta ISS no llama a la API y no registra `HttpClient`.
- **Pantalla de esta ISS:** App compone `<app-ejemplo />`. El componente demo/ejemplo enseña selector, signals, computed y effect con un objeto local. No llama a la API. En ISS-01A deja de mostrarse y entra el Shell.
- **Patrón visual:** `PATRON-VISUAL.md`. **Plantilla:** `README.md`.
- **Depende de:** ISS-00 — Requisitos previos, GATE de entorno en PASS.

El uso de StoreLab, sus productos, textos y datos demo es exento en PedalLibre. La base técnica Angular, Tailwind y PrimeNG se mantiene según la sección PedalLibre al inicio del documento.

## Ficha original

| Campo | Descripción |
|---|---|
| **ISS** | Bootstrap Angular 22 con CLI |
| **Feature / tabla** | Estructura `src/` + configuración global |
| **API** | Ninguna |
| **Depende de** | ISS-00 |
| **Habilita** | ISS-01A — Esqueleto Header/Aside/Footer |

## Contenido de la ISS original

- 1.1 Crear el proyecto en la carpeta actual
- 1.2 Tailwind 4 con PostCSS
- 1.3 Estilos globales
- 1.4 PrimeNG 22 con Aura
- 1.5 Pantalla de arranque: App compone demo/ejemplo
- 1.6 `index.html`
- 1.7 Presupuesto de build
- 1.8 Primera ejecución
- 1.9 Anatomía del componente demo/ejemplo y signals
- Verificación del ISS
- Cierre del ISS
- Correspondencia con el código
- GATE

## Objetivo original (EXENTO EN PEDALIBRE)

Crear el proyecto Angular 22 para StoreLab, integrar Tailwind 4 y PrimeNG 22 con Aura y dejar una pantalla mínima en `http://localhost:4200`. El orden original es CLI, Tailwind y después PrimeNG. En PedalLibre se aplica el objetivo adaptado que aparece al inicio.

**Bloqueado por:** ISS-00.

**Evidencia de aprendizaje original:** explicar el arranque `index.html → main.ts → app.config.ts → App → <app-ejemplo />` y distinguir `signal`, `computed` y `effect` sobre demo/ejemplo.

> **Encaje original en las dos fases (EXENTO EN PEDALIBRE):** no hay login, guards ni permisos; `app.routes.ts` queda vacío. La sesión es Fase II. `provideHttpClient()` se agrega en ISS-02.

## Criterios de aceptación originales (PARCIALMENTE EXENTOS EN PEDALIBRE)

- [ ] **1.1** `angular.json`, `package.json` y `src/main.ts` están en la raíz, sin subcarpeta.
- [ ] **1.1** `src/app/app.routes.ts` exporta `routes` y `provideRouter` está en `app.config.ts`.
- [ ] **1.2** `.postcssrc.json` declara `@tailwindcss/postcss` y Tailwind está instalado.
- [ ] **1.3** `src/styles.css` declara las capas e importa Tailwind y `primeicons/primeicons.css`.
- [ ] **1.4** `providePrimeNG` usa Aura, `darkModeSelector: '.app-dark'` y `cssLayer` con el orden de capas.
- [ ] **1.4** `app.config.ts` registra `MessageService` y `ConfirmationService`.
- [ ] **1.5** `app.ts` importa Ejemplo y `app.html` contiene `<app-ejemplo />`; `app.css` queda vacío; `app.routes.ts` sigue vacío.
- [ ] **1.5** Existe `src/app/demo/ejemplo/` (`.ts`, `.html`, `.css`, `.spec.ts`) con un objeto en un signal. **(EXENTO EN PEDALIBRE: demo StoreLab; se reemplaza por una demo local neutral.)**
- [ ] **1.6** `index.html` tiene `lang="es"`, título `StoreLab · Angular 22` y el `<body>` con utilidades Tailwind. **(EXENTO EN PEDALIBRE: título StoreLab.)**
- [ ] **1.7** El presupuesto `initial` es 750 kB / 1 MB.
- [ ] **1.8** `ng serve` responde 200; `+1000` cambia precio e IVA sin recargar. **(EXENTO EN PEDALIBRE: acción y valores de producto StoreLab.)**
- [ ] **1.8** `ng build` termina con código 0 y `npm test -- --watch=false` queda en verde.
- [ ] **1.9** Se distingue `signal`, `computed` y `effect`, y el selector `app-ejemplo`. **(EXENTO EN PEDALIBRE: nombre del selector original; se explica con el componente demo local elegido.)**
- [ ] La banda `Invalid PrimeUI License` se identifica como aviso de licencia.

## 1.1 Crear el proyecto en la carpeta actual

**Criterios del subítem**

- [ ] `angular.json`, `package.json`, `src/main.ts` y `src/app/app.config.ts` están en la raíz.
- [ ] `src/app/app.routes.ts` fue generado por `--routing`.
- [ ] `docs/construir/` sigue presente. **(EXENTO EN PEDALIBRE: ruta de documentación StoreLab; aquí se conservan `iss/` y `trazabilidad/`.)**

En la carpeta que dejó ISS-00, sin `src/` ni `package.json`:

```bash
cd ~/ia-lab/projects/dw/front-storelab-django
ng new front-storelab-django \
  --directory . \
  --style=css \
  --routing \
  --ssr=false \
  --skip-git \
  --package-manager=npm \
  --defaults
```

`--directory .` escribe en la carpeta actual. `ng new .` no es válido: el CLI exige un nombre de paquete npm. `--style=css` deja el CSS plano; Tailwind se activa en 1.2. `--routing` genera `app.routes.ts`. `--ssr=false` deja solo SPA. `--skip-git` no crea otro repositorio. `ng new` no borra `docs/`.

El README de la raíz que deja el CLI se reemplaza por la presentación breve del proyecto. El del curso vive en `docs/construir/` y no se toca.

## 1.2 Tailwind 4 con PostCSS

**Criterios del subítem**

- [ ] `tailwindcss`, `@tailwindcss/postcss` y `postcss` están instalados.
- [ ] `.postcssrc.json` declara el plugin.

```bash
npm install tailwindcss @tailwindcss/postcss postcss
```

```json
{
  "plugins": {
    "@tailwindcss/postcss": {}
  }
}
```

Angular detecta `.postcssrc.json` por convención. Tailwind 4 no usa `tailwind.config.js` en esta configuración.

## 1.3 Estilos globales

**Criterios del subítem**

- [ ] `@layer theme, base, primeng, utilities;`
- [ ] `@import 'tailwindcss';`
- [ ] `@import 'primeicons/primeicons.css';`
- [ ] Sin selectores `.p-*`, `::ng-deep` ni clases de aplicación.

`src/styles.css` es la única hoja global. `utilities` queda al final y gana sobre `primeng`.

## 1.4 PrimeNG 22 con Aura

**Criterios del subítem**

- [ ] `primeng`, `@primeuix/themes`, `primeicons` y `@angular/cdk` están instalados.
- [ ] Preset Aura, `ripple: true`, `inputVariant: 'outlined'`.
- [ ] `darkModeSelector: '.app-dark'`.
- [ ] `cssLayer` con `name: 'primeng'` y `order: 'theme, base, primeng, utilities'`.
- [ ] `MessageService` y `ConfirmationService` registrados.
- [ ] `provideRouter` incluye `withComponentInputBinding()` y `withInMemoryScrolling()`.

```bash
npm install primeng @primeuix/themes primeicons @angular/cdk
```

`@angular/cdk` es peer de PrimeNG 22. `provideHttpClient()` no se agrega aquí. La clave de licencia se enlaza en ISS-02, cuando exista `environment`. Sin clave, la consola y la esquina inferior derecha avisan `Invalid PrimeUI License`; los componentes se dibujan igual. PrimeNG 21 no sustituye a la 22: sus peers son de Angular 21.

`providePrimeNG` no escribe el tema en el CSS compilado. Serializa Aura a variables en runtime (`--p-primary-color`). La comprobación es esa variable en el documento, no una regla dentro de `dist/*.css`.

## 1.5 Pantalla de arranque original (PARCIALMENTE EXENTA EN PEDALIBRE)

**Criterios originales**

- [ ] `src/app/app.ts` importa Ejemplo y lo declara en `imports`.
- [ ] `src/app/app.html` contiene `<app-ejemplo />` dentro de un `<main>` con utilidades Tailwind.
- [ ] `src/app/app.css` queda vacío.
- [ ] `src/app/app.spec.ts` comprueba que se pinta `app-ejemplo` y el nombre del producto. **(EXENTO EN PEDALIBRE: nombre y producto StoreLab.)**
- [ ] `src/app/app.routes.ts` sigue vacío.
- [ ] Existe `src/app/demo/ejemplo/` con `ejemplo.ts`, `ejemplo.html`, `ejemplo.css` y `ejemplo.spec.ts`.
- [ ] En `http://127.0.0.1:4200` se ve la tarjeta del producto, el precio y los botones. **(EXENTO EN PEDALIBRE: producto y contenido StoreLab.)**

App solo pone la etiqueta. El router no elige la pantalla: en ISS-01 se aprende que un componente es una etiqueta HTML escrita en la plantilla de otro.

```text
index.html → <app-root> → App → <app-ejemplo /> → demo/ejemplo
```

La etiqueta funciona si coinciden `selector: 'app-ejemplo'` de Ejemplo e `imports: [Ejemplo]` en App. `host: { class: 'block' }` pone `class="block"` en `<app-ejemplo>`, sin envolverlo en otro `div`.

La prueba del CLI busca el `<h1>` de bienvenida y falla al reemplazar `app.html`. Se sustituye por casos que comprueban que App se crea, que existe el componente de demostración y que el texto esperado está presente. Las pruebas del ejemplo cubren el estado y sus cambios locales.

El aviso `Invalid PrimeUI License` puede aparecer al usar `p-card`, `p-button` y `p-tag`. La pantalla puede funcionar; el registro de la licencia se trata según las instrucciones aplicables y nunca se publica una clave.

## 1.6 `index.html` original (PARCIALMENTE EXENTO EN PEDALIBRE)

**Criterios originales**

- [ ] `lang="es"`.
- [ ] `<title>StoreLab · Angular 22</title>`. **(EXENTO EN PEDALIBRE: marca StoreLab; se usa el título PedalLibre.)**
- [ ] `<body class="m-0 bg-slate-100 font-sans text-slate-900">`.
- [ ] Meta description presente.

El título nombra el frontend. El `<body>` y el resto del documento siguen el patrón de estilo elegido.

## 1.7 Presupuesto de build

**Criterios del subítem**

- [ ] `initial: maximumWarning 750kB, maximumError 1MB`.

El CLI deja el aviso en 500 kB. Se sube a 750 kB, el mismo tope del frontend Express original, para que PrimeNG no convierta el build en warning. El error sigue en 1 MB.

## 1.8 Primera ejecución original (PARCIALMENTE EXENTA EN PEDALIBRE)

**Criterios originales**

- [ ] `ng serve` compila y `http://127.0.0.1:4200` responde 200.
- [ ] Se ve la tarjeta Objeto producto con nombre, precio, estado y botones. **(EXENTO EN PEDALIBRE: contenido de producto StoreLab.)**
- [ ] `+1000` cambia el precio y el IVA sin recargar. **(EXENTO EN PEDALIBRE: importe del producto de muestra.)**
- [ ] Cambiar estado pasa la etiqueta a Inactivo y cambia el aviso.
- [ ] Escribir en Nombre actualiza Vista previa.
- [ ] Reiniciar vuelve a «Café molido 500 g», 18000 y Activo. **(EXENTO EN PEDALIBRE: nombre y datos de producto StoreLab.)**
- [ ] `ng build` termina con código 0 y las pruebas quedan en verde.

| Comprobación visual original | Resultado esperado original |
|---|---|
| Estado inicial | Nombre «Café molido 500 g», precio 18000, IVA 21420, etiqueta Activo |
| `+1000` | Precio 19000, IVA 22610 |
| Cambiar estado | Etiqueta Inactivo y aviso de borrado lógico |
| Campo Nombre | «Vista previa: Té verde» al escribir |
| Reiniciar | Vuelve a «Café molido 500 g», 18000 y Activo |
| Caja de estilos | `.ejemplo-alcance` lleva el atributo `_ngcontent-…` |

Cualquier URL muestra la misma composición: el router está configurado y `routes` está vacío. `[PrimeUI] No license key configured` y la banda `Invalid PrimeUI License` son avisos de licencia, no un fallo de Angular.

## 1.9 Anatomía original de `demo/ejemplo` y signals (PARCIALMENTE EXENTA EN PEDALIBRE)

**Criterios originales**

- [ ] El arranque es `index.html → main.ts → app.config.ts → App → <app-ejemplo />`.
- [ ] Los cuatro archivos son `ejemplo.ts`, `ejemplo.html`, `ejemplo.css` y `ejemplo.spec.ts`.
- [ ] `signal` guarda el objeto, `computed` deriva IVA y estado, `effect` escribe en consola.
- [ ] El objeto se reemplaza con `.update()` / `.set()`, sin mutar la misma referencia.
- [ ] `selector: 'app-ejemplo'` es la etiqueta `<app-ejemplo />` de `app.html`. **(EXENTO EN PEDALIBRE: selector/nombre específico del ejemplo StoreLab.)**

```text
src/app/demo/ejemplo/
├── ejemplo.ts       estado, derivados, efecto y métodos
├── ejemplo.html     tarjetas, campo y botones
├── ejemplo.css      una clase para explicar el aislamiento
└── ejemplo.spec.ts  estado, derivados y cambios
```

`producto` es un `signal<Producto>`. `precioFinal` y `estadoTexto` son `computed`: se recalculan al leerlos. `effect` registra `[ejemplo] nombre · precio · activo|inactivo` cada vez que cambia el objeto. `variarPrecio` hace `update` con un objeto nuevo (`{ ...actual, precio }`). Mutar `actual.precio` no avisa a la vista, porque el signal compara referencias.

La plantilla conecta la clase de cuatro formas: `{{ producto().precio }}`, `[value]`, `(input)` / `(click)` y `@if`. El campo no usa `[(ngModel)]`; los formularios de negocio usan Reactive Forms desde ISS-03.

Angular 22 arranca sin Zone.js. La vista se actualiza porque el signal notifica y porque Angular escucha el clic. Una propiedad normal cambiada dentro de una promesa puede quedarse vieja.

`ejemplo.css` es la única excepción de CSS propio: `.ejemplo-alcance` demuestra el encapsulamiento. Angular le añade `_ngcontent-…`, así que esa clase no pinta otros componentes. El resto del aspecto sigue en Tailwind y Aura.

La diferencia original con Express es el texto del aviso activo: aquí dice `GET /api/products/`; allí dice `GET /api/productos`. **(EXENTO EN PEDALIBRE: ambos textos y las rutas de ejemplo no son endpoints del backend PedalLibre.)**

## Verificación original del ISS

```bash
ng build
npm test -- --watch=false
npm ls primeng @primeuix/themes primeicons @angular/cdk tailwindcss --depth=0
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:4200/
```

## Resultado original en este workspace (24-oct-2026) (EXENTO EN PEDALIBRE)

Estos son resultados reportados para el workspace de referencia StoreLab; no son resultados de esta ejecución ni de PedalLibre.

| Comprobación | Resultado original |
|---|---|
| `ng version` | Angular CLI 22.2.4, Angular 22.2.3, Node 24.20.0 |
| Paquetes PrimeNG | `primeng` 22.1.4 / `@primeuix/themes` 3.1.0 / `primeicons` 8.0.2 / `@angular/cdk` 22.2.4 |
| Tailwind | `tailwindcss` 4.3.3 / `@tailwindcss/postcss` 4.3.3 |
| `ng build` | Código 0, Initial total 614.28 kB (bajo el tope de 750 kB) |
| `npm test -- --watch=false` | 7 pruebas: 3 de App y 4 de Ejemplo |
| `GET http://127.0.0.1:4200/` | 200, título StoreLab · Angular 22 |
| Estado inicial | «Café molido 500 g», 18000, IVA 21420 |
| `+1000` | 19000 e IVA 22610, sin recargar |
| Cambiar estado | Etiqueta Inactivo y aviso de borrado lógico |
| Nombre | «Vista previa: Té verde» |
| Reiniciar | «Café molido 500 g», 18000, IVA 21420 |
| Encapsulamiento | `.ejemplo-alcance` con `_ngcontent-ng-c…`; `app-ejemplo` con `class="block"` |
| Licencia | Banda `Invalid PrimeUI License`; no es un error de compilación |
| HTTP a la API | No hay `HttpClient`; el aviso solo nombra `GET /api/products/` |

## Cierre original del ISS (EXENTO EN PEDALIBRE)

En StoreLab, `ng serve` muestra `demo/ejemplo`: `+1000` cambia precio e IVA, el estado alterna el aviso y Reiniciar restaura el objeto. El servidor queda en `http://127.0.0.1:4200/`.

La siguiente ISS-01A deja de componer `<app-ejemplo />` y arma Header, Aside, contenido y Footer. El componente de ejemplo permanece en `src/app/demo/ejemplo/` como material de la lección. En PedalLibre se usa el criterio de cierre inicial de este documento.

## Correspondencia original con el código

Los comandos de la guía original crearon los archivos siguientes:

```text
.postcssrc.json
angular.json
package.json
src/index.html
src/main.ts
src/styles.css
src/app/app.config.ts
src/app/app.ts
src/app/app.html
src/app/app.css
src/app/app.routes.ts
src/app/app.spec.ts
src/app/demo/ejemplo/ejemplo.ts
src/app/demo/ejemplo/ejemplo.html
src/app/demo/ejemplo/ejemplo.css
src/app/demo/ejemplo/ejemplo.spec.ts
```

`src/environments/` todavía no existe; se crea en ISS-02. `demo/ejemplo` no es una pantalla de negocio ni entra al menú. La correspondencia de archivos se conserva como referencia; los nombres de producto y textos de StoreLab marcados exentos no se presentan como contenido PedalLibre.

## GATE original

```text
TODOS los AC = PASS → se puede avanzar a ISS-01A
ALGÚN AC = FAIL    → se corrige y se repite
```

| AC | Comprobación original | Resultado de referencia |
|---|---|---|
| 1.1 | Raíz con `angular.json`, `package.json`, `src/main.ts` y rutas vacías | PASS |
| 1.2 | `.postcssrc.json` y Tailwind 4.3.3 | PASS |
| 1.3 | `src/styles.css` con capas y dos imports | PASS |
| 1.4 | Aura, capas, `MessageService` y `ConfirmationService` | PASS |
| 1.5 | App compone `<app-ejemplo />` y existen los cuatro archivos de demo/ejemplo | PASS |
| 1.6 | `lang="es"`, título StoreLab · Angular 22 y clases del body | PASS |
| 1.7 | Presupuesto 750 kB / 1 MB; bundle 614.28 kB | PASS |
| 1.8 | Interacciones del navegador, build 0 y 7 pruebas | PASS |
| 1.9 | `signal`, `computed`, `effect` y selector sobre el código real | PASS |

Los resultados de esta tabla son los originales de StoreLab, no se marcan como completados para PedalLibre. El GATE que habilita ISS-01A es el de la sección PedalLibre al inicio, después de ejecutar esta ISS.
