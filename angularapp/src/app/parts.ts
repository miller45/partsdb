import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Part } from './models/part.model';
import { Module } from './models/module.model';
import { Resistor } from './models/resistor.model';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class PartsService {
  private http = inject(HttpClient);
  private apiUrl = environment.apiUrl;

  getParts(): Observable<Part[]> {
    return this.http.get<Part[]>(`${this.apiUrl}/parts`);
  }

  getPartByArtnr(artnr: string): Observable<Part> {
    return this.http.get<Part>(`${this.apiUrl}/parts/find`, { params: { artnr } });
  }

  getModules(): Observable<Module[]> {
    return this.http.get<Module[]>(`${this.apiUrl}/modules`);
  }

  getResistors(): Observable<Resistor[]> {
    return this.http.get<Resistor[]>(`${this.apiUrl}/resistors`);
  }
}
