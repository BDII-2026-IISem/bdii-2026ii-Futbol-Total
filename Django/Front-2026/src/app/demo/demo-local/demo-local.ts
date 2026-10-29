import { Component, computed, effect, signal } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';

interface ItemDemo {
  name: string;
  price: number;
  active: boolean;
}

@Component({
  selector: 'app-demo-local',
  imports: [ButtonModule, CardModule, TagModule],
  templateUrl: './demo-local.html',
  styleUrl: './demo-local.css',
})
export class DemoLocal {
  protected readonly item = signal<ItemDemo>({
    name: 'Elemento de demostración',
    price: 10000,
    active: true,
  });

  protected readonly tax = computed(() => Math.round(this.item().price * 0.19));

  constructor() {
    effect(() => console.info('[demo-local]', this.item()));
  }

  protected increasePrice(): void {
    this.item.update((current) => ({ ...current, price: current.price + 1000 }));
  }

  protected toggleActive(): void {
    this.item.update((current) => ({ ...current, active: !current.active }));
  }

  protected updateName(event: Event): void {
    const input = event.target;
    if (input instanceof HTMLInputElement) {
      this.item.update((current) => ({ ...current, name: input.value }));
    }
  }

  protected reset(): void {
    this.item.set({
      name: 'Elemento de demostración',
      price: 10000,
      active: true,
    });
  }
}
