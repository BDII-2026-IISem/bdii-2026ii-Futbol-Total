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
