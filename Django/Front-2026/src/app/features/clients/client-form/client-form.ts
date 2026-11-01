import { Component, effect, inject, input, output } from '@angular/core';
import { NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Client, ClientPayload } from '../../../core/models/client.model';

@Component({
  selector: 'app-client-form',
  imports: [ReactiveFormsModule],
  templateUrl: './client-form.html',
  styleUrl: './client-form.css',
})
export class ClientForm {
  readonly client = input<Client | null>(null);
  readonly saving = input(false);
  readonly resetKey = input(0);
  readonly saved = output<ClientPayload>();
  readonly cancelled = output<void>();

  private readonly fb = inject(NonNullableFormBuilder);
  readonly form = this.fb.group({
    document_type: ['', [Validators.maxLength(30)]],
    first_name: ['', [Validators.required, Validators.maxLength(100)]],
    last_name: ['', [Validators.required, Validators.maxLength(100)]],
    document_number: ['', [Validators.required, Validators.maxLength(50)]],
    phone: ['', [Validators.maxLength(30)]],
    email: ['', [Validators.email, Validators.maxLength(150)]],
  });

  constructor() {
    effect(() => {
      const current = this.client();
      this.resetKey();
      this.form.reset({
        document_type: current?.document_type ?? '',
        first_name: current?.first_name ?? '',
        last_name: current?.last_name ?? '',
        document_number: current?.document_number ?? '',
        phone: current?.phone ?? '',
        email: current?.email ?? '',
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
      document_type: value.document_type.trim(),
      first_name: value.first_name.trim(),
      last_name: value.last_name.trim(),
      document_number: value.document_number.trim(),
      phone: value.phone.trim() || null,
      email: value.email.trim() || null,
      ...(this.client() ? {} : { is_active: true }),
    });
  }
}
