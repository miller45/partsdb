import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Part, PartsResponse } from './models/part.model';
import { Module, ModulesResponse } from './models/module.model';
import { Resistor } from './models/resistor.model';

@Injectable({
  providedIn: 'root',
})
export class PartsService {
  private http = inject(HttpClient);

  getParts(): Observable<PartsResponse> {
    return this.http.get<PartsResponse>('data/parts.json');
  }

  getModules(): Observable<ModulesResponse> {
    return this.http.get<ModulesResponse>('data/modules.json');
  }

  getResistors(): Observable<Resistor[]> {
    return this.http.get<Resistor[]>('data/myresistors.json');
  }
}
