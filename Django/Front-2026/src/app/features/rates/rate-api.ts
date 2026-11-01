import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Rate, RatePayload } from '../../core/models/rate.model';

@Injectable({ providedIn: 'root' })
export class RateApi {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/rates`;

  list(): Observable<Rate[]> {
    return this.http.get<Rate[]>(`${this.base}/`);
  }

  get(id: number): Observable<Rate> {
    return this.http.get<Rate>(`${this.base}/${id}/`);
  }

  create(payload: RatePayload): Observable<Rate> {
    return this.http.post<Rate>(`${this.base}/`, payload);
  }

  replace(id: number, payload: RatePayload): Observable<Rate> {
    return this.http.put<Rate>(`${this.base}/${id}/`, payload);
  }

  update(id: number, payload: Partial<RatePayload>): Observable<Rate> {
    return this.http.patch<Rate>(`${this.base}/${id}/`, payload);
  }
}
