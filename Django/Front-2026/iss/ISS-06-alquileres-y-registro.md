---
title: "ISS-06 · Alquileres y registro PedalLibre"
project: "Frontend de PedalLibre"
layer: "Construir"
depends_on: "Modelos y servicios de ISS-02; confirmar el alcance de ISS-05 antes de iniciar"
status: "Cerrada con alcance documentado; bundle de pruebas y seis pruebas generales aprobados; pruebas específicas de alquileres pendientes"
---

# ISS-06 · Alquileres y registro PedalLibre

> **Proyecto:** Frontend PedalLibre (`Front-2026/`).
> **Capa:** Construir.
> **Adaptación:** el backend no tiene ventas ni productos de StoreLab. El flujo de negocio equivalente para este proyecto es consultar y registrar **alquileres** con bicicletas y tarifas.
> **Importante:** la aplicación todavía no tiene login. No pedir autenticación ni credenciales para estas pruebas; usar respuestas HTTP simuladas. Si una llamada real devuelve 401/403, mostrar el error sin cambiar ni eludir RBAC.

## Contexto de PedalLibre

En el frontend ya existen los modelos y servicios de clientes, bicicletas y tarifas creados en ISS-02. El menú es local dentro de `Construir`; la opción **Tarifas** se integró en ISS-04. El backend actual no define los recursos `sales`, `products` ni `/api/sales/`.

El recurso real es `Rental`. La lectura y la escritura también tienen formas distintas, pero el contrato no es el del ISS original:

- La lectura usa `client`, `bicycle`, `rate`, estaciones, horas, estado, total e historial de eventos.
- El registro usa `clientId`, `bicycleId`, `rateId` y `startStationId`, o `reservationId` con `rateId`.
- El backend crea el alquiler como `active`, registra el evento de inicio, desancla la bicicleta y cambia su estado a `rented`.
- El total empieza en cero y el backend lo calcula cuando se finaliza el alquiler. Esta ISS no debe mostrar un importe estimado como si fuera el total definitivo.

## Objetivo

Preparar una pantalla **Alquileres** dentro de `Construir` para consultar alquileres y registrar uno desde un formulario en memoria. El formulario no debe llamar a la API; el componente de lista organiza catálogos, envía el payload y vuelve a cargar los datos tras una respuesta 201.

El borrador de alquiler no tiene líneas de producto, cantidades, descuentos ni fecha de venta: se selecciona una bicicleta, una tarifa y, según el rol, el cliente y la estación o una reserva propia. No se implementa en esta ISS la finalización del alquiler ni el cálculo de su cobro; el endpoint de finalización queda para el incremento de detalle que se defina después.

## Contrato real de la API

La raíz del backend es `/api`.

| Operación | Método y ruta | Resultado |
|---|---|---|
| Listar alquileres | `GET /api/rentals/` | Arreglo de objetos de lectura, con `events` |
| Obtener alquiler | `GET /api/rentals/{id}/` | Objeto de lectura, con `events` |
| Registrar sin reserva | `POST /api/rentals/` | 201; el body necesita `clientId`, `bicycleId`, `rateId` y `startStationId` |
| Registrar desde reserva | `POST /api/rentals/` | 201; el body necesita `reservationId` y `rateId`, sin combinar los demás identificadores |
| Bicicletas disponibles | `GET /api/bicycles/available/` | Arreglo de bicicletas disponibles y elegibles |
| Clientes | `GET /api/clients/` | Arreglo de clientes; filtrar `isActive` en el cliente, ya que el endpoint no tiene filtro `status=active` |
| Tarifas | `GET /api/rates/` | Arreglo de tarifas; seleccionar tarifas activas y vigentes |
| Estaciones | `GET /api/stations/` | Arreglo de estaciones; seleccionar estaciones activas |
| Reservas del usuario | `GET /api/reservations/` | Arreglo de reservas; el backend limita las de un rol `CLIENTE` a sus propias reservas |

El renderer/parser camelCase del backend traduce las claves JSON de entrada y salida. En la frontera HTTP los campos son camelCase, por ejemplo `startStationId`, `startedAt`, `totalAmount` e `isActive`. Los modelos actuales de catálogo del frontend declaran varios campos en `snake_case`; no se debe tipar directamente una respuesta camelCase como si tuviera esas claves. Definir DTOs que reflejen el JSON real y mapearlos a los modelos de vista existentes, o alinear los tipos de forma coherente sin modificar el contrato del servidor.

### Lectura

El serializer de lectura retorna estos campos:

```ts
export interface RentalEvent {
  id: number;
  rental: number;
  eventType: string;
  description: string | null;
  eventAt: string;
  quantity: number | null;
  status: string;
}

export interface Rental {
  id: number;
  reservation: number | null;
  client: number;
  bicycle: number;
  rate: number;
  startStation: number | null;
  endStation: number | null;
  startedAt: string;
  endedAt: string | null;
  status: string;
  totalAmount: string;
  observations: string;
  events: RentalEvent[];
}
```

`client`, `bicycle`, `rate` y las estaciones son identificadores; no vienen como `clientName` ni como objetos anidados. Para mostrar nombres, reutilizar los catálogos cargados y resolverlos por id. Si un nombre no está disponible, mostrar una etiqueta segura como `Cliente #<id>` o `Bicicleta #<id>`.

### Escritura

Para un usuario de operación autorizado, el alta directa es:

```ts
export interface RentalRegisterPayload {
  clientId: number;
  bicycleId: number;
  rateId: number;
  startStationId: number;
}
```

Un alquiler iniciado desde una reserva es:

```ts
export interface RentalFromReservationPayload {
  reservationId: number;
  rateId: number;
}
```

No enviar ambos formatos juntos. `startedAt`, `status`, `totalAmount`, `endedAt` y los eventos son calculados o controlados por el servidor; no deben incluirse en el POST. Una respuesta 201 de creación usa el serializer `RentalSerializer`, que no incluye `events`; al recargar la lista se obtiene la forma completa de lectura.

### Reglas que impone el backend

- La bicicleta debe estar activa, disponible, anclada en una estación activa y sin mantenimiento vigente.
- La tarifa debe estar activa, dentro de su vigencia, tener precio positivo y unidad `minute`, `hour` o `day` (también se aceptan sus variantes `per_minute`, `per_hour`, `per_day`).
- La estación debe estar activa y coincidir con la ubicación de la bicicleta. El contrato de `BicycleSerializer` no expone la estación/anclaje actual; por eso el formulario no puede validar esa relación localmente y el backend puede rechazar una estación no coincidente con 400.
- El registro es transaccional. En caso de error de validación no debe quedar creado parcialmente el alquiler ni cambiar la bicicleta.
- El servidor pone el alquiler en `active`, crea el evento `started`, desancla la bicicleta y la cambia a `rented`.
- `totalAmount` es `0.00` mientras está activo; al finalizar, el backend calcula el importe según duración y tarifa.
- El serializer permite un modo de reserva: `reservationId` y `rateId` únicamente. No se debe mezclar `reservationId` con `clientId`, `bicycleId` o `startStationId`.
- Para el rol `CLIENTE`, el registro requiere una reserva propia. La pantalla debe ofrecer las reservas elegibles de ese usuario y no permitir registrar un alquiler para otro cliente. Otros roles deben tener el permiso explícito para registrar alquileres.

## Requisitos para PedalLibre

- [ ] **06.1** Los tipos de lectura `Rental`/`RentalEvent` coinciden con `RentalReadSerializer`; el tipo de escritura no se confunde con la respuesta.
- [ ] **06.2** El servicio de alquiler usa `/api/rentals/` con barra final y expone listado, detalle y registro POST; no inventa PATCH/DELETE.
- [ ] **06.3** El formulario guarda su borrador en signals y valida las selecciones obligatorias antes de emitir.
- [ ] **06.4** El flujo de operación ofrece clientes activos, bicicletas disponibles, tarifas activas/vigentes y estación correcta.
- [ ] **06.5** Para rol `CLIENTE`, el payload de registro usa solo `reservationId` y `rateId` de una reserva propia elegible.
- [ ] **06.6** Una respuesta 201 recarga alquileres y bicicletas disponibles; los errores 400/401/403/409 se mantienen visibles y no cierran el formulario como éxito.
- [ ] **06.7** La pantalla se integra como **Alquileres** en el `Construir` existente, sin reemplazar Header, Aside ni Footer.
- [ ] **06.8** La lista resuelve los nombres de catálogos por id y presenta `totalAmount` de alquiler activo como valor no definitivo.
- [ ] **06.9** Pruebas del feature y build se ejecutan cuando se autorice; el CSS del feature no incorpora reglas de negocio.

## Construcción adaptada

### 06.1 · Confirmar los recursos existentes

Antes de crear archivos, revisar `ClientApi`, `BicycleApi`, `RateApi`, los modelos de ISS-02 y los componentes de `Construir`. Reutilizar esos servicios y modelos. No crear `ProductApi`, `SaleApi` ni interfaces `Sale` de StoreLab en PedalLibre.

Desde `Front-2026/`, prepara primero las carpetas del feature. Esto permite crear `rental-api.ts` incluso antes de generar los componentes:

```bash
mkdir -p src/app/features/rentals/rental-form src/app/features/rentals/rental-list
```

Después, crear DTOs de lectura y escritura que coincidan con el JSON camelCase:

```bash
cat > src/app/core/models/rental.model.ts <<'EOF'
export interface RentalEvent {
  id: number;
  rental: number;
  eventType: string;
  description: string | null;
  eventAt: string;
  quantity: number | null;
  status: string;
}

export interface Rental {
  id: number;
  reservation: number | null;
  client: number;
  bicycle: number;
  rate: number;
  startStation: number | null;
  endStation: number | null;
  startedAt: string;
  endedAt: string | null;
  status: string;
  totalAmount: string;
  observations: string;
  events: RentalEvent[];
}

export type RentalRegistrationResult = Omit<Rental, 'events'>;

export interface RentalClientOption {
  id: number;
  firstName: string;
  lastName: string;
  isActive: boolean;
}

export interface RentalRateOption {
  id: number;
  name: string;
  price: string;
  billingUnit: string;
  validFrom: string | null;
  validUntil: string | null;
  isActive: boolean;
}

export interface RentalStationOption {
  id: number;
  name: string;
  status: string;
  isActive: boolean;
}

export interface RentalReservationOption {
  id: number;
  client: number;
  bicycle: number | null;
  station: number | null;
  expiresAt: string | null;
  status: string;
}

export type RentalRegistrationPayload =
  | { reservationId: number; rateId: number }
  | {
      clientId: number;
      bicycleId: number;
      rateId: number;
      startStationId: number;
    };
EOF
```

Al pegar un bloque, copia desde `cat > ... <<'EOF'` hasta la línea final `EOF`, sin incluir las comillas invertidas que delimitan el bloque Markdown. `EOF` debe quedar solo en su propia línea; espera a que vuelva el prompt antes de pegar el siguiente comando.

Crear `RentalApi` con todas las rutas que necesita el listado y el diálogo. `available()` del servicio de bicicletas de ISS-02 sigue disponible; aquí se tipa la misma URL con el DTO camelCase actualizado:

```bash
cat > src/app/features/rentals/rental-api.ts <<'EOF'
import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Bicycle } from '../../core/models/bicycle.model';
import {
  Rental,
  RentalClientOption,
  RentalRateOption,
  RentalRegistrationPayload,
  RentalRegistrationResult,
  RentalReservationOption,
  RentalStationOption,
} from '../../core/models/rental.model';

@Injectable({ providedIn: 'root' })
export class RentalApi {
  private readonly http = inject(HttpClient);
  private readonly base = environment.apiUrl;

  list(): Observable<Rental[]> {
    return this.http.get<Rental[]>(`${this.base}/rentals/`);
  }

  get(id: number): Observable<Rental> {
    return this.http.get<Rental>(`${this.base}/rentals/${id}/`);
  }

  register(payload: RentalRegistrationPayload): Observable<RentalRegistrationResult> {
    return this.http.post<RentalRegistrationResult>(`${this.base}/rentals/`, payload);
  }

  clients(): Observable<RentalClientOption[]> {
    return this.http.get<RentalClientOption[]>(`${this.base}/clients/`);
  }

  availableBicycles(): Observable<Bicycle[]> {
    return this.http.get<Bicycle[]>(`${this.base}/bicycles/available/`);
  }

  rates(): Observable<RentalRateOption[]> {
    return this.http.get<RentalRateOption[]>(`${this.base}/rates/`);
  }

  stations(): Observable<RentalStationOption[]> {
    return this.http.get<RentalStationOption[]>(`${this.base}/stations/`);
  }

  reservations(): Observable<RentalReservationOption[]> {
    return this.http.get<RentalReservationOption[]>(`${this.base}/reservations/`);
  }
}
EOF

```

#### Error al crear `rental-api.ts`

Si Bash muestra:

```text
bash: src/app/features/rentals/rental-api.ts: No such file or directory
```

el directorio padre `src/app/features/rentals/` todavía no existe. El redireccionamiento `cat > ruta` crea el archivo, pero no crea las carpetas. Desde `Front-2026/`, ejecutar el `mkdir -p` indicado arriba y volver a pegar completo el bloque de `rental-api.ts`, desde `cat` hasta `EOF`. No pegues solo el fragmento restante del contenido: si la redirección falló, ese fragmento puede ejecutarse como comandos de shell y producir más errores.

La primera captura del error solo mostraba `rental.model.ts`; las capturas posteriores EVI-06-02 a EVI-06-10 sí muestran la creación del servicio, formulario, listado e integración en `Construir`.

### 06.2 · Crear los componentes

Desde `Front-2026/`, generar la lista y el formulario una sola vez:

```bash
npx ng generate component features/rentals/rental-list --skip-tests --defaults
npx ng generate component features/rentals/rental-form --skip-tests --defaults
```

Después de generar los componentes, el formulario siguiente recibe opciones y estado, reinicia su borrador al cambiar `resetKey` y emite exactamente una de las dos formas permitidas del payload:

```bash
cat > src/app/features/rentals/rental-form/rental-form.ts <<'EOF'
import { Component, effect, input, output, signal } from '@angular/core';
import { Bicycle } from '../../../core/models/bicycle.model';
import {
  RentalClientOption,
  RentalRateOption,
  RentalRegistrationPayload,
  RentalReservationOption,
  RentalStationOption,
} from '../../../core/models/rental.model';

@Component({
  selector: 'app-rental-form',
  imports: [],
  templateUrl: './rental-form.html',
  styleUrl: './rental-form.css',
})
export class RentalForm {
  readonly mode = input<'direct' | 'reservation'>('direct');
  readonly clients = input<RentalClientOption[]>([]);
  readonly bicycles = input<Bicycle[]>([]);
  readonly rates = input<RentalRateOption[]>([]);
  readonly stations = input<RentalStationOption[]>([]);
  readonly reservations = input<RentalReservationOption[]>([]);
  readonly saving = input(false);
  readonly resetKey = input(0);
  readonly saved = output<RentalRegistrationPayload>();
  readonly cancelled = output<void>();

  readonly clientId = signal<number | null>(null);
  readonly bicycleId = signal<number | null>(null);
  readonly rateId = signal<number | null>(null);
  readonly stationId = signal<number | null>(null);
  readonly reservationId = signal<number | null>(null);
  readonly validationMessage = signal<string | null>(null);

  constructor() {
    effect(() => {
      this.resetKey();
      this.clientId.set(null);
      this.bicycleId.set(null);
      this.rateId.set(null);
      this.stationId.set(null);
      this.reservationId.set(null);
      this.validationMessage.set(null);
    });
  }

  onClientChange(event: Event): void {
    this.clientId.set(this.readId(event));
  }

  onBicycleChange(event: Event): void {
    this.bicycleId.set(this.readId(event));
  }

  onRateChange(event: Event): void {
    this.rateId.set(this.readId(event));
  }

  onStationChange(event: Event): void {
    this.stationId.set(this.readId(event));
  }

  onReservationChange(event: Event): void {
    this.reservationId.set(this.readId(event));
  }

  submit(): void {
    const rateId = this.rateId();
    if (rateId === null) {
      this.validationMessage.set('Selecciona una tarifa vigente.');
      return;
    }

    if (this.mode() === 'reservation') {
      const reservationId = this.reservationId();
      if (reservationId === null) {
        this.validationMessage.set('Selecciona una reserva propia elegible.');
        return;
      }
      this.saved.emit({ reservationId, rateId });
      return;
    }

    const clientId = this.clientId();
    const bicycleId = this.bicycleId();
    const startStationId = this.stationId();
    if (clientId === null || bicycleId === null || startStationId === null) {
      this.validationMessage.set('Selecciona cliente, bicicleta y estación.');
      return;
    }
    this.saved.emit({ clientId, bicycleId, rateId, startStationId });
  }

  private readId(event: Event): number | null {
    if (!(event.target instanceof HTMLSelectElement) || !event.target.value) return null;
    const value = Number(event.target.value);
    return Number.isInteger(value) && value > 0 ? value : null;
  }
}
EOF
```

```bash
cat > src/app/features/rentals/rental-form/rental-form.html <<'EOF'
<form class="grid gap-4" (submit)="$event.preventDefault(); submit()">
  @if (mode() === 'reservation') {
    <label class="grid gap-1">
      Reserva propia *
      <select class="rounded border border-slate-300 bg-white p-2" (change)="onReservationChange($event)">
        <option value="">Selecciona una reserva</option>
        @for (reservation of reservations(); track reservation.id) {
          <option [value]="reservation.id">
            Reserva #{{ reservation.id }} · bicicleta #{{ reservation.bicycle }} · {{ reservation.status }}
          </option>
        }
      </select>
    </label>
  } @else {
    <label class="grid gap-1">
      Cliente *
      <select class="rounded border border-slate-300 bg-white p-2" (change)="onClientChange($event)">
        <option value="">Selecciona un cliente</option>
        @for (client of clients(); track client.id) {
          <option [value]="client.id">{{ client.firstName }} {{ client.lastName }}</option>
        }
      </select>
    </label>

    <label class="grid gap-1">
      Bicicleta disponible *
      <select class="rounded border border-slate-300 bg-white p-2" (change)="onBicycleChange($event)">
        <option value="">Selecciona una bicicleta</option>
        @for (bicycle of bicycles(); track bicycle.id) {
          <option [value]="bicycle.id">{{ bicycle.serialNumber }} · {{ bicycle.name || bicycle.bicycleType }}</option>
        }
      </select>
    </label>

    <label class="grid gap-1">
      Estación de inicio *
      <select class="rounded border border-slate-300 bg-white p-2" (change)="onStationChange($event)">
        <option value="">Selecciona una estación</option>
        @for (station of stations(); track station.id) {
          <option [value]="station.id">{{ station.name }}</option>
        }
      </select>
    </label>
  }

  <label class="grid gap-1">
    Tarifa vigente *
    <select class="rounded border border-slate-300 bg-white p-2" (change)="onRateChange($event)">
      <option value="">Selecciona una tarifa</option>
      @for (rate of rates(); track rate.id) {
        <option [value]="rate.id">{{ rate.name }} · {{ rate.price }} / {{ rate.billingUnit }}</option>
      }
    </select>
  </label>

  @if (validationMessage()) {
    <p role="alert" class="text-sm text-red-700">{{ validationMessage() }}</p>
  }

  <p class="text-sm text-slate-600">
    El costo final se calcula al finalizar el alquiler; aquí no se estima el total.
  </p>

  <div class="flex justify-end gap-2 border-t border-slate-200 pt-4">
    <button class="rounded border border-slate-300 px-4 py-2" type="button" (click)="cancelled.emit()">Cancelar</button>
    <button class="rounded bg-blue-700 px-4 py-2 text-white disabled:opacity-50" type="submit" [disabled]="saving()">
      {{ saving() ? 'Registrando…' : 'Registrar alquiler' }}
    </button>
  </div>
</form>
EOF
```

```bash
cat > src/app/features/rentals/rental-form/rental-form.css <<'EOF'
EOF
```

```bash
cat > src/app/features/rentals/rental-list/rental-list.css <<'EOF'
EOF
```

### 06.3 · Borrador de registro

El borrador es estado de interfaz, no un `FormGroup` requerido por el dominio. Puede mantener signals para:

- modo de registro: directo o desde reserva;
- cliente, bicicleta, tarifa y estación seleccionados, cuando el rol permite alta directa;
- reserva propia y tarifa seleccionadas, cuando el rol es `CLIENTE`;
- observaciones opcionales si se acuerda agregarlas al contrato;
- estado de guardado y error de la petición.

Antes de emitir, valida que todos los ids requeridos estén seleccionados. Construye uno de los dos payloads permitidos; nunca envía un objeto combinado. No calcula importe final, descuentos, cantidad de bicicleta ni hora de inicio en el cliente. La hora se genera en el backend.

`submit()` no debe limpiar ni cerrar el diálogo antes de recibir respuesta satisfactoria. Si POST responde 400, conservar las selecciones y mostrar los errores de validación del backend en el formulario. Los errores 401/403 deben explicar que falta sesión o permiso, sin degradar el control de acceso.

### 06.4 · Lista y recarga

Al entrar en la pantalla, cargar `GET /api/rentals/` y los catálogos necesarios para representar nombres. Para el formulario directo, cargar también clientes, bicicletas disponibles, tarifas y estaciones. Evitar pedir recursos no usados por el rol actual.

El siguiente componente muestra el flujo base para un operador. Como el frontend aún no implementa login, no se debe pedir una sesión ni agregar autenticación para probarlo: mantener `mode` en `direct` y probar `reservation` con reservas simuladas. Cuando exista autenticación, conectar `mode` al rol; el servidor sigue siendo la autoridad de permisos.

```bash
cat > src/app/features/rentals/rental-list/rental-list.ts <<'EOF'
import { DatePipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { Component, computed, inject, signal } from '@angular/core';
import { forkJoin } from 'rxjs';
import { Bicycle } from '../../../core/models/bicycle.model';
import {
  Rental,
  RentalClientOption,
  RentalRateOption,
  RentalRegistrationPayload,
  RentalReservationOption,
  RentalStationOption,
} from '../../../core/models/rental.model';
import { RentalApi } from '../rental-api';
import { RentalForm } from '../rental-form/rental-form';

@Component({
  selector: 'app-rental-list',
  imports: [DatePipe, RentalForm],
  templateUrl: './rental-list.html',
  styleUrl: './rental-list.css',
})
export class RentalList {
  private readonly api = inject(RentalApi);
  readonly rows = signal<Rental[]>([]);
  readonly clients = signal<RentalClientOption[]>([]);
  readonly bicycles = signal<Bicycle[]>([]);
  readonly rates = signal<RentalRateOption[]>([]);
  readonly stations = signal<RentalStationOption[]>([]);
  readonly reservations = signal<RentalReservationOption[]>([]);
  readonly mode = signal<'direct' | 'reservation'>('direct');
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly dialogVisible = signal(false);
  readonly resetKey = signal(0);
  readonly errorMessage = signal<string | null>(null);
  readonly successMessage = signal<string | null>(null);
  readonly activeCount = computed(() => this.rows().filter((row) => row.status === 'active').length);

  constructor() {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.errorMessage.set(null);
    if (this.mode() === 'reservation') {
      forkJoin({
        rentals: this.api.list(),
        rates: this.api.rates(),
        reservations: this.api.reservations(),
      }).subscribe({
        next: (data) => {
          this.rows.set(data.rentals);
          this.rates.set(data.rates.filter((rate) =>
            rate.isActive
            && Number(rate.price) > 0
            && ['minute', 'per_minute', 'hour', 'per_hour', 'day', 'per_day']
              .includes(rate.billingUnit.trim().toLowerCase())
            && this.isRateCurrent(rate),
          ));
          this.reservations.set(this.eligibleReservations(data.reservations));
          this.clients.set([]);
          this.bicycles.set([]);
          this.stations.set([]);
          this.loading.set(false);
        },
        error: (error: unknown) => this.failLoad(error),
      });
      return;
    }

    forkJoin({
      rentals: this.api.list(),
      clients: this.api.clients(),
      bicycles: this.api.availableBicycles(),
      rates: this.api.rates(),
      stations: this.api.stations(),
    }).subscribe({
      next: (data) => {
        this.rows.set(data.rentals);
        this.clients.set(data.clients.filter((client) => client.isActive));
        this.bicycles.set(data.bicycles);
        this.rates.set(data.rates.filter((rate) =>
          rate.isActive
          && Number(rate.price) > 0
          && ['minute', 'per_minute', 'hour', 'per_hour', 'day', 'per_day']
            .includes(rate.billingUnit.trim().toLowerCase())
          && this.isRateCurrent(rate),
        ));
        this.stations.set(data.stations.filter((station) => station.isActive && station.status === 'active'));
        this.reservations.set([]);
        this.loading.set(false);
      },
      error: (error: unknown) => this.failLoad(error),
    });
  }

  private eligibleReservations(reservations: RentalReservationOption[]): RentalReservationOption[] {
    return reservations.filter((reservation) =>
      ['pending', 'confirmed'].includes(reservation.status)
      && reservation.bicycle !== null
      && reservation.station !== null
      && reservation.expiresAt !== null
      && new Date(reservation.expiresAt).getTime() > Date.now(),
    );
  }

  private failLoad(error: unknown): void {
    this.rows.set([]);
    this.errorMessage.set(this.describeError(error));
    this.loading.set(false);
  }

  openCreate(): void {
    this.errorMessage.set(null);
    this.successMessage.set(null);
    this.resetKey.update((key) => key + 1);
    this.dialogVisible.set(true);
  }

  closeForm(): void {
    if (!this.saving()) this.dialogVisible.set(false);
  }

  clientName(id: number): string {
    const client = this.clients().find((row) => row.id === id);
    return client ? `${client.firstName} ${client.lastName}` : `Cliente #${id}`;
  }

  bicycleName(id: number): string {
    const bicycle = this.bicycles().find((row) => row.id === id);
    return bicycle?.name || bicycle?.serialNumber || `Bicicleta #${id}`;
  }

  rateName(id: number): string {
    return this.rates().find((row) => row.id === id)?.name ?? `Tarifa #${id}`;
  }

  stationName(id: number | null): string {
    if (id === null) return '—';
    return this.stations().find((row) => row.id === id)?.name ?? `Estación #${id}`;
  }

  save(payload: RentalRegistrationPayload): void {
    this.saving.set(true);
    this.errorMessage.set(null);
    this.successMessage.set(null);
    this.api.register(payload).subscribe({
      next: (rental) => {
        this.saving.set(false);
        this.dialogVisible.set(false);
        this.successMessage.set(`Alquiler #${rental.id} registrado. El total se calculará al finalizar.`);
        this.load();
      },
      error: (error: unknown) => {
        this.saving.set(false);
        this.errorMessage.set(this.describeError(error));
      },
    });
  }

  private isRateCurrent(rate: RentalRateOption): boolean {
    const now = new Date();
    const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    return (!rate.validFrom || rate.validFrom <= today)
      && (!rate.validUntil || rate.validUntil >= today);
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
cat > src/app/features/rentals/rental-list/rental-list.html <<'EOF'
<section class="grid gap-5">
  <header class="flex flex-wrap items-end justify-between gap-3">
    <div>
      <h1 class="text-2xl font-semibold">Alquileres</h1>
      <p class="mt-1 text-sm text-slate-600">{{ activeCount() }} activos · el total se liquida al finalizar</p>
    </div>
    <button class="rounded bg-blue-700 px-4 py-2 font-medium text-white" type="button"
      (click)="openCreate()">Registrar alquiler</button>
  </header>

  @if (errorMessage()) {
    <p role="alert" class="rounded border border-red-300 bg-red-50 p-3 text-red-800">{{ errorMessage() }}</p>
  }
  @if (successMessage()) {
    <p role="status" class="rounded border border-green-300 bg-green-50 p-3 text-green-800">{{ successMessage() }}</p>
  }
  @if (loading()) {
    <p role="status">Cargando alquileres…</p>
  } @else if (rows().length === 0 && !errorMessage()) {
    <p class="rounded border border-slate-200 bg-white p-6 text-slate-600">Aún no hay alquileres.</p>
  } @else if (rows().length > 0) {
    <div class="overflow-x-auto rounded border border-slate-200 bg-white">
      <table class="w-full min-w-[900px] text-left text-sm">
        <thead class="bg-slate-100 text-slate-700">
          <tr>
            <th class="p-3">Id</th><th class="p-3">Cliente</th><th class="p-3">Bicicleta</th>
            <th class="p-3">Tarifa</th><th class="p-3">Estación inicial</th>
            <th class="p-3">Inicio</th><th class="p-3">Estado</th><th class="p-3">Total</th>
          </tr>
        </thead>
        <tbody>
          @for (rental of rows(); track rental.id) {
            <tr class="border-t border-slate-200">
              <td class="p-3">#{{ rental.id }}</td>
              <td class="p-3">{{ clientName(rental.client) }}</td>
              <td class="p-3">{{ bicycleName(rental.bicycle) }}</td>
              <td class="p-3">{{ rateName(rental.rate) }}</td>
              <td class="p-3">{{ stationName(rental.startStation) }}</td>
              <td class="p-3">{{ rental.startedAt | date:'short' }}</td>
              <td class="p-3">{{ rental.status }}</td>
              <td class="p-3">
                @if (rental.status === 'active') {
                  {{ rental.totalAmount }} · provisional
                } @else {
                  {{ rental.totalAmount }}
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
        aria-modal="true" aria-labelledby="rental-dialog-title" (click)="$event.stopPropagation()">
        <h2 id="rental-dialog-title" class="mb-4 text-xl font-semibold">Registrar alquiler</h2>
        @if (errorMessage()) {
          <p role="alert" class="mb-4 rounded border border-red-300 bg-red-50 p-3 text-red-800">{{ errorMessage() }}</p>
        }
        <app-rental-form [mode]="mode()" [clients]="clients()" [bicycles]="bicycles()"
          [rates]="rates()" [stations]="stations()" [reservations]="reservations()"
          [saving]="saving()" [resetKey]="resetKey()" (saved)="save($event)"
          (cancelled)="closeForm()" />
      </section>
    </div>
  }
</section>
EOF
```

Tras el POST 201:

1. cerrar el diálogo y mostrar confirmación;
2. volver a pedir `GET /api/rentals/`;
3. volver a pedir `GET /api/bicycles/available/`, pues la bicicleta registrada debe dejar de ofrecerse como disponible.

Si cualquier GET falla, conservar un mensaje visible y no representar una respuesta fallida como lista correcta. Resolver nombres desde mapas indexados por id; el endpoint de lectura de alquileres no devuelve nombres de cliente, bicicleta ni tarifa.

La tabla puede mostrar id, cliente, bicicleta, tarifa, estación de inicio, inicio, estado y total. Para un alquiler activo, etiquetar el total como provisional/no liquidado (el valor leído inicialmente es cero). Mostrar el historial `events` en el detalle del siguiente incremento, no inventar campos de venta ni historial de líneas.

### 06.5 · Integración en `Construir`

Cada comando reemplaza un archivo completo de `Construir`. El HTML conserva las pantallas de clientes, bicicletas y tarifas, e incluye explícitamente `@else if (title() === 'Bicicletas')` con `<app-bicycle-list />`, además de agregar alquileres:

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
import { RentalList } from '../rentals/rental-list/rental-list';

@Component({
  imports: [Aside, BicycleList, ClientList, DrawerModule, Footer, Header, RateList, RentalList],
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
    { label: 'Alquileres', command: () => this.seleccionar('Alquileres') },
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
      } @else if (title() === 'Alquileres') {
        <app-rental-list />
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

La ruta de detalle, si el siguiente ISS la requiere, debe nombrarse con el dominio real (`/alquileres/:id`) y documentarse en la ISS posterior. No enlazar una ruta que todavía no existe ni presentar el comodín como una pantalla de detalle.

En el ejemplo, `RentalList.mode` está en modo directo para las pruebas actuales. Cuando se implemente autenticación en otra ISS, conectar esa señal al rol y usar `reservation` para `CLIENTE`; no implementar ni solicitar login como parte de esta ISS. La protección real siempre corresponde al backend.

### 06.6 · Pruebas propuestas

- El servicio comprueba `/api/rentals/` con barra final, GET de lista/detalle y POST con cada forma válida de payload usando peticiones simuladas; no se necesita login.
- El formulario directo requiere cliente, bicicleta, tarifa y estación; desde reserva solo admite `reservationId` y `rateId`.
- El formulario no emite campos de lectura como `events`, `startedAt` o `totalAmount`.
- Una respuesta 400 deja abierto el formulario y conserva el borrador.
- Una respuesta 201 recarga alquileres y la lista de bicicletas disponibles.
- Se muestra correctamente el nombre resuelto por id y el estado de total no liquidado en alquiler activo.
- Respuestas 401/403 simuladas muestran error y no crean una fila de éxito.

No pedir login ni credenciales. El build y las pruebas unitarias locales no necesitan sesión; no exigir pruebas contra la API real para completar esta ISS mientras el frontend no tenga autenticación.

## Cómo verificar sin login

1. Abrir **Alquileres** en `Construir` y confirmar que se conservan Header, Aside y Footer.
2. Con `HttpTestingController` o mocks, comprobar las peticiones de listado y catálogos, el payload directo y el payload desde reserva.
3. Simular 201 para verificar que se actualiza la lista; simular 400 y 401/403 para comprobar que se muestra el error sin reportar éxito.
4. Verificar que `totalAmount: "0.00"` en el alquiler activo no se presenta como el cobro final.
5. No ejecutar altas contra la API real: requieren autorización del backend y no son necesarias para validar el feature sin login.

### Resultado de pruebas recibido (01-nov-2026)

La captura EVI-06-11 muestra que `npm test -- --watch=false` compiló el bundle de pruebas y terminó con **2 archivos y 6 pruebas aprobadas**. Los archivos visibles son `app.spec.ts` (2 pruebas) y `demo-local.spec.ts` (4 pruebas); no son pruebas específicas de alquileres. Esta evidencia tampoco corresponde a `npm run build` ni a llamadas reales a la API.

La ISS queda cerrada con este alcance documentado. La verificación unitaria de `RentalApi`, `RentalForm` y `RentalList` con `HttpTestingController` o mocks sigue pendiente; no se afirma que esos casos hayan pasado.

## Estado de esta guía

### Evidencias ISS-06

Las siguientes capturas documentan código fuente del modelo, servicio, formulario, listado e integración. No prueban por sí solas un build, la ejecución de pruebas unitarias ni operaciones reales contra la API.

- **EVI-06-01** Modelo camelCase `Rental`, eventos y opciones de catálogo: [captura](../trazabilidad/evidencias/ISS-06-01-modelo-rental.png).
- **EVI-06-02** `RentalApi` con listado, detalle, registro y catálogos: [captura](../trazabilidad/evidencias/ISS-06-02-rental-api.png).
- **EVI-06-03** Inputs y signals del formulario de alquiler: [captura](../trazabilidad/evidencias/ISS-06-03-formulario-signal-inputs.png).
- **EVI-06-04** Validación del borrador y payload directo o desde reserva: [captura](../trazabilidad/evidencias/ISS-06-04-formulario-validacion.png).
- **EVI-06-05** Plantilla HTML del formulario: [captura](../trazabilidad/evidencias/ISS-06-05-formulario-template.png).
- **EVI-06-06** Inicialización y carga de datos en `RentalList`: [captura](../trazabilidad/evidencias/ISS-06-06-listado-carga.png).
- **EVI-06-07** Carga filtrada de tarifas, clientes y estaciones: [captura](../trazabilidad/evidencias/ISS-06-07-listado-catalogos.png).
- **EVI-06-08** Resolución de nombres y envío del registro: [captura](../trazabilidad/evidencias/ISS-06-08-listado-resolucion-nombres-y-alta.png).
- **EVI-06-09** Errores HTTP y su presentación: [captura](../trazabilidad/evidencias/ISS-06-09-listado-errores.png).
- **EVI-06-10** Integración de `RentalList` en `Construir`: [captura](../trazabilidad/evidencias/ISS-06-10-integracion-construir.png).
- **EVI-06-11** Bundle de pruebas compilado; 2 archivos y 6 pruebas generales aprobadas, sin cobertura específica de alquileres: [captura](../trazabilidad/evidencias/ISS-06-11-pruebas-generales.png).

## Estado de esta guía

Guía adaptada al recurso real `Rental` y a sus contratos de lectura, registro, disponibilidad y RBAC. La implementación y la integración en `Construir` están documentadas mediante EVI-06-01 a EVI-06-10. EVI-06-11 registra que el bundle de pruebas compiló y que pasaron seis pruebas generales; no hay pruebas unitarias específicas del feature acreditadas. No se verificó un build de producción ni se hicieron llamadas a la API real. La ISS se cierra con esas limitaciones expresas; no se requieren credenciales y las pruebas específicas pendientes deben usar respuestas simuladas. Este documento conserva el ISS original de StoreLab al final, separado de la adaptación.

---

# ISS-06 original · Ventas y detalle en memoria

> **Fin de la adaptación PedalLibre.** Lo que sigue conserva el contenido del ISS original de StoreLab. Sus entidades, campos, rutas, resultados y pruebas no describen el backend PedalLibre.

> **Unidad ISS-06 · Ventas y detalle** — capa **Construir**
>
> [Comprender este bloque](https://tecnogua.com/academic/site/frontend2026/django/aprender/ISS-06-ventas-y-detalle/) · [Ruta Frontend-Django](https://tecnogua.com/academic/site/frontend2026/django/)
>
> Capa | Página | Para qué
> --- | --- | ---
> Aprender | Ventas y detalle | comprender, explicar y relacionar
> Construir | esta página | ejecutar, verificar y entregar

## Contexto mínimo original

Proyecto `front-storelab-django`: Angular 22, PrimeNG 22 Aura, Tailwind 4 y sin CSS de negocio. Backend `pry-django` en `http://localhost:8000/api`.

La lectura de una venta trae `client`, `clientName` y `lines[]` con `product` y `productName`. La escritura usa POST con `clientId`, `saleDate`, `discounts` e `items[{ productId, quantity }]`. El servidor calcula impuesto, precios y totales, y descuenta existencias. No existe PATCH de una venta.

Al terminar ISS-05, clientes, tipos y productos se leen. `/ventas` sigue en el placeholder y el ítem ya existe en `Shell.items`. El patrón visual es `PATRON-VISUAL.md`.

| Campo | Valor original |
|---|---|
| Título | Ventas y detalle en memoria |
| Feature / tabla | `features/sales` (`sale-list`, `sale-form`, `sale-date`) sobre `sales` |
| API | `GET/POST /api/sales/`, más `GET /api/clients/?status=active` y `GET /api/products/available/` |
| Depende de | ISS-05 — CRUD de productos |
| Habilita | ISS-07 — Detalle de ventas y dashboard |

**Lectura y escritura no comparten campos.** Copiar `clientId` o `items` a la lectura, o `client` y `lines` al POST, produce 400. El borrador vive en signals; no es un `FormGroup`.

**Evidencia de aprendizaje:** explicar por qué el total del formulario es una vista previa y el total de la tabla es el devuelto por el servidor, y qué ocurre si se agrega dos veces la misma línea.

## Objetivo original

Listar ventas y registrar una desde un borrador en memoria. El borrador rechaza producto repetido, cantidad inválida y cantidad superior al stock conocido. Un 400 del POST permanece en el diálogo. La anulación no se implementa aquí: el número de la venta enlaza a `/ventas/:id`, que construye ISS-07.

El original llama a esto Fase I · Business: sin login y sin interceptor. El descuento de existencias lo hace el backend al responder 201.

## Requisitos originales

- [ ] **06.1** `Sale` de lectura usa `client`, `clientName` y `lines`; `SaleCreatePayload` usa `clientId` e `items`.
- [ ] **06.2** `toIsoWithOffset` emite fecha con zona del navegador, no con `Z`.
- [ ] **06.3** El borrador impide línea duplicada y cantidad superior al stock.
- [ ] **06.4** La lista carga tres GET (ventas, clientes activos, productos disponibles) y el POST exitoso la recarga.
- [ ] **06.5** Un error del POST permanece en el formulario.
- [ ] **06.6** `/ventas` carga `SaleList` y el id enlaza a `/ventas/:id`.
- [ ] **06.7** Pasan las pruebas del incremento y el CSS del feature no tiene reglas.

## Construcción original

### 06.1 · Dos formas del mismo recurso

Lectura de `GET /api/sales/` y `GET /api/sales/{id}/`:

```ts
export interface Sale {
  id: number;
  client: number;
  clientName?: string;
  saleDate: string;
  subtotal: Money;
  tax: Money;
  discounts: Money;
  total: Money;
  status: Status;
  lines?: SaleLine[];
}
```

`SaleLine` trae `product`, `productName`, `quantity`, `unitPrice` y `lineTotal`.

Escritura de `POST /api/sales/`:

```ts
export interface SaleCreatePayload {
  clientId: number;
  saleDate: string;
  discounts: Money;
  items: { productId: number; quantity: number }[];
}
```

El parser camelCase del backend traduce `clientId` y `productId`. No existe el recurso `/product-sales/`.

### 06.2 · Fecha con zona

`sale-date.ts` arma `YYYY-MM-DDTHH:mm:ss±HH:mm` con `getTimezoneOffset()`. No usar `date.toISOString()`: termina en `Z` y no representa la zona local del laboratorio.

### 06.3 · Borrador

`sale-form` no usa `ReactiveFormsModule`. Cliente, fecha, descuento, producto elegido, cantidad y líneas son signals. El `effect` solo lee `resetKey()` y luego reinicia el borrador.

`addLine()` exige un producto disponible, cantidad entera `>= 1`, que el producto no esté ya en `lines` y que la cantidad no supere `product.quantity`. `lineTotal` y `subtotal` se derivan del precio de catálogo; el descuento se resta para la vista previa.

El `submit()` emite:

```ts
this.saved.emit({
  clientId,
  saleDate: toIsoWithOffset(saleDate),
  discounts: (this.discounts() || 0).toFixed(2),
  items: this.lines().map(({ productId, quantity }) => ({ productId, quantity })),
});
```

### 06.4 · Lista original

```ts
forkJoin({
  sales: this.api.list(),
  clients: this.clientsApi.list('active'),
  products: this.productsApi.available(),
})
```

El nombre visible es `sale.clientName`, luego el mapa de clientes activos y, si falta, `Cliente #id`. La etiqueta del encabezado suma `quantity` de los productos disponibles. `save()` hace POST; si responde, cierra el diálogo, avisa y vuelve a cargar los tres GET, porque el stock disponible ya cambió. Si falla, `saleError` permanece en el formulario.

La columna de venta enlaza a `/ventas/:id`. Hasta ISS-07 esa ruta no existe y el comodín lleva a `/construir`.

### 06.5 · Pruebas originales

- `sale-form.spec.ts`: la segunda línea del mismo producto deja el mensaje «ya está en la venta» y no crece el arreglo; `submit()` emite `clientId`, `saleDate` con `toIsoWithOffset`, `discounts` con dos decimales e `items`.
- `sale-list.spec.ts`: verifica los tres GET (clientes con `status=active` y `/products/available/`), el POST con ese cuerpo y la recarga que deja la venta nueva en `sales()`.

## Cómo probar el original

1. Abrir `/ventas`: filas del seeder con cliente, fecha, total y estado, además de la etiqueta de unidades disponibles.
2. Abrir «Nueva venta», elegir cliente y producto, agregar la línea y volver a agregar el mismo producto: aparece «ya está en la venta» y queda una línea.
3. Registrar: `POST /api/sales/` con `clientId` e `items`. La respuesta contiene `total`, `lines[].unitPrice` y `lines[].lineTotal` calculados. El stock baja según la cantidad vendida.
4. La venta nueva aparece en la tabla y enlaza a `/ventas/{id}`.

## Criterios originales de aceptación

- **AC-06-01:** la tabla sale de `GET /api/sales/` y muestra `clientName`, fecha, total y estado.
- **AC-06-02:** el alta carga clientes activos y productos disponibles.
- **AC-06-03:** el borrador rechaza una línea duplicada y no la agrega.
- **AC-06-04:** el POST envía `clientId`, `saleDate` con zona, `discounts` e `items[{ productId, quantity }]`.
- **AC-06-05:** el 201 recarga la lista y el stock queda descontado.
- **AC-06-06:** el id enlaza a `/ventas/:id`.
- **AC-06-07:** pasan las pruebas del feature y su CSS no tiene reglas.

## Verificación y resultados originales

Resultados reportados en ese workspace (24-oct-2026):

| Comprobación | Resultado original |
|---|---|
| Listado | 30 ventas del seeder; primera fila `#60`, cliente «Pacífica Aurora Cañellas Cerro», 24/10/2026 09:46, `$1,266.02`, Activo. Etiqueta «2921 unidades disponibles» |
| Borrador | Cliente «Alfredo Garrido Vilanova» y producto «Acción 15»; al repetir aparece «ya está en la venta» y permanece 1 línea |
| Alta | Venta 61, `client: 15`, `total: "516.10"`, una línea de producto 35 con `unitPrice` y `lineTotal` `"516.10"` |
| Stock | «Acción 15» pasa de 149 a 148 unidades |
| Enlace | `#61` apunta a `/ventas/61` |

La anulación de esa venta, que devuelve el stock a 149, se registra en ISS-07.

| Criterio | Resultado original |
|---|---|
| AC-06-01 | Tabla con cliente, fecha, total y estado — PASS |
| AC-06-02 | Diálogo ofrece clientes activos y productos disponibles — PASS |
| AC-06-03 | La línea duplicada no se agrega — PASS |
| AC-06-04 | Venta 61 guarda `client` 15 y la línea del producto 35 — PASS |
| AC-06-05 | Stock de «Acción 15» baja de 149 a 148 — PASS |
| AC-06-06 | El id enlaza a `/ventas/61` — PASS |
| AC-06-07 | Pruebas del feature en verde y CSS sin reglas — PASS |

## Evidencias originales

- **EVI-06-01:** tabla de ventas con la etiqueta de unidades disponibles.
- **EVI-06-02:** borrador con una línea y aviso de producto repetido.
- **EVI-06-03:** `GET /api/sales/61/` con `clientName`, `total: "516.10"` y línea de «Acción 15»; `GET /api/products/35/` con `quantity: 148` después del alta.

## Gate y navegación originales

```text
TODOS los AC = PASS  → se puede avanzar a ISS-07
ALGÚN AC = FAIL      → se corrige y se repite
```

← ISS-05 · CRUD de productos · ↑ Ruta Frontend-Django · → ISS-07 · Detalle de ventas y dashboard
