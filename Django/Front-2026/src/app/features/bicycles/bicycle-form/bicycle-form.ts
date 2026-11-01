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
