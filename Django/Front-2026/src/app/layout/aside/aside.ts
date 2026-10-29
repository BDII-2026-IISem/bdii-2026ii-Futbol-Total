import { Component, input, output } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenuModule } from 'primeng/panelmenu';

@Component({
  host: { class: 'block h-full' },
  selector: 'app-aside',
  imports: [PanelMenuModule],
  templateUrl: './aside.html',
  styleUrl: './aside.css',
})
export class Aside {
  readonly appName = input('PedalLibre');
  readonly items = input<MenuItem[]>([]);
  readonly navigated = output<void>();

  onNavigationClick(event: Event): void {
    const target = event.target;
    if (target instanceof HTMLElement && target.closest('a, button, [role="button"]')) {
      this.navigated.emit();
    }
  }
}
