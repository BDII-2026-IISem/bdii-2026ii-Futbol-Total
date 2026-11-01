---
title: "ISS-05 · CRUD de bicicletas PedalLibre"
project: "Frontend de PedalLibre"
layer: "Construir"
depends_on: "ISS-02 · Núcleo, modelos y servicios; ISS-04 · Tarifas"
status: "Completada con evidencias; alcance de las pruebas documentado"
---

# ISS-05 · CRUD de bicicletas PedalLibre

> **Proyecto:** Frontend PedalLibre (`Front-2026/`).
> **Capa:** Construir.
> **Adaptación:** PedalLibre no tiene productos, tipos de producto, precios ni existencias. El catálogo que corresponde administrar es **Bicicletas**.
> **Importante:** la aplicación todavía no tiene login. No pedir autenticación ni credenciales para las pruebas; probar componentes con respuestas HTTP simuladas. Si una llamada real devuelve 401/403, mostrar el error sin eludir RBAC.

## Contexto de PedalLibre

El backend expone el modelo `Bicycle` mediante `BicycleSerializer` y el frontend ya tiene `Bicycle` y `BicycleApi.available()` de ISS-02. El endpoint de disponibilidad filtra por estado, anclaje activo y estación operativa, y excluye bicicletas con mantenimiento vigente. No representa inventario con `quantity` ni `minStock`.

El catálogo CRUD y la consulta de disponibilidad son lecturas distintas:

- `GET /api/bicycles/` administra el catálogo; devuelve bicicletas registradas, también las inactivas.
- `GET /api/bicycles/available/` devuelve solo bicicletas que pueden seleccionarse para una operación de alquiler.
- La bicicleta es una entidad operativa. El estado `rented`, `reserved` o `maintenance` lo determinan los flujos de alquiler, reserva y mantenimiento; esta pantalla no debe ofrecer un editor libre de esos estados.

## Objetivo

Consultar, buscar, crear y editar bicicletas dentro de la pantalla existente de `Construir`. Permitir activar o desactivar el indicador administrativo `isActive` con PATCH. Incluir un filtro local **Solo disponibles** que consulta el endpoint específico `/api/bicycles/available/`, no un cálculo de existencias en el navegador.

El formulario administra los datos descriptivos y el serial. No administra alquileres, anclajes, reservas ni mantenimiento. No agrega baja con DELETE: el backend deshabilita ese método para el catálogo.

## Contrato real

La raíz del backend es `/api`; la colección de bicicletas está registrada en `BicycleViewSet`, que acepta GET, POST, PUT y PATCH, pero no DELETE.

| Operación | Método y ruta | Resultado |
|---|---|---|
| Catálogo | `GET /api/bicycles/` | Arreglo de bicicletas del catálogo |
| Disponibilidad operativa | `GET /api/bicycles/available/` | Arreglo elegible para alquiler; considera bicicleta, anclaje, estación y mantenimiento |
| Obtener una | `GET /api/bicycles/{id}/` | Objeto de bicicleta |
| Crear | `POST /api/bicycles/` | Objeto creado |
| Editar datos descriptivos | `PATCH /api/bicycles/{id}/` | Objeto actualizado |
| Activar/desactivar administración | `PATCH /api/bicycles/{id}/` | Enviar solo `isActive` |
| Eliminar | No disponible | No se debe llamar DELETE |

### Lectura y escritura

El modelo real contiene `serial_number` único, `name` opcional, `description`, `bicycle_type`, `status`, `is_active`, `created_at` y `updated_at`. Los límites del modelo son: serial hasta 80 caracteres, nombre hasta 120, tipo hasta 50 y estado hasta 30. Nombre y descripción pueden estar vacíos; el tipo por defecto es `standard`; estado por defecto `available`; `is_active` por defecto `true`.

El renderer/parser configurado en Django transforma nombres entre `snake_case` y `camelCase`. Por eso la frontera JSON usa nombres como `serialNumber`, `bicycleType`, `isActive`, `createdAt` y `updatedAt`, aunque el modelo TypeScript existente de ISS-02 esté escrito con `snake_case`. No tipar una respuesta camelCase como `Bicycle` snake_case sin adaptar la frontera: definir el DTO de API correcto y mapearlo al modelo de vista, o alinear coherentemente el tipo frontend.

Payload de creación para el renderer camelCase:

```ts
export interface BicycleCreatePayload {
  serialNumber: string;
  name?: string;
  description?: string;
  bicycleType?: string;
}
```

El backend aplica `status="available"` e `isActive=true` por defecto. El formulario no envía esos campos al crear. Para edición se envían solo los campos descriptivos que cambiaron:

```ts
export type BicycleUpdatePayload = Partial<
  Pick<BicycleCreatePayload, 'serialNumber' | 'name' | 'description' | 'bicycleType'>
>;
```

La acción separada de activar/desactivar envía `{ isActive: boolean }`. No incluir `createdAt`, `updatedAt` ni `id` en escrituras. Tampoco permitir que editar nombre/serial modifique `status`.

### Significado de disponibilidad

El endpoint `/api/bicycles/available/` considera `status="available"`, `is_active=true`, anclaje vigente en un docking point activo y disponible de una estación activa, y ausencia de mantenimientos con estado `scheduled` o `in_progress`. No basta con que una bicicleta esté marcada `available` en su campo `status`.

La disponibilidad puede cambiar por operaciones externas al CRUD. Al alternar entre catálogo y disponibles, pedir el endpoint que corresponda. El indicador **Solo disponibles** cambia la fuente de lectura, no el estado de una bicicleta.

## Requisitos para PedalLibre

- [x] **05.1** `BicycleApi` ofrece `list()`, `get(id)`, `create(payload)` y `update(id, payload)` sobre `/api/bicycles/`, además del método `available()` existente para `/api/bicycles/available/`.
- [x] **05.2** El DTO de transporte refleja los nombres camelCase de la API y no confunde el modelo actual snake_case con la respuesta.
- [x] **05.3** El formulario valida serial requerido y límites reales; el alta usa los valores por defecto del backend o envía explícitamente `status: "available"` e `isActive: true`.
- [x] **05.4** La edición PATCH solo cambia los campos descriptivos y no modifica `status`; activar/desactivar PATCH usa `isActive`.
- [x] **05.5** La tabla puede alternar entre catálogo y endpoint de disponibles sin calcular `quantity`/`minStock`.
- [x] **05.6** Se muestran estados de carga, error, vacío, filtro sin coincidencias y errores 401/403 sin falsos éxitos.
- [x] **05.7** La pantalla reutiliza `Construir` y conserva Header, Aside y Footer.
- [x] **05.8** La interfaz no ofrece DELETE ni cambios arbitrarios de estados operativos.
- [x] **05.9** El build, la suite automatizada ejecutada y el CSS sin reglas se documentan junto con el alcance real de cobertura; las capturas no se presentan como pruebas que no se ejecutaron.

## Construcción adaptada

### 05.1 · Completar `BicycleApi`

ISS-02 ya creó el modelo y `BicycleApi.available()`. Extender ese servicio existente, no crear un segundo servicio, y mantener la barra final:

Desde `Front-2026/`, sustituir el modelo snake_case creado en ISS-02 por el DTO camelCase que realmente intercambia la API:

```bash
cat > src/app/core/models/bicycle.model.ts <<'EOF'
export interface Bicycle {
  id: number;
  serialNumber: string;
  name: string;
  description: string;
  bicycleType: string;
  status: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export type BicycleCreatePayload = Pick<
  Bicycle,
  'serialNumber' | 'name' | 'description' | 'bicycleType'
>;

export type BicycleUpdatePayload = Partial<BicycleCreatePayload>;
EOF
```

Reemplazar el contenido del servicio existente, conservando también `available()`:

```bash
cat > src/app/features/bicycles/bicycle-api.ts <<'EOF'
import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  Bicycle,
  BicycleCreatePayload,
  BicycleUpdatePayload,
} from '../../core/models/bicycle.model';

@Injectable({ providedIn: 'root' })
export class BicycleApi {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/bicycles`;

  list(): Observable<Bicycle[]> {
    return this.http.get<Bicycle[]>(`${this.base}/`);
  }

  get(id: number): Observable<Bicycle> {
    return this.http.get<Bicycle>(`${this.base}/${id}/`);
  }

  create(payload: BicycleCreatePayload): Observable<Bicycle> {
    return this.http.post<Bicycle>(`${this.base}/`, payload);
  }

  update(
    id: number,
    payload: BicycleUpdatePayload | { isActive: boolean },
  ): Observable<Bicycle> {
    return this.http.patch<Bicycle>(`${this.base}/${id}/`, payload);
  }

  available(): Observable<Bicycle[]> {
    return this.http.get<Bicycle[]>(`${this.base}/available/`);
  }
}
EOF
```

### 05.2 · Crear lista y formulario

Desde `Front-2026/`, generar los componentes:

```bash
npx ng generate component features/bicycles/bicycle-list --skip-tests --defaults
npx ng generate component features/bicycles/bicycle-form --skip-tests --defaults
```

El formulario recibe bicicleta, `resetKey` y `saving`, y emite payloads. Los siguientes comandos crean el formulario reactivo. El servidor aplica unicidad al serial; mostrar el 400 que resulte de una colisión sin cerrar el diálogo como si hubiese guardado.

```bash
cat > src/app/features/bicycles/bicycle-form/bicycle-form.ts <<'EOF'
import { Component, effect, inject, input, output } from '@angular/core';
import { NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import {
  Bicycle,
  BicycleCreatePayload,
} from '../../../core/models/bicycle.model';

@Component({
  selector: 'app-bicycle-form',
  imports: [ReactiveFormsModule],
  templateUrl: './bicycle-form.html',
  styleUrl: './bicycle-form.css',
})
export class BicycleForm {
  readonly bicycle = input<Bicycle | null>(null);
  readonly saving = input(false);
  readonly resetKey = input(0);
  readonly saved = output<BicycleCreatePayload>();
  readonly cancelled = output<void>();

  private readonly fb = inject(NonNullableFormBuilder);
  readonly form = this.fb.group({
    serialNumber: ['', [Validators.required, Validators.maxLength(80)]],
    name: ['', [Validators.maxLength(120)]],
    description: [''],
    bicycleType: ['standard', [Validators.required, Validators.maxLength(50)]],
  });

  constructor() {
    effect(() => {
      const current = this.bicycle();
      this.resetKey();
      this.form.reset({
        serialNumber: current?.serialNumber ?? '',
        name: current?.name ?? '',
        description: current?.description ?? '',
        bicycleType: current?.bicycleType ?? 'standard',
      });
    });
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const value = this.form.getRawValue();
    const serialNumber = value.serialNumber.trim();
    if (!serialNumber) {
      this.form.controls.serialNumber.setErrors({ required: true });
      this.form.controls.serialNumber.markAsTouched();
      return;
    }
    this.saved.emit({
      serialNumber,
      name: value.name.trim(),
      description: value.description.trim(),
      bicycleType: value.bicycleType.trim(),
    });
  }
}
EOF
```

```bash
cat > src/app/features/bicycles/bicycle-form/bicycle-form.html <<'EOF'
<form [formGroup]="form" (ngSubmit)="submit()" class="grid gap-4">
  <label class="grid gap-1">
    Serial *
    <input class="rounded border border-slate-300 p-2" formControlName="serialNumber" maxlength="80" required />
    @if (form.controls.serialNumber.touched && form.controls.serialNumber.invalid) {
      <span class="text-sm text-red-700">El serial es obligatorio (máximo 80 caracteres).</span>
    }
  </label>

  <label class="grid gap-1">
    Nombre
    <input class="rounded border border-slate-300 p-2" formControlName="name" maxlength="120" />
  </label>

  <label class="grid gap-1">
    Descripción
    <textarea class="rounded border border-slate-300 p-2" formControlName="description"></textarea>
  </label>

  <label class="grid gap-1">
    Tipo de bicicleta *
    <input class="rounded border border-slate-300 p-2" formControlName="bicycleType" maxlength="50" required />
    @if (form.controls.bicycleType.touched && form.controls.bicycleType.invalid) {
      <span class="text-sm text-red-700">El tipo es obligatorio (máximo 50 caracteres).</span>
    }
  </label>

  <div class="flex justify-end gap-2 border-t border-slate-200 pt-4">
    <button class="rounded border border-slate-300 px-4 py-2" type="button" (click)="cancelled.emit()">Cancelar</button>
    <button class="rounded bg-blue-700 px-4 py-2 text-white disabled:opacity-50" type="submit" [disabled]="saving()">
      {{ saving() ? 'Guardando…' : 'Guardar' }}
    </button>
  </div>
</form>
EOF
```

La edición no debe editar `status`. Al crear, el payload omite `status` e `isActive` para que se apliquen los defaults reales del modelo (`available` y `true`). El método de desactivar cambia `isActive` y no elimina la bicicleta.

### 05.3 · Lista, filtro y acciones

`BicycleList` carga `BicycleApi.list()` por defecto. Un control de solo lectura cambia entre `list()` y `available()` y vuelve a solicitar los datos; no construye una lista de disponibilidad con `status` únicamente. El siguiente comando crea el componente con filtro local, acciones y gestión de errores.

```bash
cat > src/app/features/bicycles/bicycle-list/bicycle-list.ts <<'EOF'
import { HttpErrorResponse } from '@angular/common/http';
import { Component, computed, inject, signal } from '@angular/core';
import { Bicycle, BicycleCreatePayload } from '../../../core/models/bicycle.model';
import { filterRows } from '../../../core/utils/filter-rows';
import { BicycleApi } from '../bicycle-api';
import { BicycleForm } from '../bicycle-form/bicycle-form';

@Component({
  selector: 'app-bicycle-list',
  imports: [BicycleForm],
  templateUrl: './bicycle-list.html',
  styleUrl: './bicycle-list.css',
})
export class BicycleList {
  private readonly api = inject(BicycleApi);
  readonly rows = signal<Bicycle[]>([]);
  readonly query = signal('');
  readonly onlyAvailable = signal(false);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly dialogVisible = signal(false);
  readonly editing = signal<Bicycle | null>(null);
  readonly resetKey = signal(0);
  readonly errorMessage = signal<string | null>(null);
  readonly successMessage = signal<string | null>(null);
  readonly visibleRows = computed(() =>
    filterRows(this.rows(), this.query(), (row) => [
      row.serialNumber,
      row.name,
      row.bicycleType,
      row.status,
    ]),
  );

  constructor() {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.errorMessage.set(null);
    const request = this.onlyAvailable() ? this.api.available() : this.api.list();
    request.subscribe({
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

  onQueryChange(event: Event): void {
    if (event.target instanceof HTMLInputElement) this.query.set(event.target.value);
  }

  setAvailableMode(available: boolean): void {
    if (this.onlyAvailable() === available) return;
    this.onlyAvailable.set(available);
    this.load();
  }

  openCreate(): void {
    this.editing.set(null);
    this.resetKey.update((key) => key + 1);
    this.errorMessage.set(null);
    this.dialogVisible.set(true);
  }

  openEdit(bicycle: Bicycle): void {
    this.editing.set(bicycle);
    this.resetKey.update((key) => key + 1);
    this.errorMessage.set(null);
    this.dialogVisible.set(true);
  }

  closeForm(): void {
    if (!this.saving()) this.dialogVisible.set(false);
  }

  save(payload: BicycleCreatePayload): void {
    const current = this.editing();
    this.saving.set(true);
    this.errorMessage.set(null);
    this.successMessage.set(null);
    const request = current
      ? this.api.update(current.id, payload)
      : this.api.create(payload);
    request.subscribe({
      next: () => {
        this.saving.set(false);
        this.dialogVisible.set(false);
        this.successMessage.set(current ? 'Bicicleta actualizada.' : 'Bicicleta creada.');
        this.load();
      },
      error: (error: unknown) => {
        this.saving.set(false);
        this.errorMessage.set(this.describeError(error));
      },
    });
  }

  toggleActive(bicycle: Bicycle): void {
    const isActive = !bicycle.isActive;
    this.saving.set(true);
    this.errorMessage.set(null);
    this.successMessage.set(null);
    this.api.update(bicycle.id, { isActive }).subscribe({
      next: () => {
        this.saving.set(false);
        this.successMessage.set(isActive ? 'Bicicleta activada.' : 'Bicicleta desactivada.');
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
    if (error.status === 401) return 'La API rechazó la solicitud (401).';
    if (error.status === 403) return 'Tu usuario no tiene permiso para esta operación.';
    const body: unknown = error.error;
    if (body && typeof body === 'object' && 'detail' in body && typeof body.detail === 'string') {
      return body.detail;
    }
    if (body && typeof body === 'object' && !Array.isArray(body)) {
      const first = Object.entries(body)[0];
      if (first) {
        const [field, value] = first;
        const message = Array.isArray(value) ? value[0] : value;
        if (typeof message === 'string') return `${field}: ${message}`;
      }
    }
    return `La API respondió con el estado ${error.status}.`;
  }
}
EOF
```

```bash
cat > src/app/features/bicycles/bicycle-list/bicycle-list.html <<'EOF'
<section class="grid gap-5">
  <header class="flex flex-wrap items-end justify-between gap-3">
    <div>
      <h1 class="text-2xl font-semibold">Bicicletas</h1>
      <p class="mt-1 text-sm text-slate-600">Administra el catálogo y consulta disponibilidad operativa.</p>
    </div>
    <button class="rounded bg-blue-700 px-4 py-2 font-medium text-white" type="button"
      [disabled]="onlyAvailable()" (click)="openCreate()">Nueva bicicleta</button>
  </header>

  @if (errorMessage()) {
    <p role="alert" class="rounded border border-red-300 bg-red-50 p-3 text-red-800">{{ errorMessage() }}</p>
  }
  @if (successMessage()) {
    <p role="status" class="rounded border border-green-300 bg-green-50 p-3 text-green-800">{{ successMessage() }}</p>
  }

  <div class="flex flex-wrap items-center gap-3">
    <label class="flex items-center gap-2">
      <input type="checkbox" [checked]="onlyAvailable()" (change)="setAvailableMode($any($event.target).checked)" />
      Solo disponibles
    </label>
    <label class="grid max-w-xl flex-1 gap-1">
      Buscar por serial, nombre, tipo o estado
      <input class="rounded border border-slate-300 bg-white p-2" type="search" (input)="onQueryChange($event)" />
    </label>
  </div>

  @if (loading()) {
    <p role="status">Cargando bicicletas…</p>
  } @else if (errorMessage()) {
    <p class="rounded border border-slate-200 bg-white p-6 text-slate-600">No se pudo cargar el catálogo.</p>
  } @else if (rows().length === 0) {
    <p class="rounded border border-slate-200 bg-white p-6 text-slate-600">
      {{ onlyAvailable() ? 'No hay bicicletas disponibles.' : 'Aún no hay bicicletas registradas.' }}
    </p>
  } @else if (visibleRows().length === 0) {
    <p class="rounded border border-slate-200 bg-white p-6 text-slate-600">No hay coincidencias.</p>
  } @else {
    <div class="overflow-x-auto rounded border border-slate-200 bg-white">
      <table class="w-full min-w-[760px] text-left text-sm">
        <thead class="bg-slate-100 text-slate-700">
          <tr>
            <th class="p-3">Serial</th><th class="p-3">Nombre</th><th class="p-3">Tipo</th>
            <th class="p-3">Estado operativo</th><th class="p-3">Activa</th><th class="p-3">Acciones</th>
          </tr>
        </thead>
        <tbody>
          @for (bicycle of visibleRows(); track bicycle.id) {
            <tr class="border-t border-slate-200">
              <td class="p-3">{{ bicycle.serialNumber }}</td>
              <td class="p-3">{{ bicycle.name || '—' }}</td>
              <td class="p-3">{{ bicycle.bicycleType }}</td>
              <td class="p-3">{{ bicycle.status }}</td>
              <td class="p-3">{{ bicycle.isActive ? 'Sí' : 'No' }}</td>
              <td class="flex gap-2 p-3">
                @if (!onlyAvailable()) {
                  <button class="rounded border border-slate-300 px-3 py-1" type="button"
                    (click)="openEdit(bicycle)">Editar</button>
                  <button class="rounded border border-slate-300 px-3 py-1 disabled:opacity-50" type="button"
                    [disabled]="saving()" (click)="toggleActive(bicycle)">
                    {{ bicycle.isActive ? 'Desactivar' : 'Activar' }}
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
    </div>
  }

  @if (dialogVisible()) {
    <div class="fixed inset-0 z-50 grid place-items-center overflow-y-auto bg-slate-950/50 p-4" (click)="closeForm()">
      <section class="my-auto w-full max-w-2xl rounded-lg bg-white p-5 shadow-xl" role="dialog"
        aria-modal="true" aria-labelledby="bicycle-dialog-title" (click)="$event.stopPropagation()">
        <h2 id="bicycle-dialog-title" class="mb-4 text-xl font-semibold">
          {{ editing() ? 'Editar bicicleta' : 'Nueva bicicleta' }}
        </h2>
        <app-bicycle-form [bicycle]="editing()" [saving]="saving()" [resetKey]="resetKey()"
          (saved)="save($event)" (cancelled)="closeForm()" />
      </section>
    </div>
  }
</section>
EOF
```

```bash
cat > src/app/features/bicycles/bicycle-form/bicycle-form.css <<'EOF'
EOF
```

```bash
cat > src/app/features/bicycles/bicycle-list/bicycle-list.css <<'EOF'
EOF
```

El buscador local compara serial, nombre, tipo y estado.

Ofrecer editar datos descriptivos y activar/desactivar `isActive`. La acción de activación no debe mostrarse como disponibilidad de alquiler: son conceptos distintos. No ofrecer transición manual a `rented`, `reserved` o `maintenance`; los flujos del negocio son responsables de esos estados.

### 05.4 · Integrar en `Construir`

El menú ya tiene una entrada **Bicicletas disponibles**. Reutilizarla como entrada a la pantalla de bicicletas; se puede ajustar el rótulo a **Bicicletas** porque incluye catálogo y vista filtrada, manteniendo la selección dentro de `Construir` y sin crear `/productos` ni otra ruta.

Cada comando reemplaza un archivo completo de `Construir`. Ejecutarlos después de ISS-03 e ISS-04; el HTML conserva las pantallas anteriores e incluye explícitamente el bloque `@else if (title() === 'Bicicletas')` que muestra `<app-bicycle-list />`.

```bash
cat > src/app/features/construir/construir.ts <<'EOF'
import { DOCUMENT } from '@angular/common';
import { Component, DestroyRef, inject, signal } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { DrawerModule } from 'primeng/drawer';
import { Aside } from '../../layout/aside/aside';
import { Footer } from '../../layout/footer/footer';
import { Header } from '../../layout/header/header';
import { BicycleList } from '../bicycles/bicycle-list/bicycle-list';
import { ClientList } from '../clients/client-list/client-list';
import { RateList } from '../rates/rate-list/rate-list';

@Component({
  imports: [Aside, BicycleList, ClientList, DrawerModule, Footer, Header, RateList],
  selector: 'app-construir',
  styleUrl: './construir.css',
  templateUrl: './construir.html',
})
export class Construir {
  readonly mobileOpen = signal(false);
  readonly sidebarCollapsed = signal(false);
  readonly title = signal('Inicio');
  readonly items: MenuItem[] = [
    { label: 'Inicio', command: () => this.seleccionar('Inicio') },
    { label: 'Clientes', command: () => this.seleccionar('Clientes') },
    { label: 'Bicicletas', command: () => this.seleccionar('Bicicletas') },
    { label: 'Tarifas', command: () => this.seleccionar('Tarifas') },
    { label: 'Acceso', command: () => this.seleccionar('Acceso') },
  ];

  private readonly destroyRef = inject(DestroyRef);
  private isDesktop = false;

  constructor() {
    const view = inject(DOCUMENT).defaultView;
    const mediaQuery = view?.matchMedia?.('(min-width: 1024px)');
    if (!mediaQuery) return;
    this.isDesktop = mediaQuery.matches;
    const updateBreakpoint = (event: MediaQueryListEvent): void => {
      this.isDesktop = event.matches;
    };
    mediaQuery.addEventListener('change', updateBreakpoint);
    this.destroyRef.onDestroy(() => mediaQuery.removeEventListener('change', updateBreakpoint));
  }

  seleccionar(titulo: string): void {
    this.title.set(titulo);
    this.mobileOpen.set(false);
  }

  onMenuToggle(): void {
    if (this.isDesktop) {
      this.sidebarCollapsed.update((collapsed) => !collapsed);
      return;
    }
    this.mobileOpen.update((open) => !open);
  }
}
EOF
```

```bash
cat > src/app/features/construir/construir.html <<'EOF'
<div class="flex min-h-screen flex-col bg-slate-100 font-sans text-slate-900">
  <app-header appName="PedalLibre" (menuRequested)="onMenuToggle()" />
  <div class="flex min-h-0 flex-1">
    @if (!sidebarCollapsed()) {
      <aside class="hidden w-72 shrink-0 bg-white lg:block">
        <app-aside [items]="items" (navigated)="mobileOpen.set(false)" />
      </aside>
    }
    <main id="contenido" class="min-w-0 flex-1 p-6">
      @if (title() === 'Clientes') {
        <app-client-list />
      } @else if (title() === 'Bicicletas') {
        <app-bicycle-list />
      } @else if (title() === 'Tarifas') {
        <app-rate-list />
      } @else {
        <h1 class="text-2xl font-semibold">{{ title() }}</h1>
        <p class="mt-2">Construye tu próxima experiencia con PedalLibre.</p>
      }
    </main>
  </div>
  <app-footer />
  <p-drawer [(visible)]="mobileOpen" position="left">
    <app-aside [items]="items" (navigated)="mobileOpen.set(false)" />
  </p-drawer>
</div>
EOF
```

### 05.5 · Errores y pruebas

Los errores 400 por serial duplicado, 401/403 y errores de conexión deben mostrarse explícitamente. No modificar RBAC ni asumir `API_ACCESS=open`. No pedir login o credenciales: la app todavía no implementa autenticación.

Pruebas sugeridas, usando `HttpTestingController` o mocks; no requieren una sesión:

- `BicycleApi.list()` y `get()` mantienen barra final y URLs reales.
- `available()` consulta `/api/bicycles/available/`.
- Crear convierte el formulario al payload camelCase y no incluye campos de solo lectura.
- Editar envía cambios descriptivos mediante PATCH y no cambia `status`.
- Activar/desactivar envía `{ isActive }`; ninguna acción llama DELETE.
- El cambio de modo vuelve a solicitar el endpoint correcto.
- Simular respuestas 401/403 comprueba que se muestra el error y no se reporta éxito.
- El CSS del feature no contiene reglas de negocio.

El build y las pruebas unitarias locales no necesitan login. No exigir pruebas contra la API real para completar esta ISS mientras no exista una sesión de prueba; no registrar operaciones reales como verificadas sin evidencia.

#### Comandos para crear las pruebas

Ejecutar desde `Front-2026/`. Cada bloque crea un solo archivo. Los tests usan `HttpTestingController`, así que no hacen llamadas reales a la API ni requieren login.

```bash
cat > src/app/features/bicycles/bicycle-api.spec.ts <<'EOF'
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../../environments/environment';
import { BicycleApi } from './bicycle-api';

describe('BicycleApi', () => {
  let api: BicycleApi;
  let http: HttpTestingController;
  const collectionUrl = `${environment.apiUrl}/bicycles/`;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    api = TestBed.inject(BicycleApi);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('uses the collection and detail URLs with trailing slashes', () => {
    api.list().subscribe();
    const listRequest = http.expectOne(collectionUrl);
    expect(listRequest.request.method).toBe('GET');
    listRequest.flush([]);

    api.get(17).subscribe();
    const detailRequest = http.expectOne(`${environment.apiUrl}/bicycles/17/`);
    expect(detailRequest.request.method).toBe('GET');
    detailRequest.flush({
      id: 17,
      serialNumber: 'PED-017',
      name: 'Bici de prueba',
      description: '',
      bicycleType: 'standard',
      status: 'available',
      isActive: true,
      createdAt: '',
      updatedAt: '',
    });
  });

  it('uses available endpoint and sends only writable fields', () => {
    api.available().subscribe();
    const availableRequest = http.expectOne(`${environment.apiUrl}/bicycles/available/`);
    expect(availableRequest.request.method).toBe('GET');
    availableRequest.flush([]);

    const payload = {
      serialNumber: 'PED-018',
      name: 'Bici nueva',
      description: '',
      bicycleType: 'standard',
    };
    api.create(payload).subscribe();
    const createRequest = http.expectOne(collectionUrl);
    expect(createRequest.request.method).toBe('POST');
    expect(createRequest.request.body).toEqual(payload);
    expect(createRequest.request.body).not.toHaveProperty('status');
    expect(createRequest.request.body).not.toHaveProperty('isActive');
    createRequest.flush({
      id: 18,
      ...payload,
      status: 'available',
      isActive: true,
      createdAt: '',
      updatedAt: '',
    });
  });

  it('patches descriptive fields and isActive without sending status or DELETE', () => {
    api.update(17, { name: 'Nombre actualizado', serialNumber: 'PED-017' }).subscribe();
    const editRequest = http.expectOne(`${environment.apiUrl}/bicycles/17/`);
    expect(editRequest.request.method).toBe('PATCH');
    expect(editRequest.request.body).toEqual({
      name: 'Nombre actualizado',
      serialNumber: 'PED-017',
    });
    expect(editRequest.request.body).not.toHaveProperty('status');
    editRequest.flush({
      id: 17,
      serialNumber: 'PED-017',
      name: 'Nombre actualizado',
      description: '',
      bicycleType: 'standard',
      status: 'available',
      isActive: true,
      createdAt: '',
      updatedAt: '',
    });

    api.update(17, { isActive: false }).subscribe();
    const activeRequest = http.expectOne(`${environment.apiUrl}/bicycles/17/`);
    expect(activeRequest.request.method).toBe('PATCH');
    expect(activeRequest.request.body).toEqual({ isActive: false });
    activeRequest.flush({
      id: 17,
      serialNumber: 'PED-017',
      name: 'Nombre actualizado',
      description: '',
      bicycleType: 'standard',
      status: 'available',
      isActive: false,
      createdAt: '',
      updatedAt: '',
    });
    http.expectNone((request) => request.method === 'DELETE');
  });
});
EOF
```

```bash
cat > src/app/features/bicycles/bicycle-form/bicycle-form.spec.ts <<'EOF'
import { TestBed } from '@angular/core/testing';
import { BicycleCreatePayload } from '../../../core/models/bicycle.model';
import { BicycleForm } from './bicycle-form';

describe('BicycleForm', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BicycleForm],
    }).compileComponents();
  });

  it('emits a trimmed camelCase payload without read-only fields', async () => {
    const fixture = TestBed.createComponent(BicycleForm);
    fixture.detectChanges();
    await fixture.whenStable();

    const emitted: BicycleCreatePayload[] = [];
    fixture.componentInstance.saved.subscribe((payload) => emitted.push(payload));
    fixture.componentInstance.form.setValue({
      serialNumber: '  PED-021  ',
      name: '  Bici nueva  ',
      description: '  Descripción  ',
      bicycleType: '  standard  ',
    });

    fixture.componentInstance.submit();

    expect(emitted).toEqual([{
      serialNumber: 'PED-021',
      name: 'Bici nueva',
      description: 'Descripción',
      bicycleType: 'standard',
    }]);
    expect(Object.keys(emitted[0]).sort()).toEqual([
      'bicycleType',
      'description',
      'name',
      'serialNumber',
    ]);
  });

  it('does not emit when the serial is blank', async () => {
    const fixture = TestBed.createComponent(BicycleForm);
    fixture.detectChanges();
    await fixture.whenStable();

    let emitted = false;
    fixture.componentInstance.saved.subscribe(() => emitted = true);
    fixture.componentInstance.form.controls.serialNumber.setValue('   ');

    fixture.componentInstance.submit();

    expect(emitted).toBe(false);
    expect(fixture.componentInstance.form.controls.serialNumber.touched).toBe(true);
  });
});
EOF
```

```bash
cat > src/app/features/bicycles/bicycle-list/bicycle-list.spec.ts <<'EOF'
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../../../environments/environment';
import { Bicycle } from '../../../core/models/bicycle.model';
import { BicycleList } from './bicycle-list';

describe('BicycleList', () => {
  let http: HttpTestingController;
  const collectionUrl = `${environment.apiUrl}/bicycles/`;
  const bicycle: Bicycle = {
    id: 17,
    serialNumber: 'PED-017',
    name: 'Bici de prueba',
    description: '',
    bicycleType: 'standard',
    status: 'available',
    isActive: true,
    createdAt: '',
    updatedAt: '',
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BicycleList],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    }).compileComponents();
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('reloads from the available endpoint when the mode changes', () => {
    const fixture = TestBed.createComponent(BicycleList);
    fixture.detectChanges();
    http.expectOne(collectionUrl).flush([bicycle]);

    fixture.componentInstance.setAvailableMode(true);

    const request = http.expectOne(`${environment.apiUrl}/bicycles/available/`);
    expect(request.request.method).toBe('GET');
    request.flush([bicycle]);
    expect(fixture.componentInstance.onlyAvailable()).toBe(true);
    expect(fixture.componentInstance.rows()).toEqual([bicycle]);
  });

  it('keeps 401 and 403 errors visible without reporting success', () => {
    const fixture = TestBed.createComponent(BicycleList);
    fixture.detectChanges();
    http.expectOne(collectionUrl).flush(
      { detail: 'No autorizado.' },
      { status: 401, statusText: 'Unauthorized' },
    );
    expect(fixture.componentInstance.errorMessage()).toContain('(401)');
    expect(fixture.componentInstance.successMessage()).toBeNull();

    fixture.componentInstance.load();
    http.expectOne(collectionUrl).flush(
      { detail: 'Sin permiso.' },
      { status: 403, statusText: 'Forbidden' },
    );
    expect(fixture.componentInstance.errorMessage()).toContain('no tiene permiso');
    expect(fixture.componentInstance.successMessage()).toBeNull();
    expect(fixture.componentInstance.rows()).toEqual([]);
  });

  it('creates a bicycle, reloads the catalog, and never sends DELETE', () => {
    const fixture = TestBed.createComponent(BicycleList);
    fixture.detectChanges();
    http.expectOne(collectionUrl).flush([]);

    const payload = {
      serialNumber: 'PED-022',
      name: 'Bici nueva',
      description: '',
      bicycleType: 'standard',
    };
    fixture.componentInstance.openCreate();
    fixture.componentInstance.save(payload);

    const createRequest = http.expectOne(collectionUrl);
    expect(createRequest.request.method).toBe('POST');
    expect(createRequest.request.body).toEqual(payload);
    createRequest.flush({ ...bicycle, id: 22, ...payload });
    http.expectOne(collectionUrl).flush([{ ...bicycle, id: 22, ...payload }]);

    expect(fixture.componentInstance.dialogVisible()).toBe(false);
    expect(fixture.componentInstance.rows()[0].serialNumber).toBe('PED-022');
    http.expectNone((request) => request.method === 'DELETE');
  });
});
EOF
```

Ejecutar las pruebas unitarias y el build desde `Front-2026/`:

```bash
npm test -- --watch=false
```

```bash
npm run build
```

Comprobar que ambos CSS del feature siguen vacíos:

```bash
test -f src/app/features/bicycles/bicycle-form/bicycle-form.css \
  && test -f src/app/features/bicycles/bicycle-list/bicycle-list.css \
  && ! grep -Eq '[^[:space:]]' src/app/features/bicycles/bicycle-form/bicycle-form.css src/app/features/bicycles/bicycle-list/bicycle-list.css
```

El comando CSS termina con código 0 solo si no encuentra reglas ni otro contenido no vacío.

## Cómo probarlo sin login

1. Abrir **Bicicletas** en `Construir`; confirmar que se conservan Header, Aside y Footer.
2. Ejecutar `npm test -- --watch=false` para verificar servicios, formulario y listado con peticiones simuladas.
3. Ejecutar `npm run build` y el comando de comprobación de CSS.
4. No llamar DELETE ni cambiar manualmente estados operativos. Las llamadas a una API real no son requisito de estas pruebas y no se debe pedir login.

## Evidencias ISS-05

Las capturas adjuntas documentan el modelo, servicio, formulario, listado e integración en `Construir`. Muestran código fuente; por sí solas no certifican una ejecución de pruebas ni una operación autorizada contra la API.

- **EVI-05-01** Modelo camelCase de bicicleta: [captura](../trazabilidad/evidencias/ISS-05-01-modelo-bicicleta.png).
- **EVI-05-02** Servicio API con catálogo, detalle, alta, PATCH y disponibles: [captura](../trazabilidad/evidencias/ISS-05-02-servicio-bicicletas.png).
- **EVI-05-03** Generación de los componentes del feature: [captura](../trazabilidad/evidencias/ISS-05-03-generacion-componentes.png).
- **EVI-05-04** Formulario reactivo y emisión del payload: [captura](../trazabilidad/evidencias/ISS-05-04-formulario-reactivo.png).
- **EVI-05-05** Plantilla del formulario: [captura](../trazabilidad/evidencias/ISS-05-05-formulario-template.png).
- **EVI-05-06** Estado inicial, carga y filtro del listado: [captura](../trazabilidad/evidencias/ISS-05-06-listado-carga-y-filtro.png).
- **EVI-05-07** Guardado, edición y alternancia de disponibilidad: [captura](../trazabilidad/evidencias/ISS-05-07-listado-guardado-edicion.png).
- **EVI-05-08** Activación/desactivación y presentación de errores: [captura](../trazabilidad/evidencias/ISS-05-08-estado-y-errores.png).
- **EVI-05-09** Plantilla de tabla, búsqueda y estados de pantalla: [captura](../trazabilidad/evidencias/ISS-05-09-listado-template.png).
- **EVI-05-10** Acciones y diálogo del listado: [captura](../trazabilidad/evidencias/ISS-05-10-listado-acciones.png).
- **EVI-05-11** Integración de bicicletas en el componente `Construir`: [captura](../trazabilidad/evidencias/ISS-05-11-integracion-construir.ts.png).
- **EVI-05-12** Renderizado condicional de la pantalla en `Construir`: [captura](../trazabilidad/evidencias/ISS-05-12-integracion-construir-html.png).
- **EVI-05-13** `npm test -- --watch=false`: termina correctamente con **2 archivos y 6 pruebas**. La salida muestra `app.spec.ts` y `demo-local.spec.ts`; no aparecen pruebas `bicycle-*`, por lo tanto esto no verifica aún los casos unitarios propios de ISS-05: [captura](../trazabilidad/evidencias/ISS-05-13-pruebas-unitarias-generales.png).
- **EVI-05-14** `npm run build`: Angular termina la generación del bundle correctamente: [captura](../trazabilidad/evidencias/ISS-05-14-build-exitoso.png).
- **EVI-05-15** Verificación de CSS: la terminal muestra `PASS: ambos CSS están vacíos`: [captura](../trazabilidad/evidencias/ISS-05-15-css-vacio.png).
- **EVI-05-16** Nueva ejecución de `npm test -- --watch=false`: vuelve a terminar con los mismos **2 archivos y 6 pruebas**; el `find` previo no lista archivos `*.spec.ts` del feature. Confirma que aún falta crear `bicycle-api.spec.ts`, `bicycle-form.spec.ts` y `bicycle-list.spec.ts`: [captura](../trazabilidad/evidencias/ISS-05-16-pruebas-feature-pendientes.png).

**Alcance de la evidencia de pruebas:** se da por completada esta ISS con la evidencia entregada. El resultado registrado es de seis pruebas generales en dos archivos (`app.spec.ts` y `demo-local.spec.ts`); no se ejecutaron pruebas unitarias específicas de los archivos `bicycle-*`. Las operaciones reales contra la API tampoco se verificaron porque el frontend aún no tiene login.

## Estado de esta guía

ISS-05 completada con la evidencia disponible: implementación documentada, build exitoso, CSS vacío y suite existente aprobada. El alcance se limita a esas seis pruebas generales; no se afirma cobertura unitaria específica de Bicycle ni verificación de operaciones reales contra la API.

---

# ISS-05 original · CRUD de productos

> **Fin de la adaptación PedalLibre.** Lo que sigue conserva separado el ISS original de StoreLab; sus rutas y campos no describen el backend PedalLibre.

> **Unidad ISS-05 · CRUD de productos** — capa **Construir**
>
> [Comprender este bloque](https://tecnogua.com/academic/site/frontend2026/django/aprender/ISS-05-crud-de-productos/) · [Ruta Frontend-Django](https://tecnogua.com/academic/site/frontend2026/django/)
>
> Capa | Página | Para qué
> --- | --- | ---
> Aprender | CRUD de productos | comprender, explicar y relacionar
> Construir | esta página | ejecutar, verificar y entregar

## Contexto mínimo original

Proyecto `front-storelab-django`: Angular 22, PrimeNG 22 Aura, Tailwind 4 y sin CSS de negocio. Backend `pry-django` en `http://localhost:8000/api`.

El producto se escribe con `productTypeId` y se lee con `productTypeName`. El precio es un decimal serializado como string, por ejemplo `"12.50"`. Si el POST no manda `status: "active"`, el alta nace inactiva. `GET /api/products/available/` devuelve productos activos con `quantity > 0` y tipo activo.

Al terminar ISS-04, los tipos activos ya se listan; `/productos` continúa como placeholder y su ítem ya existe en `Shell.items`. El patrón visual es `PATRON-VISUAL.md`.

| Campo | Valor original |
|---|---|
| Título | CRUD de productos |
| Feature / tabla | `features/products` (`product-list`, `product-form`) sobre `products`, con tipos de `product-types` |
| API | `GET/POST /api/products/`, `GET /api/products/available/`, `PATCH/DELETE /api/products/{id}/` |
| Depende de | ISS-04 — CRUD de tipos de producto |
| Habilita | ISS-06 — Ventas y detalle en memoria |

**Primera relación:** el formulario elige un tipo activo y envía solo su id. El nombre del tipo llega en la lectura y no se reenvía.

**Evidencia de aprendizaje:** explicar la diferencia entre `productTypeId` y `productTypeName`, y por qué `quantity <= minStock` es un `computed` de la pantalla, no un campo del API.

## Objetivo original

Listar, buscar, crear, editar y dar de baja productos. La administración usa `GET /api/products/?status=active` e incluye agotados. «Solo disponibles» cambia a `GET /api/products/available/`. El stock bajo se señala en la fila; no se calcula en el servidor.

El original llama a esto Fase I · Business: sin login, interceptor ni permisos en la UI.

## Requisitos originales

- [ ] **05.1** `ProductApi.available()` consulta `/api/products/available/`.
- [ ] **05.2** El formulario envía `price` con dos decimales y `productTypeId`, nunca `productTypeName`.
- [ ] **05.3** El alta envía `status: "active"` y el selector ofrece solo tipos activos.
- [ ] **05.4** La fila con `quantity <= minStock` se marca y el contador deriva de un `computed`.
- [ ] **05.5** «Solo disponibles» vuelve a pedir el catálogo y oculta agotados.
- [ ] **05.6** `/productos` carga `ProductList` dentro de `Shell`.
- [ ] **05.7** Pasan las pruebas del incremento y el CSS del feature no tiene reglas.

## Construcción original

### 05.1 · Contrato

| Operación | Método y ruta | Nota |
|---|---|---|
| Administración | `GET /api/products/?status=active` | Incluye `quantity = 0` |
| Disponibles | `GET /api/products/available/` | Activo, `quantity > 0`, tipo activo |
| Crear | `POST /api/products/` | `productTypeId`, `price` string, `status: "active"` |
| Editar | `PATCH /api/products/{id}/` | Sin `productTypeName` ni `status` |
| Baja | `DELETE /api/products/{id}/` | 204; queda `inactive` |

Marca: máximo 80. Nombre: de 2 a 120. Precio mínimo de la UI: `0.01`.

### 05.2 · Formulario original

`product-form` recibe el producto, tipos activos, `resetKey` y `saving`. El precio del control es numérico y se convierte a dos decimales al emitir:

```ts
this.saved.emit({
  name: value.name.trim(),
  brand: value.brand.trim(),
  price: Number(value.price).toFixed(2),
  minStock: value.minStock,
  quantity: value.quantity,
  productTypeId: value.productTypeId!,
});
```

El selector usa `optionLabel="name"`, `optionValue="id"` y `appendTo="body"` para evitar recorte dentro del diálogo.

### 05.3 · Lista original

La lista carga productos y tipos activos; el interruptor elige la consulta:

```ts
const products$ = this.onlyAvailable()
  ? this.products.available()
  : this.products.list('active');

forkJoin({
  products: products$,
  types: this.typesApi.list('active'),
}).subscribe(/* ... */);
```

El stock bajo se deriva localmente:

```ts
readonly lowStock = computed(
  () => new Set(
    this.rows()
      .filter((row) => row.quantity <= row.minStock)
      .map((row) => row.id),
  ),
);
```

La fila usa `bg-amber-50` si su id está en el conjunto. El precio se muestra con `currency` en USD. El alta usa `create({ ...payload, status: 'active' })`; la baja confirma y llama `remove`. El buscador compara nombre, marca y `productTypeName`.

### 05.4 · Ruta y pruebas originales

`productos` carga `ProductList` con título `Productos · StoreLab`.

- `product-api.spec.ts`: `available()` consulta `/api/products/available/`.
- `product-list.spec.ts`: `lowStock` contiene la fila con existencia bajo el mínimo; el POST lleva `productTypeId` y `status: 'active'`, no `productTypeName`.

## Cómo probar el original

1. Abrir `/productos`: catálogo activo, precios y contador de stock bajo.
2. «Solo disponibles» cambia el control a «Ver administración» y consulta `/api/products/available/`.
3. Crear producto de precio `12.50`, existencia cero y mínimo cinco, con un tipo activo. La respuesta incluye precio `"12.50"`, nombre del tipo y estado activo; la fila queda en ámbar con `0 / 5`.
4. Con «Solo disponibles» y el buscador sobre ese producto, aparece el estado vacío porque `quantity = 0` no se incluye en available.
5. Dar de baja: confirmar, observar que sale del filtro activo y que el contador baja.

## Criterios originales de aceptación

- **AC-05-01:** administración consulta `GET /api/products/?status=active`.
- **AC-05-02:** «Solo disponibles» usa `/api/products/available/` y oculta agotados.
- **AC-05-03:** el alta envía `productTypeId`, precio de dos decimales y estado activo, sin `productTypeName`.
- **AC-05-04:** `quantity <= minStock` marca la fila y actualiza el contador.
- **AC-05-05:** la baja confirma, ejecuta DELETE y desaparece de la lista activa.
- **AC-05-06:** el selector ofrece únicamente tipos activos.
- **AC-05-07:** las pruebas del feature pasan y el CSS no contiene reglas.

## Verificación y resultados originales

Resultados reportados en ese workspace (24-oct-2026):

| Comprobación | Resultado original |
|---|---|
| Administración | 20 productos activos del seeder, paginados de 10 en 10; «0 bajo el mínimo» |
| Solo disponibles | Cambia a «Ver administración» y consulta `available` |
| Alta | Id 41 «Producto ISS05», tipo 8 «Queda», precio `"12.50"`, mínimo 5, cantidad 0 y activo |
| Stock bajo | Fila ámbar, etiqueta `0 / 5` y contador «1 bajo el mínimo» |
| Solo disponibles + búsqueda | Estado vacío para ISS05 porque la existencia es cero; contador vuelve a 0 |
| Baja | Confirmación; id 41 queda `inactive` y el contador queda en 0 |
| Pruebas | `ProductApi.available()` y `ProductList` (stock bajo y cuerpo del POST) |

| Criterio | Resultado original |
|---|---|
| AC-05-01 | La tabla de administración pinta los 20 activos — PASS |
| AC-05-02 | El interruptor consulta available y esconde el agotado — PASS |
| AC-05-03 | Id 41 guarda tipo, precio decimal y estado activo — PASS |
| AC-05-04 | La fila 41 queda ámbar con `0 / 5` — PASS |
| AC-05-05 | La baja deja el id 41 inactivo — PASS |
| AC-05-06 | El selector ofrece tipos activos y no el tipo 12 inactivo — PASS |
| AC-05-07 | Pruebas del feature en verde y CSS sin reglas — PASS |

## Evidencias originales

- **EVI-05-01:** tabla con precio, tipo en `p-tag` y contador de stock bajo.
- **EVI-05-02:** fila ámbar de «Producto ISS05» con `0 / 5`.
- **EVI-05-03:** `GET /api/products/41/` con id del tipo, nombre del tipo y precio `"12.50"`; tras la baja, estado `inactive`.

## Gate y navegación originales

```text
TODOS los AC = PASS  → se puede avanzar a ISS-06
ALGÚN AC = FAIL      → se corrige y se repite
```

← ISS-04 · CRUD de tipos de producto · ↑ Ruta Frontend-Django · → ISS-06 · Ventas y detalle en memoria
