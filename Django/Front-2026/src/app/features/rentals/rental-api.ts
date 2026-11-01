import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Bicycle } from '../../core/models/bicycle.model';
import {
  Rental,
  RentalClientOption,
  RentalRateOption,
  RentalRegistrationPayload,
  RentalRegistrationResult,
  RentalReservationOption,
  RentalStationOption,
} from '../../core/models/rental.model';

@Injectable({ providedIn: 'root' })
export class RentalApi {
  private readonly http = inject(HttpClient);
  private readonly base = environment.apiUrl;

  list(): Observable<Rental[]> {
    return this.http.get<Rental[]>(`${this.base}/rentals/`);
  }

  get(id: number): Observable<Rental> {
    return this.http.get<Rental>(`${this.base}/rentals/${id}/`);
  }

  register(payload: RentalRegistrationPayload): Observable<RentalRegistrationResult> {
    return this.http.post<RentalRegistrationResult>(`${this.base}/rentals/`, payload);
  }

  clients(): Observable<RentalClientOption[]> {
    return this.http.get<RentalClientOption[]>(`${this.base}/clients/`);
  }

  availableBicycles(): Observable<Bicycle[]> {
    return this.http.get<Bicycle[]>(`${this.base}/bicycles/available/`);
  }

  rates(): Observable<RentalRateOption[]> {
    return this.http.get<RentalRateOption[]>(`${this.base}/rates/`);
  }

  stations(): Observable<RentalStationOption[]> {
    return this.http.get<RentalStationOption[]>(`${this.base}/stations/`);
  }

  reservations(): Observable<RentalReservationOption[]> {
    return this.http.get<RentalReservationOption[]>(`${this.base}/reservations/`);
  }
}
