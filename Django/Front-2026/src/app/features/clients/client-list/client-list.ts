import { HttpErrorResponse } from '@angular/common/http';
import { Component, computed, inject, signal } from '@angular/core';
import { Client, ClientPayload } from '../../../core/models/client.model';
import { filterRows } from '../../../core/utils/filter-rows';
import { ClientForm } from '../client-form/client-form';
import { ClientApi } from '../client-api';

@Component({
  selector: 'app-client-list',
  imports: [ClientForm],
  templateUrl: './client-list.html',
  styleUrl: './client-list.css',
})
export class ClientList {
  private readonly api = inject(ClientApi);

  readonly rows = signal<Client[]>([]);
  readonly filter = signal('');
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly dialogVisible = signal(false);
  readonly editing = signal<Client | null>(null);
  readonly resetKey = signal(0);
  readonly errorMessage = signal<string | null>(null);
  readonly successMessage = signal<string | null>(null);
  readonly visibleRows = computed(() =>
    filterRows(this.rows(), this.filter(), (client) => [
      client.first_name,
      client.last_name,
      client.document_number,
      client.phone,
      client.email,
    ]),
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

  onFilterChange(event: Event): void {
    if (event.target instanceof HTMLInputElement) {
      this.filter.set(event.target.value);
    }
  }

  openCreate(): void {
    this.editing.set(null);
    this.resetKey.update((value) => value + 1);
    this.errorMessage.set(null);
    this.dialogVisible.set(true);
  }

  openEdit(client: Client): void {
    this.editing.set(client);
    this.resetKey.update((value) => value + 1);
    this.errorMessage.set(null);
    this.dialogVisible.set(true);
  }

  closeForm(): void {
    if (!this.saving()) this.dialogVisible.set(false);
  }

  save(payload: ClientPayload): void {
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
        this.successMessage.set(current ? 'Cliente actualizado.' : 'Cliente creado.');
        this.load();
      },
      error: (error: unknown) => {
        this.saving.set(false);
        this.errorMessage.set(this.describeError(error));
      },
    });
  }

  setActive(client: Client): void {
    const isActive = !client.is_active;
    this.errorMessage.set(null);
    this.successMessage.set(null);
    this.saving.set(true);
    this.api.setActive(client.id, isActive).subscribe({
      next: () => {
        this.saving.set(false);
        this.successMessage.set(isActive ? 'Cliente activado.' : 'Cliente desactivado.');
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
