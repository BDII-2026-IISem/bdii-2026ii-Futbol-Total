import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  Bicycle,
  BicycleCreatePayload,
  BicycleUpdatePayload,
} from '../../core/models/bicycle.model';

@Injectable({ providedIn: 'root' })
export class BicycleApi {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/bicycles`;

  list(): Observable<Bicycle[]> {
    return this.http.get<Bicycle[]>(`${this.base}/`);
  }

  get(id: number): Observable<Bicycle> {
    return this.http.get<Bicycle>(`${this.base}/${id}/`);
  }

  create(payload: BicycleCreatePayload): Observable<Bicycle> {
    return this.http.post<Bicycle>(`${this.base}/`, payload);
  }

  update(
    id: number,
    payload: BicycleUpdatePayload | { isActive: boolean },
  ): Observable<Bicycle> {
    return this.http.patch<Bicycle>(`${this.base}/${id}/`, payload);
  }

  available(): Observable<Bicycle[]> {
    return this.http.get<Bicycle[]>(`${this.base}/available/`);
  }
}
