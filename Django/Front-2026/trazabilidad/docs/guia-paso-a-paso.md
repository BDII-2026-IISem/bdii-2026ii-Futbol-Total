# Guía paso a paso del frontend

> **Proyecto:** Frontend Django
> **Formato:** bitácora personal, escrita en primera persona
> **Recorrido:** ISS-00 a ISS-11
> **Estado:** en desarrollo

## Propósito

En esta guía registro, con mis propias palabras, cómo voy desarrollando el frontend del proyecto. Sigo las ISS de la [guía del docente](https://tecnogua.com/academic/site/frontend2026/django/construir/ISS-00-requisitos-previos/), desde ISS-00 hasta ISS-11.

Por cada ISS documento lo que hice realmente, cómo comprobé que funciona, las evidencias visuales, la retroalimentación recibida y lo que aprendí. No marco un paso como realizado ni agrego capturas hasta contar con la información o evidencia correspondiente.

## Cómo llevaré la bitácora

1. Consulto la ISS correspondiente en la guía del docente.
2. Desarrollo el paso y describo en primera persona las acciones que realicé.
3. Anoto los comandos o decisiones relevantes y el resultado que observé.
4. Guardo las capturas compartidas en `../evidencias/`, las inserto en la sección de la ISS y explico debajo de cada una qué muestra.
5. Registro la retroalimentación: qué está bien, qué debo corregir y por qué.
6. Cierro con una reflexión breve sobre lo que aprendí y marco el estado según la evidencia disponible.

Las capturas deben mostrar lo necesario para verificar el trabajo. Antes de guardarlas, oculto contraseñas, tokens, claves y otros datos sensibles.

## Ubicación de las evidencias

Las imágenes se guardan en [`../evidencias/`](../evidencias/), con nombres descriptivos y numerados por ISS. En la bitácora inserto cada captura con un enlace relativo y escribo justo debajo una explicación del resultado que muestra.

## Seguimiento

| ISS | Tema | Estado |
|---|---|---|
| ISS-00 | Requisitos previos | Completada; las pruebas de integración quedan para las ISS que consuman la API |
| ISS-01 | Bootstrap Angular 22 con CLI | Completada; demo PedalLibre, build y seis pruebas verificados |
| ISS-01B | Menú PrimeNG y primera interacción | Completada; escritorio, Drawer móvil a 390 px y build con chunk diferido documentados |
| ISS-02 | Núcleo, modelos y layout | Pendiente |
| ISS-03 | Por registrar desde la guía del docente | Pendiente |
| ISS-04 | Por registrar desde la guía del docente | Pendiente |
| ISS-05 | Por registrar desde la guía del docente | Pendiente |
| ISS-06 | Por registrar desde la guía del docente | Pendiente |
| ISS-07 | Por registrar desde la guía del docente | Pendiente |
| ISS-08 | Por registrar desde la guía del docente | Pendiente |
| ISS-09 | Por registrar desde la guía del docente | Pendiente |
| ISS-10 | Por registrar desde la guía del docente | Pendiente |
| ISS-11 | Por registrar desde la guía del docente | Pendiente |

Los títulos y criterios de cada ISS se completarán al consultar su página correspondiente. El estado refleja el trabajo y las evidencias documentadas, no solo la existencia de esta plantilla.

## Registro de desarrollo

### ISS-00 · Requisitos previos

**Referencia:** [ISS-00 — Requisitos previos](https://tecnogua.com/academic/site/frontend2026/django/construir/ISS-00-requisitos-previos/)

**Estado:** En curso; entorno y CLI comprobados con capturas. Adapté la guía para trabajar con PedalLibre.

#### Objetivo

Registrar cómo preparé y comprobé el entorno antes de comenzar a escribir código Angular, contrastando la ISS-00 con el backend PedalLibre del repositorio.

#### Pasos que realicé

1. **0.1 — Node y npm (verificado):**
   - Ejecuté `node --version` y `npm --version`; obtuve Node `v24.21.0` y npm `12.1.0`.
   - Consulté `npm view @angular/cli version engines --json`. La versión publicada era `22.2.5` y el rango de Node incluía `^24.15.0`, por lo que mi versión instalada era compatible.
   - Actualicé npm con `npm install -g npm@12.2.1`.

2. **0.2 — Angular CLI (verificado):**
   - Instalé el CLI con `npm install -g @angular/cli`.
   - Ejecuté `ng version` y `command -v ng`; obtuve Angular CLI `22.2.5`, Node `v24.21.0`, npm `12.2.1` y la ruta `/home/oscar_vega/.nvm/versions/node/v24.21.0/bin/ng`.

3. **0.3 — Editor y navegador (parcial):**
   - Abrí el proyecto en VS Code y comprobé que puedo usar su terminal integrada.
   - Abrí la página de inicio de sesión del administrador Django en `http://127.0.0.1:8000/admin/`.
   - Todavía no registré una comprobación de DevTools.

4. **0.4 — Backend Django (parcial):**
   - Ejecuté `python manage.py check` y `python manage.py runserver`.
   - En la terminal vi que el servidor de desarrollo inició en `http://127.0.0.1:8000/`.
   - Abrí `/admin/` y vi el formulario de inicio de sesión.

5. **Consulta de clientes (resultado observado; evidencia no adjunta):**
   - Ejecuté `curl -i http://127.0.0.1:8000/api/clients/`. La respuesta mostró `HTTP/1.1 200 OK` y un arreglo JSON.
   - La captura de esa respuesta contiene datos personales visibles de clientes. No la copié a las evidencias del proyecto; repetiré la comprobación guardando solo el estado HTTP y la forma de la respuesta, sin mostrar registros.

6. **Prueba de login desde terminal (no completada):**
   - Intenté ejecutar un bloque Python para probar el login y consultar endpoints.
   - La terminal devolvió `EOF when reading a line`; no completé el ingreso del usuario y la contraseña ni validé las consultas con token.
   - No registré credenciales ni tokens.

7. **Adaptación de la ISS:**
   - Identifiqué que las instrucciones originales describen StoreLab y no coinciden con PedalLibre.
   - Acordé trabajar con PedalLibre y documenté las equivalencias de rutas y autenticación en `../iss/ISS-00-requisitos-previos.md`.

#### Evidencias

![Terminal con las versiones de Node y npm y la consulta de compatibilidad de Angular CLI](../evidencias/ISS-00-02-node-npm-y-engines.png)

**Explicación:** En esta captura registro las versiones de Node y npm y la consulta de los requisitos de Node para Angular CLI. La versión de Node que aparece es compatible con el rango mostrado.

![Instalación y versión de Angular CLI 22](../evidencias/ISS-00-03-angular-cli-22.png)

**Explicación:** En esta captura muestro la instalación y la verificación de Angular CLI 22. Se observa la versión 22.2.5 junto con las versiones de Node y npm del entorno.

![Servidor Django iniciado y formulario de acceso al administrador](../evidencias/ISS-00-01-runserver-y-admin.png)

**Explicación:** En esta captura se ve el servidor de desarrollo de Django en ejecución y el formulario de inicio de sesión de `/admin/`. Esto comprueba que la página carga; no significa que haya iniciado sesión en el administrador.

![Intento de prueba del login que terminó con un error de entrada](../evidencias/ISS-00-04-prueba-login-con-error.png)

**Explicación:** En esta captura documento el intento de probar el login desde la terminal. La ejecución terminó con `EOF when reading a line`, por lo que no completé el ingreso de credenciales ni confirmé la autenticación.

La captura de `curl /api/clients/` que compartí muestra datos personales de clientes. No la incorporé al repositorio para evitar publicar esa información; repetiré la comprobación con una salida resumida que no exponga registros.

#### Retroalimentación

Comprobé que Node, npm y Angular CLI son compatibles, que el servidor Django inicia y que `/admin/` carga. La consulta de clientes devolvió 200; no guardaré la captura con datos personales. El intento de probar el login desde la terminal terminó con `EOF when reading a line`, por lo que no confirmé el login ni las rutas protegidas con JWT. Esas comprobaciones se harán cuando una ISS requiera integrar la API y no bloquean el inicio del frontend.

#### Qué aprendí

Aprendí a comprobar la compatibilidad entre Node y Angular CLI antes de crear el proyecto. También confirmé que debo adaptar las rutas de la guía al backend PedalLibre y proteger los datos personales cuando guardo evidencias de consultas.

#### Cierre

- **Criterios verificados:** Node/npm y Angular CLI; `manage.py check` y `runserver` ejecutados; `/admin/` abierto; `/api/clients/` respondió 200 en la captura compartida.
- **Pendientes para las ISS de integración:** validar login y permisos con JWT, comprobar CORS desde el navegador y revisar el contrato de tarifas cuando el frontend consuma esos recursos. No necesito repetir la consulta de clientes para cerrar los requisitos del entorno.
- **Estado final:** Completada; puedo avanzar a ISS-01.

---

### ISS-01 · Bootstrap Angular 22 con CLI

**Referencia:** consultar el enlace a ISS-01 desde la ruta de construcción del docente.

**Estado:** Completada.

#### Pasos que realicé

1. **Creación del proyecto Angular:**
   - Creé el scaffold Angular dentro de `Front-2026/`; ahí están `angular.json`, `package.json` y `src/`.
   - En un primer intento ejecuté también `ng new pedalibre-frontend` desde la carpeta superior. Se creó una carpeta adicional fuera de `Front-2026/`; no es el workspace que uso para esta ISS.

2. **Instalación de dependencias en el frontend:**
   - Ejecuté Tailwind, PostCSS, PrimeNG, Aura, PrimeIcons y Angular CDK desde `Front-2026/`. `package.json` registra las dependencias.
   - npm mostró avisos porque cuatro scripts de instalación no están aprobados por `allowScripts`. No habilité scripts de forma general; el build y las pruebas sí funcionaron.
   - Comprobé las versiones con `npm ls`: Tailwind y `@tailwindcss/postcss` 4.3.3, PrimeNG 22.1.4, Aura 3.1.0, PrimeIcons 8.0.2 y Angular CDK 22.2.5.

3. **Configuración de estilos y PrimeNG:**
   - Creé `.postcssrc.json` con `@tailwindcss/postcss`.
   - En `src/styles.css` declaré las capas de tema, base, PrimeNG y utilidades, e importé Tailwind y PrimeIcons.
   - Configuré Aura, `darkModeSelector: '.app-dark'`, las capas CSS, `MessageService`, `ConfirmationService` y el router.

4. **Demostración local de Angular:**
   - Creé `DemoLocal` y lo compuse desde `App` mediante `<app-demo-local />`.
   - La demostración usa datos identificados como ejemplo y no consulta la API. Implementé `signal`, el impuesto derivado con `computed`, el registro con `effect`, edición del nombre, cambio de precio/estado y reinicio.
   - Ajusté `index.html` a `lang="es"` y al título `PedalLibre · Angular 22`.
   - Configuré el presupuesto inicial del build a 750 kB de advertencia y 1 MB de error.

5. **Ejecución, build y pruebas:**
   - Abrí la demostración en el navegador. Como el puerto 4200 estaba ocupado, Angular inició en `http://127.0.0.1:46529/`.
   - Ejecuté `npm run build`: terminó correctamente con un bundle inicial de `542.51 kB`.
   - La prueba generada originalmente por Angular todavía buscaba el saludo del scaffold. La actualicé para comprobar que se muestra la demo local y añadí cuatro pruebas para los datos iniciales, el cálculo derivado, la edición del nombre, el estado y el reinicio.
   - Volví a ejecutar `npm test -- --watch=false`: pasaron los dos archivos de prueba y las seis pruebas.

#### Evidencias

![Primer intento de ng new que creó una carpeta fuera de Front-2026](../evidencias/ISS-01-01-ng-new-en-ruta-incorrecta.png)

**Explicación:** En este primer intento ejecuté `cd ..` antes de `ng new pedalibre-frontend --directory pedalibre-frontend`. Angular creó la carpeta adicional fuera de `Front-2026/`; conservé la captura como registro del error de ubicación y trabajé en el scaffold que ya está dentro de `Front-2026/`.

![Primer intento de instalación de Tailwind desde la carpeta superior](../evidencias/ISS-01-02-instalacion-tailwind-fuera-del-frontend.png)

**Explicación:** El prompt muestra que este primer `npm install` se ejecutó en `Django/`, no en el workspace. Más adelante repetí la instalación desde `Front-2026/`, como se ve en la evidencia ISS-01-07.

![Imports de Tailwind y PrimeIcons en los estilos globales](../evidencias/ISS-01-03-imports-de-estilos.png)

**Explicación:** En `Front-2026/src/styles.css` escribí el orden de capas y los imports de Tailwind y PrimeIcons. Después instalé las dependencias desde el workspace y la hoja quedó compilada con ellas.

![Primer intento de instalación de PrimeNG desde la carpeta superior](../evidencias/ISS-01-04-instalacion-primeng-fuera-del-frontend.png)

**Explicación:** Este primer intento agregó paquetes desde `Django/`, fuera de `Front-2026/`. Luego instalé las dependencias en el workspace correcto y comprobé que aparecen en el `package.json` del frontend.

![Servidor Angular en 4200 con la pantalla inicial generada por el CLI](../evidencias/ISS-01-05-servidor-angular-pantalla-inicial.png)

**Explicación:** Esta captura registra el primer arranque, cuando todavía se veía la plantilla de bienvenida generada por Angular. La evidencia ISS-01-16 muestra el estado posterior con la demo local.

![Build y pruebas del scaffold Angular](../evidencias/ISS-01-06-build-y-pruebas-iniciales.png)

**Explicación:** Esta captura registra el build inicial y las dos pruebas generadas por el CLI, antes de terminar la demo. Después actualicé las pruebas para la aplicación real y ejecuté de nuevo la suite: seis pruebas aprobaron.

![Instalación de Tailwind, PostCSS y PrimeNG desde Front-2026](../evidencias/ISS-01-07-dependencias-instaladas-en-frontend.png)

**Explicación:** El prompt ahora está en `Django/Front-2026/` y npm instaló las dependencias en este workspace. La salida reporta 87 paquetes agregados y cero vulnerabilidades; también advierte que cuatro scripts de instalación fueron bloqueados por `allowScripts`.

![Configuración de PostCSS para Tailwind 4](../evidencias/ISS-01-08-postcss-configurado.png)

**Explicación:** Creé `.postcssrc.json` en la raíz de `Front-2026/` y declaré el plugin `@tailwindcss/postcss`.

![Capas e imports globales de Tailwind y PrimeIcons](../evidencias/ISS-01-09-estilos-globales-configurados.png)

**Explicación:** En `src/styles.css` quedaron las capas `theme`, `base`, `primeng` y `utilities`, junto con los imports de Tailwind y PrimeIcons.

![Configuración de Aura, capas y servicios de PrimeNG](../evidencias/ISS-01-10-primeng-aura-configurado.png)

**Explicación:** Configuré Aura, el modo oscuro `.app-dark`, las capas CSS y los servicios `MessageService` y `ConfirmationService`. El router conserva sus opciones de binding y restauración del scroll.

![Plantilla de la demostración local](../evidencias/ISS-01-11-plantilla-demo-local.png)

**Explicación:** La plantilla muestra datos explícitamente identificados como ejemplo y controles para editar el nombre, aumentar el precio de muestra, cambiar el estado y reiniciar.

![Lógica de signals y valor derivado de la demostración](../evidencias/ISS-01-12-logica-signals-demo.png)

**Explicación:** `DemoLocal` mantiene un objeto local en `signal`, calcula el impuesto con `computed` y observa cambios con `effect`. No realiza peticiones a la API.

![Componente raíz que importa DemoLocal](../evidencias/ISS-01-13-componente-app-demo.png)

**Explicación:** `App` importa `DemoLocal` como componente standalone y lo usa como contenido inicial.

![Plantilla raíz que presenta la demostración](../evidencias/ISS-01-14-app-compone-demo-local.png)

**Explicación:** `app.html` compone `<app-demo-local />` dentro del contenedor con utilidades de Tailwind.

![Idioma y metadatos de PedalLibre en index.html](../evidencias/ISS-01-15-index-html-pedallibre.png)

**Explicación:** Configuré `lang="es"`, el título `PedalLibre · Angular 22`, la descripción del frontend y las clases del `body`.

![Demostración local de PedalLibre ejecutándose en el navegador](../evidencias/ISS-01-16-demo-en-navegador.png)

**Explicación:** La captura muestra la demo en el puerto alternativo `46529`, porque `4200` estaba ocupado. Se ven los datos de muestra, el impuesto calculado y los botones. El aviso `Invalid PrimeUI License` aparece como aviso visual de licencia; la página se renderizó.

![Build y pruebas de ISS-01 en la terminal](../evidencias/ISS-01-17-build-y-pruebas-en-terminal.png)

**Explicación:** En esta captura se ve que ejecuté `ng build` y `npm test -- --watch=false` desde `Front-2026/`. El build terminó correctamente con un bundle inicial de `542.51 kB`; la salida muestra dos archivos de pruebas y seis pruebas aprobadas.

#### Retroalimentación

Completé la configuración dentro de `Front-2026/`, mostré la demo local y verifiqué build y pruebas. El primer intento dejó una carpeta extra fuera del workspace y las primeras instalaciones se hicieron desde el nivel superior; corregí el procedimiento instalando las dependencias en la carpeta frontend. npm advirtió que algunos scripts estaban bloqueados por `allowScripts`, pero el build terminó correctamente y las seis pruebas pasaron. Angular usó el puerto alternativo `46529` porque `4200` estaba ocupado.

#### Qué aprendí

Aprendí a comprobar la carpeta actual antes de instalar dependencias y a reemplazar las pruebas generadas por Angular cuando cambia la pantalla inicial. También confirmé que el build, las pruebas y la vista del navegador deben corresponder al estado final, no solo al scaffold inicial.

#### Cierre

- **Criterios verificados:** scaffold y rutas Angular; Tailwind/PostCSS; estilos globales; PrimeNG/Aura y servicios; demo local; título/idioma; presupuesto; build exitoso de `542.51 kB`; seis pruebas aprobadas.
- **Pendientes o correcciones:** ninguno para cerrar ISS-01. En otra sesión se puede iniciar ISS-01A según la secuencia del proyecto.
- **Estado final:** Completada.

---

### ISS-01B · Menú PrimeNG y primera interacción

**Estado:** Completada.

#### Pasos que realicé

1. Generé el componente `Construir` desde `Front-2026/`.
2. Configuré `Aside` para recibir el modelo de opciones por `input()` y presentarlo con `p-panelmenu`. El clic emite `navigated`.
3. Configuré `Header` para recibir el nombre de la aplicación y emitir `menuRequested` desde el botón de menú.
4. Implementé `Construir` con signals para el título, el Drawer y el Aside de escritorio. Las opciones locales son Inicio, Clientes, Bicicletas disponibles, Tarifas y Acceso.
5. Convertí `App` en punto de entrada con `router-outlet`; las rutas redirigen a `construir` y cargan el componente de forma diferida.
6. Inicié la aplicación con `npm start`. El puerto 4200 estaba ocupado, así que acepté el puerto alternativo 38663. La captura muestra la página `/construir` en escritorio y el chunk diferido.
7. Revisé la vista responsive a 390 px: el Aside fijo no aparece y el botón abre el Drawer con las cinco opciones locales.

#### Evidencias

![Aside recibe las opciones mediante input y usa PanelMenu](../evidencias/ISS-01B-01-aside-input-panelmenu.png)

**Explicación:** En el editor se ve `Aside` importando `input`, `output`, `MenuItem` y `PanelMenuModule`. El componente declara `items` como entrada y emite `navigated`; no define el modelo de opciones.

![Generación del componente Construir](../evidencias/ISS-01B-02-generar-construir.png)

**Explicación:** La terminal muestra que ejecuté `ng generate component features/construir --skip-tests --defaults` desde `Front-2026/` y que Angular creó los archivos del componente.

![Plantilla del Aside con PanelMenu](../evidencias/ISS-01B-03-plantilla-aside.png)

**Explicación:** La plantilla conserva el nombre accesible de navegación, delega el clic al método del componente y enlaza el modelo con `[model]="items()"`.

![Header declara el aviso de menú](../evidencias/ISS-01B-04-header-output.png)

**Explicación:** `Header` recibe el nombre PedalLibre con `input()` y declara `menuRequested` como aviso que el padre atenderá.

![Botón de menú siempre visible en la plantilla del Header](../evidencias/ISS-01B-05-boton-header.png)

**Explicación:** La plantilla emite `menuRequested` al pulsar el botón con etiqueta accesible; no condiciona su visibilidad con `lg:hidden`.

![Rutas con carga diferida y redirecciones](../evidencias/ISS-01B-06-rutas-loadcomponent.png)

**Explicación:** `app.routes.ts` carga `Construir` mediante `loadComponent` y redirige la ruta vacía y las desconocidas a `construir`.

![App contiene el ancla router-outlet](../evidencias/ISS-01B-07-router-outlet.png)

**Explicación:** La captura muestra `<router-outlet />` como contenido de `app.html`.

![Archivo de especificaciones abierto en el editor](../evidencias/ISS-01B-08-app-spec.png)

**Explicación:** La captura muestra código en `app.spec.ts`; no muestra la ejecución de pruebas. No la considero evidencia de pruebas ejecutadas y no ejecuté pruebas para esta ISS.

![App importa RouterOutlet como punto de entrada](../evidencias/ISS-01B-09-app-routeroutlet.png)

**Explicación:** `app.ts` importa `RouterOutlet` y configura el componente raíz para que el router presente la pantalla seleccionada.

![Pantalla PedalLibre y build con chunk diferido](../evidencias/ISS-01B-10-build-y-escritorio.png)

**Explicación:** La captura muestra la aplicación en `/construir` a escritorio con las cinco opciones locales. Angular informa un bundle inicial de `31.79 kB` y un chunk diferido `construir` de `17.55 kB`; el servidor usó el puerto `38663` porque `4200` estaba ocupado.

![Vista móvil de PedalLibre a 390 px sin el Aside fijo](../evidencias/ISS-01B-11-movil-390-sin-aside.png)

**Explicación:** La captura muestra la aplicación en viewport responsive de 390 px. El Header, el contenido y el Footer se ven sin el Aside fijo; el botón de menú permanece visible.

![Drawer móvil abierto con las cinco opciones](../evidencias/ISS-01B-12-drawer-abierto-movil.png)

**Explicación:** Abrí el botón de menú en la vista móvil. El Drawer aparece desde la izquierda y presenta Inicio, Clientes, Bicicletas disponibles, Tarifas y Acceso. Esta captura no muestra todavía la selección de una opción.

La selección del menú está conectada a `seleccionar()`, que cambia el título local y cierra el estado del Drawer. Las opciones no tienen enlaces ni llamadas HTTP; son ejemplos de navegación para esta ISS.

#### Retroalimentación

Implementé el menú local, las entradas y salidas de los componentes, el Drawer y el punto de entrada con rutas. Las capturas muestran la vista de escritorio, el build con chunk diferido y el Drawer abierto a 390 px. Las opciones son locales y no están conectadas a servicios de API.

#### Qué aprendí

`input()` permite que el padre entregue datos al componente visual y `output()` permite que el hijo avise sin decidir qué acción debe realizar el padre. El estado del título, el Aside y el Drawer queda en `Construir`.

#### Cierre

- **Criterios verificados:** implementación del menú y del router; vista de escritorio; build con chunk diferido; Aside oculto y Drawer abierto a 390 px; opciones locales sin rutas de negocio ni consumo de API.
- **Pendientes o correcciones:** ninguno para cerrar ISS-01B.
- **Estado final:** Completada. No ejecuté pruebas automatizadas.

---

### ISS-02 · Núcleo, modelos y layout

**Estado:** Pendiente.

La adaptación para PedalLibre y el contenido original de referencia están en [ISS-02 · Núcleo, modelos y layout](../../iss/ISS-02-nucleo-modelos-layout.md).

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-03 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-04 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-05 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-06 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-07 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-08 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-09 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-10 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.

---

### ISS-11 · Por registrar desde la guía del docente

**Estado:** Pendiente.

#### Pasos que realicé

#### Evidencias

#### Retroalimentación

#### Qué aprendí

#### Cierre

- **Criterios verificados:** pendiente.
- **Pendientes o correcciones:** pendiente.
- **Estado final:** Pendiente.
