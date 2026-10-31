---
title: "ISS-04 · CRUD de tarifas PedalLibre"
project: "Frontend de PedalLibre"
layer: "Construir"
depends_on: "ISS-03 · Clientes"
status: "Completada con evidencias de implementación; CRUD autenticado pendiente por respuesta 401"
---

# ISS-04 · CRUD de tarifas PedalLibre

## Objetivo para PedalLibre

Adaptar el siguiente incremento de CRUD al recurso real disponible en PedalLibre: **Tarifas**. El original de StoreLab construye tipos de producto, pero ese recurso no existe en el backend de este proyecto. La pantalla de tarifas se integra en la opción **Tarifas** del menú de `Construir`, conserva `/construir` y usa el endpoint real `/api/rates/`.

La guía describe listado, búsqueda local, alta, edición y activación/desactivación. No se presupone autenticación disponible: el backend aplica RBAC y puede responder 401/403. No se cambian permisos ni se simula una sesión.

## Contrato real de tarifas

`RateSerializer` expone `id`, `name`, `price`, `billing_unit`, `valid_from`, `valid_until`, `is_active`, `created_at` y `updated_at`. `id` y las fechas de creación/actualización son de solo lectura.

`RateViewSet` ofrece GET, POST, PUT y PATCH; DELETE está deshabilitado. La ruta de colección es `/api/rates/` y la de detalle `/api/rates/{id}/`.

- `price` se transporta como decimal en JSON y el modelo TypeScript lo representa como `string`.
- `valid_from` y `valid_until` aceptan fecha o `null`.
- La interfaz envía `snake_case`, igual que el serializer.
- El modelo no declara unicidad para `name`; no se agrega una validación de unicidad que el backend no tenga.
- Para retirar una tarifa del uso se actualiza `is_active` mediante PATCH. No se llama DELETE ni se envía el estado StoreLab `status`.
- El recurso requiere los permisos RBAC del backend. La respuesta 401 observada durante ISS-03 se conserva como evidencia y no se elude.

## Criterios de aceptación para PedalLibre

- [x] **04.1** La opción **Tarifas** muestra `RateList` dentro de la composición actual y mantiene la URL `/construir`.
- [x] **04.2** El listado consulta `RateApi.list()` y representa los campos reales del serializer.
- [x] **04.3** Carga, error, lista vacía y filtro sin coincidencias tienen estados visibles.
- [x] **04.4** El filtro local busca nombre y unidad de cobro sin una petición adicional.
- [x] **04.5** El formulario valida nombre, precio y unidad; fechas vacías se envían como `null`.
- [x] **04.6** El alta usa POST y crea activa; la edición usa PATCH sin cambiar `is_active`.
- [x] **04.7** Activar/desactivar usa PATCH sobre `is_active`; la interfaz no invoca DELETE.
- [x] **04.8** Los errores 401/403 se muestran sin cambiar RBAC ni presentar falsos éxitos.
- [x] **04.9** No se registran secretos ni información personal en consola o capturas.

Los criterios están respaldados por la implementación y las capturas revisadas. La operación CRUD con una sesión autorizada sigue pendiente: la evidencia de navegador muestra un 401 real de la API.

## 04.1 · Environment, modelo y servicio existentes

ISS-02 ya documenta el modelo `Rate`, `RatePayload` y `RateApi`. No volver a generarlos ni reemplazarlos: confirmar que sus definiciones coincidan con el contrato anterior.

El servicio existente ofrece `list`, `get`, `create`, `replace` y `update`. Para este CRUD se usa `list()`, `create()` y `update()`; no se usa `replace()` para no enviar campos que no hayan cambiado.

## 04.2 · Generar los componentes

Desde `Front-2026/`, generar la lista y el formulario:

```bash
npx ng generate component features/rates/rate-list --skip-tests --defaults
npx ng generate component features/rates/rate-form --skip-tests --defaults
```

Los componentes serán standalone. Mantener sus CSS sin reglas de negocio; la presentación usa Tailwind y PrimeNG según los componentes importados.

## 04.3 · Formulario de tarifa

El formulario solo valida y emite datos; no conoce `HttpClient`. La edición recibe la tarifa y `resetKey` para reiniciar los controles al abrir el diálogo. No permite cambiar `is_active` desde el formulario; ese estado se opera por separado.

Crear `src/app/features/rates/rate-form/rate-form.ts`:

```bash
cat > src/app/features/rates/rate-form/rate-form.ts <<'EOF'
import { Component, effect, inject, input, output } from '@angular/core';
import { NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Rate, RatePayload } from '../../../core/models/rate.model';

type RateFormPayload = Omit<RatePayload, 'is_active'>;

@Component({
  selector: 'app-rate-form',
  imports: [ReactiveFormsModule],
  templateUrl: './rate-form.html',
  styleUrl: './rate-form.css',
})
export class RateForm {
  readonly rate = input<Rate | null>(null);
  readonly saving = input(false);
  readonly resetKey = input(0);
  readonly saved = output<RateFormPayload>();
  readonly cancelled = output<void>();

  private readonly fb = inject(NonNullableFormBuilder);
  readonly form = this.fb.group({
    name: ['', [Validators.required, Validators.maxLength(100)]],
    price: ['', [Validators.required]],
    billing_unit: ['', [Validators.required, Validators.maxLength(80)]],
    valid_from: [''],
    valid_until: [''],
  });

  constructor() {
    effect(() => {
      const current = this.rate();
      this.resetKey();
      this.form.reset({
        name: current?.name ?? '',
        price: current?.price ?? '',
        billing_unit: current?.billing_unit ?? '',
        valid_from: current?.valid_from ?? '',
        valid_until: current?.valid_until ?? '',
      });
    });
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const value = this.form.getRawValue();
    this.saved.emit({
      name: value.name.trim(),
      price: value.price.trim(),
      billing_unit: value.billing_unit.trim(),
      valid_from: value.valid_from || null,
      valid_until: value.valid_until || null,
    });
  }
}
EOF
```

Crear `src/app/features/rates/rate-form/rate-form.html`:

```bash
cat > src/app/features/rates/rate-form/rate-form.html <<'EOF'
<form [formGroup]="form" (ngSubmit)="submit()" class="grid gap-4">
  <label class="grid gap-1">
    Nombre *
    <input formControlName="name" maxlength="100" required />
    @if (form.controls.name.touched && form.controls.name.invalid) {
      <span class="text-sm text-red-700">El nombre es obligatorio (máximo 100 caracteres).</span>
    }
  </label>

  <label class="grid gap-1">
    Precio *
    <input type="number" step="0.01" formControlName="price" required />
    @if (form.controls.price.touched && form.controls.price.invalid) {
      <span class="text-sm text-red-700">Ingresa un precio.</span>
    }
  </label>

  <label class="grid gap-1">
    Unidad de cobro *
    <input formControlName="billing_unit" maxlength="80" required />
    @if (form.controls.billing_unit.touched && form.controls.billing_unit.invalid) {
      <span class="text-sm text-red-700">La unidad es obligatoria (máximo 80 caracteres).</span>
    }
  </label>

  <div class="grid gap-4 sm:grid-cols-2">
    <label class="grid gap-1">
      Vigente desde
      <input type="date" formControlName="valid_from" />
    </label>
    <label class="grid gap-1">
      Vigente hasta
      <input type="date" formControlName="valid_until" />
    </label>
  </div>

  <div class="flex justify-end gap-2 border-t border-slate-200 pt-4">
    <button type="button" (click)="cancelled.emit()">Cancelar</button>
    <button type="submit" [disabled]="saving()">
      {{ saving() ? 'Guardando…' : 'Guardar' }}
    </button>
  </div>
</form>
EOF
```

El precio se conserva como texto para evitar operaciones de punto flotante en el cliente. No se fija una regla de unicidad ni un valor de estado en el formulario. Los campos de fecha vacíos se convierten en `null`.

## 04.4 · Lista y escrituras

`RateList` es dueña de la carga, filtro, diálogo y mensajes. Usa `filterRows` de ISS-03 sobre `name` y `billing_unit`. En creación agrega `is_active: true`; en edición envía únicamente los campos del formulario. La activación se maneja en una acción independiente.

Crear `src/app/features/rates/rate-list/rate-list.ts`:

```bash
cat > src/app/features/rates/rate-list/rate-list.ts <<'EOF'
import { HttpErrorResponse } from '@angular/common/http';
import { Component, computed, inject, signal } from '@angular/core';
import { Rate, RatePayload } from '../../../core/models/rate.model';
import { filterRows } from '../../../core/utils/filter-rows';
import { RateApi } from '../rate-api';
import { RateForm } from '../rate-form/rate-form';

type RateFormPayload = Omit<RatePayload, 'is_active'>;

@Component({
  selector: 'app-rate-list',
  imports: [RateForm],
  templateUrl: './rate-list.html',
  styleUrl: './rate-list.css',
})
export class RateList {
  private readonly api = inject(RateApi);

  readonly rows = signal<Rate[]>([]);
  readonly query = signal('');
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly dialogVisible = signal(false);
  readonly editing = signal<Rate | null>(null);
  readonly resetKey = signal(0);
  readonly errorMessage = signal<string | null>(null);
  readonly successMessage = signal<string | null>(null);
  readonly visibleRows = computed(() =>
    filterRows(this.rows(), this.query(), (rate) => [rate.name, rate.billing_unit]),
  );

  constructor() {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.errorMessage.set(null);
    this.api.list().subscribe({
      next: (rows) => {
        this.rows.set(rows);
        this.loading.set(false);
      },
      error: (error: unknown) => {
        this.rows.set([]);
        this.errorMessage.set(this.describeError(error));
        this.loading.set(false);
      },
    });
  }

  openCreate(): void {
    this.editing.set(null);
    this.resetKey.update((key) => key + 1);
    this.errorMessage.set(null);
    this.dialogVisible.set(true);
  }

  openEdit(rate: Rate): void {
    this.editing.set(rate);
    this.resetKey.update((key) => key + 1);
    this.errorMessage.set(null);
    this.dialogVisible.set(true);
  }

  onQueryChange(event: Event): void {
    if (event.target instanceof HTMLInputElement) {
      this.query.set(event.target.value);
    }
  }

  save(payload: RateFormPayload): void {
    const current = this.editing();
    this.saving.set(true);
    this.errorMessage.set(null);
    this.successMessage.set(null);
    const request = current
      ? this.api.update(current.id, payload)
      : this.api.create({ ...payload, is_active: true });

    request.subscribe({
      next: () => {
        this.saving.set(false);
        this.dialogVisible.set(false);
        this.successMessage.set(current ? 'Tarifa actualizada.' : 'Tarifa creada.');
        this.load();
      },
      error: (error: unknown) => {
        this.saving.set(false);
        this.errorMessage.set(this.describeError(error));
      },
    });
  }

  setActive(rate: Rate): void {
    const isActive = !rate.is_active;
    this.saving.set(true);
    this.errorMessage.set(null);
    this.successMessage.set(null);
    this.api.update(rate.id, { is_active: isActive }).subscribe({
      next: () => {
        this.saving.set(false);
        this.successMessage.set(isActive ? 'Tarifa activada.' : 'Tarifa desactivada.');
        this.load();
      },
      error: (error: unknown) => {
        this.saving.set(false);
        this.errorMessage.set(this.describeError(error));
      },
    });
  }

  private describeError(error: unknown): string {
    if (!(error instanceof HttpErrorResponse)) {
      return error instanceof Error ? error.message : 'Ocurrió un error inesperado.';
    }
    if (error.status === 0) return 'No se pudo conectar con la API de PedalLibre.';
    if (error.status === 401) return 'La API requiere una sesión válida.';
    if (error.status === 403) return 'Tu usuario no tiene permiso para esta operación.';

    const body: unknown = error.error;
    if (body && typeof body === 'object' && 'detail' in body && typeof body.detail === 'string') {
      return body.detail;
    }
    return `La API respondió con el estado ${error.status}.`;
  }
}
EOF
```

Crear `src/app/features/rates/rate-list/rate-list.html`:

```bash
cat > src/app/features/rates/rate-list/rate-list.html <<'EOF'
<section class="grid gap-5">
  <header class="flex flex-wrap items-end justify-between gap-3">
    <div>
      <h1 class="text-2xl font-semibold">Tarifas</h1>
      <p class="text-sm text-slate-600">Administra precios y vigencias.</p>
    </div>
    <button class="rounded bg-blue-700 px-4 py-2 font-medium text-white" type="button" (click)="openCreate()">Nueva tarifa</button>
  </header>

  @if (errorMessage()) {
    <p role="alert" class="rounded border border-red-300 bg-red-50 p-3 text-red-800">
      {{ errorMessage() }}
    </p>
  }
  @if (successMessage()) {
    <p role="status" class="rounded border border-green-300 bg-green-50 p-3 text-green-800">
      {{ successMessage() }}
    </p>
  }

  <label class="grid max-w-xl gap-1">
    Buscar por nombre o unidad de cobro
    <input class="rounded border border-slate-300 bg-white p-2" type="search" (input)="onQueryChange($event)" />
  </label>

  @if (loading()) {
    <p role="status">Cargando tarifas…</p>
  } @else if (rows().length === 0 && !errorMessage()) {
    <p class="rounded border bg-white p-6">Aún no hay tarifas registradas.</p>
  } @else if (visibleRows().length === 0 && rows().length > 0) {
    <p class="rounded border bg-white p-6">No hay tarifas que coincidan con la búsqueda.</p>
  } @else if (visibleRows().length > 0) {
    <div class="overflow-x-auto rounded border bg-white">
      <table class="w-full min-w-[800px] text-left text-sm">
        <thead class="bg-slate-100 text-slate-700">
          <tr>
            <th class="p-3">Nombre</th>
            <th class="p-3">Precio</th>
            <th class="p-3">Unidad</th>
            <th class="p-3">Vigencia</th>
            <th class="p-3">Estado</th>
            <th class="p-3">Acciones</th>
          </tr>
        </thead>
        <tbody>
          @for (rate of visibleRows(); track rate.id) {
            <tr class="border-t border-slate-200">
              <td class="p-3">{{ rate.name }}</td>
              <td class="p-3">{{ rate.price }}</td>
              <td class="p-3">{{ rate.billing_unit }}</td>
              <td class="p-3">{{ rate.valid_from || '—' }} — {{ rate.valid_until || '—' }}</td>
              <td class="p-3">{{ rate.is_active ? 'Activa' : 'Inactiva' }}</td>
              <td class="flex gap-2 p-3">
                <button class="rounded border border-slate-300 px-3 py-1" type="button" (click)="openEdit(rate)">Editar</button>
                <button class="rounded border border-slate-300 px-3 py-1 disabled:opacity-50" type="button" [disabled]="saving()" (click)="setActive(rate)">
                  {{ rate.is_active ? 'Desactivar' : 'Activar' }}
                </button>
              </td>
            </tr>
          }
        </tbody>
      </table>
    </div>
  }

  @if (dialogVisible()) {
    <div class="fixed inset-0 z-50 grid place-items-center overflow-y-auto bg-slate-950/50 p-4">
      <section class="my-auto w-full max-w-2xl rounded-lg bg-white p-5 shadow-xl"
        role="dialog" aria-modal="true" aria-labelledby="rate-dialog-title">
        <h2 id="rate-dialog-title" class="mb-4 text-xl font-semibold">
          {{ editing() ? 'Editar tarifa' : 'Nueva tarifa' }}
        </h2>
        <app-rate-form
          [rate]="editing()"
          [saving]="saving()"
          [resetKey]="resetKey()"
          (saved)="save($event)"
          (cancelled)="dialogVisible.set(false)"
        />
      </section>
    </div>
  }
</section>
EOF
```

El código usa mensajes en pantalla y no presupone que `MessageService` tenga un toast montado. Si la API devuelve 401/403, se muestra el error sin cambiar el permiso.

## 04.5 · Integración en `Construir`

El ítem **Tarifas** ya existe en `Construir.items`. Agregar `RateList` a los imports del componente y renderizarlo cuando el título seleccionado sea Tarifas; no crear `/tipos-producto`, `/rates` ni un Shell nuevo.

En `construir.ts`, importar y agregar `RateList`:

```ts
import { RateList } from '../rates/rate-list/rate-list';

// En @Component:
imports: [Aside, ClientList, DrawerModule, Footer, Header, RateList],
```

En `construir.html`, junto al caso de clientes:

```html
@if (title() === 'Clientes') {
  <app-client-list />
} @else if (title() === 'Tarifas') {
  <app-rate-list />
} @else {
  <h1 class="text-2xl font-semibold">{{ title() }}</h1>
  <p class="mt-2">Construye tu próxima experiencia con PedalLibre.</p>
}
```

La selección debe mantener `/construir`. No conectar la opción del menú con una autorización ficticia.

## 04.6 · Verificación y alcance de las evidencias

El backend de PedalLibre aplica `HasRoleResourceAccess`. La evidencia de navegador de esta ISS muestra que una petición sin credenciales recibe 401; por eso no se afirma que el CRUD contra la API esté funcional ni se desactiva RBAC para pasar esta comprobación.

Para completar la comprobación funcional del backend cuando exista una sesión autorizada:

1. Abrir **Tarifas** desde el menú y confirmar que sigue en `/construir`.
2. En Network, observar `GET /api/rates/` y comprobar que la tabla refleja la respuesta real.
3. Filtrar por nombre/unidad y confirmar que no aparece otra petición.
4. Probar validación del formulario; sin datos válidos no debe salir POST.
5. Crear con datos ficticios; verificar POST y respuesta.
6. Editar y verificar PATCH sin cambios accidentales a `is_active`.
7. Activar/desactivar y verificar PATCH con `is_active`; confirmar que no se envía DELETE.
8. Revisar 401/403 y estados vacíos/error, sin incluir datos sensibles en capturas.

La captura del navegador muestra la aplicación en `/construir`, el mensaje de sesión requerida y la terminal con `Application bundle generation complete`. No se aportaron resultados de pruebas automatizadas. Las capturas se guardan en `trazabilidad/evidencias/` y se describen en `trazabilidad/docs/guia-paso-a-paso.md`; no se insertan como imágenes en este documento.

## Resultado de la adaptación PedalLibre

ISS-04 completada con evidencias de la implementación del formulario, listado, búsqueda local, alta/edición, cambio de estado, manejo de errores e integración en `Construir`. La pantalla abre y el build reporta compilación completa. La API responde 401 sin sesión válida, así que las operaciones CRUD autorizadas y las pruebas automatizadas quedan explícitamente pendientes; esta limitación no se registra como un éxito funcional.

### Evidencias de implementación

- **EVI-04-01 a EVI-04-02:** generación de los componentes `RateForm` y `RateList`.
- **EVI-04-03 a EVI-04-04:** formulario reactivo, validaciones y fechas opcionales.
- **EVI-04-05 a EVI-04-07:** signals, filtro local, guardado/edición, PATCH de estado y manejo de errores.
- **EVI-04-08 a EVI-04-09:** plantilla de listado, estados, tabla, acciones y diálogo.
- **EVI-04-10 a EVI-04-11:** incorporación de `RateList` en `Construir` y su plantilla.
- **EVI-04-12:** pantalla de Tarifas en `/construir`, respuesta visible de sesión requerida y salida de compilación completa.

Las imágenes están enlazadas individualmente en la bitácora de [`guia-paso-a-paso.md`](../trazabilidad/docs/guia-paso-a-paso.md).

---

# ISS-04 original · CRUD de tipos de producto

> **Fin de la adaptación PedalLibre.** Desde aquí se conserva aparte el ISS original de StoreLab. Su entidad, API, rutas y pruebas no forman parte del contrato PedalLibre.

## Contexto original

La unidad original es «CRUD de tipos de producto» para `front-storelab-django`, con Angular 22, PrimeNG 22 Aura y Tailwind 4, sin CSS de negocio. El backend de referencia es `pry-django` en `http://localhost:8000/api`.

- `GET /api/product-types/` devuelve un arreglo plano.
- El alta nace `inactive`; el POST del original envía `status: "active"`.
- `name` no es único y admite hasta 100 caracteres.
- La baja usa DELETE y responde 204.
- Al terminar ISS-03, `/clientes` es un CRUD; `/tipos-producto` continúa como placeholder y su ítem ya está en `Shell.items`.
- No hay login ni interceptor; la guía original indica probar con `API_ACCESS=open`.
- Patrón visual: `PATRON-VISUAL.md`.

| Dato del ISS original | Valor |
|---|---|
| Título | CRUD de tipos de producto |
| Feature / tabla | `features/product-types` (`product-type-list`, `product-type-form`) sobre `product_types` |
| API | `GET` / `POST /api/product-types/`, `PATCH` / `DELETE /api/product-types/{id}/` |
| Depende de | ISS-03 — CRUD de clientes |
| Habilita | ISS-05 — CRUD de productos |

El patrón reutiliza servicio → signal → lista → formulario. El original usa `/api/product-types/`, lista plana y `DELETE`; esos son los rasgos del proyecto StoreLab.

**Evidencia de aprendizaje:** explicar qué se reutiliza de clientes y qué cambia; abrir `/tipos-producto` sin perder Header ni Footer.

## Objetivo original

Repetir el CRUD de ISS-03 con una entidad más simple antes de la primera relación de ISS-05. La lista muestra tipos activos; el formulario no solicita el estado y no comprueba unicidad del nombre.

La guía original llama a esto Fase I · Business: sin login, interceptor, guards ni directiva de permisos, con `API_ACCESS=open`.

## Requisitos originales

- [ ] **04.1** `ProductTypeApi.list('active')` consulta `/api/product-types/?status=active` con barra final.
- [ ] **04.2** El formulario exige un nombre de 2 a 100 caracteres y convierte descripción vacía en `null`.
- [ ] **04.3** El alta envía `status: "active"`; PATCH no envía `status`.
- [ ] **04.4** La baja confirma, ejecuta DELETE y recibe 204.
- [ ] **04.5** El buscador filtra nombre y descripción sin otra petición.
- [ ] **04.6** `/tipos-producto` carga `ProductTypeList` dentro de `Shell`.
- [ ] **04.7** Las pruebas del incremento pasan y el CSS del feature no tiene reglas.

## Construcción original

### 04.1 · Contrato

| Operación | Método y ruta | Cuerpo / respuesta |
|---|---|---|
| Listar activos | `GET /api/product-types/?status=active` | Arreglo plano |
| Obtener uno | `GET /api/product-types/{id}/` | Objeto |
| Crear | `POST /api/product-types/` | `{ name, description, status: "active" }` |
| Editar | `PATCH /api/product-types/{id}/` | `{ name, description }` |
| Baja lógica | `DELETE /api/product-types/{id}/` | 204; fila `inactive` |

`name` no es único. `description` es opcional; vacío se envía como `null`. Sin `status` en el POST, el registro nace `inactive` y no aparece en el filtro de activos.

### 04.2 · Componentes

```bash
ng generate component features/product-types/product-type-list --skip-tests --defaults
ng generate component features/product-types/product-type-form --skip-tests --defaults
```

El CSS se conserva sin reglas. `product-type-api.ts` ya existe desde ISS-02 y ofrece `list(status?)`; construye el parámetro solo si se entrega el filtro y `create` recibe el estado.

### 04.3 · Formulario original

`product-type-form` recibe el tipo, `resetKey` y `saving`; emite `ProductTypePayload` y no consulta la API. El efecto observa `resetKey()` y `productType()` para reiniciar el formulario al abrir el diálogo.

```ts
readonly form = this.fb.group({
  name: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(100)]],
  description: [''],
});
```

`submit()` recorta el nombre y convierte la descripción en blanco a `null`. No se agrega campo de estado ni validador de unicidad.

### 04.4 · Lista original

`load()` solicita `api.list('active')`. `visibleRows` filtra nombre y descripción con `filterRows`. El alta y la edición se distinguen así:

```ts
const request = current
  ? this.api.update(current.id, payload)
  : this.api.create({ ...payload, status: 'active' });
```

`deactivate()` abre `ConfirmationService`; solo la aceptación llama `remove(id)`. Al recargar `?status=active`, la fila deja de aparecer.

La tabla usa `#caption`, `#header`, `#body` y `#emptymessage`; muestra nombre, descripción, `app-status-tag`, editar y dar de baja. El buscador declara `aria-label="Buscar tipos"`.

### 04.5 · Ruta original

En `app.routes.ts`, la hija `tipos-producto` reemplaza el placeholder y carga `ProductTypeList`:

```ts
{
  path: 'tipos-producto',
  title: 'Tipos de producto · StoreLab',
  loadComponent: () =>
    import('./features/product-types/product-type-list/product-type-list')
      .then((module) => module.ProductTypeList),
}
```

El ítem de menú original está en `Shell.items`; no se crea `nav.config.ts`.

### 04.6 · Pruebas originales

- `product-type-api.spec.ts`: `list('active')` llama a `http://localhost:8000/api/product-types/` con `status=active`.
- `product-type-list.spec.ts`: un `ConfirmationService` falso ejecuta `accept` y verifica que `remove` recibe el id; el alta llama a `save()` y envía `status: 'active'`.

## Cómo probar el original

1. Consultar `curl -s 'http://localhost:8000/api/product-types/?status=active'`: debe devolver el arreglo plano.
2. Abrir `http://localhost:4200/tipos-producto`; buscar «Ambiente»: queda una fila y no se dispara otro GET.
3. Intentar guardar nombre vacío: aparece el mensaje «entre 2 y 100 caracteres» y no sale POST.
4. Crear un tipo de prueba con nombre y descripción: respuesta con `status: "active"` y fila visible.
5. Confirmar la baja: DELETE 204, fila fuera de la lista activa y GET de detalle con `"status": "inactive"`.

## Criterios originales de aceptación

- **AC-04-01:** `GET /api/product-types/?status=active` pinta solo tipos activos.
- **AC-04-02:** el buscador filtra nombre y descripción sin otra petición.
- **AC-04-03:** el nombre vacío no se envía y muestra la validación de 2 a 100 caracteres.
- **AC-04-04:** el alta usa POST con `status: "active"` y descripción vacía como `null`.
- **AC-04-05:** la baja confirma, usa DELETE y retira la fila de la lista.
- **AC-04-06:** `/tipos-producto` vive dentro de `Shell`.
- **AC-04-07:** pasan las pruebas del feature y el CSS no contiene reglas.

## Verificación y resultados originales

Resultados reportados en ese workspace (24-oct-2026):

| Comprobación | Resultado original |
|---|---|
| `GET /api/product-types/?status=active` | Cinco tipos activos: Ambiente, Cuya, Efectos, Espera y Queda |
| Buscar «Ambiente» | Una fila: «Ambiente #11»; sin GET adicional |
| Nombre vacío | Se muestra el mensaje de 2 a 100 caracteres; no se envía POST |
| Alta | Crea id 12 «Tipo ISS04», activa, con descripción de verificación; la lista queda con seis activos |
| Baja | Confirmación; lista regresa a cinco activos y el detalle id 12 queda `inactive` |
| Ruta | Título «Tipos de producto · StoreLab» dentro de `Shell` |
| Pruebas | Pruebas de API (barra final y filtro) y lista (baja aceptada y alta con estado) |

| Criterio | Resultado original |
|---|---|
| AC-04-01 | Arreglo activo en tabla — PASS |
| AC-04-02 | Búsqueda sin otro GET — PASS |
| AC-04-03 | Nombre vacío no se envía — PASS |
| AC-04-04 | Alta crea id 12 con `status: "active"` — PASS |
| AC-04-05 | Baja deja id 12 `inactive` y lo retira de la tabla — PASS |
| AC-04-06 | Pantalla conserva Header y Aside — PASS |
| AC-04-07 | Pruebas del feature y CSS sin reglas — PASS |

## Evidencias originales

- **EVI-04-01:** tabla con cinco activos y buscador en «Ambiente».
- **EVI-04-02:** diálogo de alta con validación y luego fila «Tipo ISS04 #12».
- **EVI-04-03:** confirmación de baja y detalle con estado `inactive`.

## Gate original

```text
TODOS los AC = PASS  → se puede avanzar a ISS-05
ALGÚN AC = FAIL      → se corrige y se repite
```

Navegación original: ← ISS-03 · Construir · ↑ Ruta Frontend-Django · → ISS-05 · Construir
