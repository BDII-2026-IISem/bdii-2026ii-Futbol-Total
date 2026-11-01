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
