import { DOCUMENT } from '@angular/common';
import { Component, DestroyRef, inject, signal } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { DrawerModule } from 'primeng/drawer';
import { Aside } from '../../layout/aside/aside';
import { Footer } from '../../layout/footer/footer';
import { Header } from '../../layout/header/header';

@Component({
  imports: [Aside, DrawerModule, Footer, Header],
  selector: 'app-construir',
  styleUrl: './construir.css',
  templateUrl: './construir.html',
})
export class Construir {
  readonly mobileOpen = signal(false);
  readonly sidebarCollapsed = signal(false);
  readonly title = signal('Inicio');

  readonly items: MenuItem[] = [
    { label: 'Inicio', command: () => this.seleccionar('Inicio') },
    { label: 'Clientes', command: () => this.seleccionar('Clientes') },
    {
      label: 'Bicicletas disponibles',
      command: () => this.seleccionar('Bicicletas disponibles'),
    },
    { label: 'Tarifas', command: () => this.seleccionar('Tarifas') },
    { label: 'Acceso', command: () => this.seleccionar('Acceso') },
  ];

  private readonly destroyRef = inject(DestroyRef);
  private isDesktop = false;

  constructor() {
    const view = inject(DOCUMENT).defaultView;
    const mediaQuery = view?.matchMedia?.('(min-width: 1024px)');
    if (!mediaQuery) {
      return;
    }

    this.isDesktop = mediaQuery.matches;
    const updateBreakpoint = (event: MediaQueryListEvent): void => {
      this.isDesktop = event.matches;
    };

    mediaQuery.addEventListener('change', updateBreakpoint);
    this.destroyRef.onDestroy(() => mediaQuery.removeEventListener('change', updateBreakpoint));
  }

  seleccionar(titulo: string): void {
    this.title.set(titulo);
    this.mobileOpen.set(false);
  }

  onMenuToggle(): void {
    if (this.isDesktop) {
      this.sidebarCollapsed.update((collapsed) => !collapsed);
      return;
    }

    this.mobileOpen.update((open) => !open);
  }
}
