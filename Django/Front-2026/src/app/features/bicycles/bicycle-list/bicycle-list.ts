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
