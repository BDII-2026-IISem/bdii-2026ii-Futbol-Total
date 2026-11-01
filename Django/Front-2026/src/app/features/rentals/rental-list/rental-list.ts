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
