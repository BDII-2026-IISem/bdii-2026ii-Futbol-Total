import { Component } from '@angular/core';

@Component({
  host: { class: 'block' },
  selector: 'app-header',
  styleUrl: './header.css',
  templateUrl: './header.html',
})
export class Header {
  readonly title = 'PedalLibre';
}
