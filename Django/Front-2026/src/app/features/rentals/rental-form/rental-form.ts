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
