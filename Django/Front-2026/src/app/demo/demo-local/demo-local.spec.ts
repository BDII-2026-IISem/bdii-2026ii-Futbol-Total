import { TestBed } from '@angular/core/testing';
import { DemoLocal } from './demo-local';

describe('DemoLocal', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DemoLocal],
    }).compileComponents();
  });

  it('renders local sample values and derived tax', async () => {
    const fixture = TestBed.createComponent(DemoLocal);
    await fixture.whenStable();
    fixture.detectChanges();

    const content = (fixture.nativeElement as HTMLElement).textContent;
    expect(content).toContain('Elemento de demostración');
    expect(content).toContain('Precio de muestra: 10000');
    expect(content).toContain('Impuesto de muestra: 1900');
    expect(content).toContain('Activo');
  });

  it('updates the sample price and computed tax', async () => {
    const fixture = TestBed.createComponent(DemoLocal);
    await fixture.whenStable();
    fixture.detectChanges();

    const buttons = (fixture.nativeElement as HTMLElement).querySelectorAll('button');
    buttons[0].click();
    fixture.detectChanges();

    const content = (fixture.nativeElement as HTMLElement).textContent;
    expect(content).toContain('Precio de muestra: 11000');
    expect(content).toContain('Impuesto de muestra: 2090');
  });

  it('updates the preview and toggles the sample status', async () => {
    const fixture = TestBed.createComponent(DemoLocal);
    await fixture.whenStable();
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    const nameInput = element.querySelector<HTMLInputElement>('#demo-name');
    expect(nameInput).not.toBeNull();
    nameInput!.value = 'Mi muestra';
    nameInput!.dispatchEvent(new Event('input', { bubbles: true }));
    fixture.detectChanges();

    expect(element.textContent).toContain('Vista previa: Mi muestra');

    const buttons = element.querySelectorAll('button');
    buttons[1].click();
    fixture.detectChanges();

    expect(element.textContent).toContain('Inactivo');
  });

  it('resets the sample to its initial values', async () => {
    const fixture = TestBed.createComponent(DemoLocal);
    await fixture.whenStable();
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    const buttons = element.querySelectorAll('button');
    buttons[0].click();
    buttons[1].click();
    buttons[2].click();
    fixture.detectChanges();

    expect(element.textContent).toContain('Precio de muestra: 10000');
    expect(element.textContent).toContain('Impuesto de muestra: 1900');
    expect(element.textContent).toContain('Activo');
  });
});
