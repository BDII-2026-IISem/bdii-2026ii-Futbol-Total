import { Component } from '@angular/core';
import { Aside } from './layout/aside/aside';
import { Footer } from './layout/footer/footer';
import { Header } from './layout/header/header';

@Component({
  imports: [Header, Aside, Footer],
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  protected readonly title = 'Inicio';
}
