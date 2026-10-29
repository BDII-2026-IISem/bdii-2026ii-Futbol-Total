import { Component, input, output } from '@angular/core';
import { ButtonModule } from 'primeng/button';

@Component({
  host: { class: 'block' },
  selector: 'app-header',
  imports: [ButtonModule],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  readonly appName = input('PedalLibre');
  readonly menuRequested = output<void>();
}
