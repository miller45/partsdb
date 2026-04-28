import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PartsService } from '../parts';
import { Resistor } from '../models/resistor.model';

type SortField = keyof Resistor;
type SortDir = 'asc' | 'desc' | '';

@Component({
  selector: 'app-resistors',
  imports: [CommonModule, FormsModule],
  templateUrl: './resistors.html',
  styleUrl: './resistors.css'
})
export class Resistors implements OnInit {
  private svc = inject(PartsService);

  rows = signal<Resistor[]>([]);
  globalSearch = signal<string>('');
  sortField = signal<SortField | ''>('');
  sortDir = signal<SortDir>('');

  filtered = computed(() => {
    let data = this.rows();
    const global = this.globalSearch().toLowerCase();
    if (global) {
      data = data.filter(r =>
        Object.values(r).some(v => v != null && String(v).toLowerCase().includes(global))
      );
    }
    const sf = this.sortField();
    const sd = this.sortDir();
    if (sf && sd) {
      data = [...data].sort((a, b) => {
        const av = a[sf as keyof Resistor] ?? '';
        const bv = b[sf as keyof Resistor] ?? '';
        const cmp = String(av).localeCompare(String(bv), undefined, { numeric: true });
        return sd === 'asc' ? cmp : -cmp;
      });
    }
    return data;
  });

  ngOnInit(): void {
    this.svc.getResistors().subscribe(data => this.rows.set(data));
  }

  sort(field: SortField): void {
    if (this.sortField() === field) {
      this.sortDir.set(this.sortDir() === 'asc' ? 'desc' : this.sortDir() === 'desc' ? '' : 'asc');
      if (this.sortDir() === '') this.sortField.set('');
    } else {
      this.sortField.set(field);
      this.sortDir.set('asc');
    }
  }

  sortIcon(field: SortField): string {
    if (this.sortField() !== field) return '';
    return this.sortDir() === 'asc' ? '▲' : '▼';
  }
}
