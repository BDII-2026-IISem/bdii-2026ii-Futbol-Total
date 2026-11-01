import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Client, ClientPayload } from '../../core/models/client.model';

@Injectable({ providedIn: 'root' })
export class ClientApi {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/clients`;

  list(): Observable<Client[]> {
    return this.http.get<Client[]>(`${this.base}/`);
  }

  get(id: number): Observable<Client> {
    return this.http.get<Client>(`${this.base}/${id}/`);
  }

  create(payload: ClientPayload): Observable<Client> {
    return this.http.post<Client>(`${this.base}/`, payload);
  }

  replace(id: number, payload: ClientPayload): Observable<Client> {
    return this.http.put<Client>(`${this.base}/${id}/`, payload);
  }

  update(id: number, payload: Partial<ClientPayload>): Observable<Client> {
    return this.http.patch<Client>(`${this.base}/${id}/`, payload);
  }

  setActive(id: number, isActive: boolean): Observable<Client> {
    return this.http.patch<Client>(`${this.base}/${id}/`, { is_active: isActive });
  }
}
