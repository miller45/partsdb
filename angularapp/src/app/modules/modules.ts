import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PartsService } from '../parts';
import { Module } from '../models/module.model';

type SortField = keyof Module;
type SortDir = 'asc' | 'desc' | '';

@Component({
  selector: 'app-modules',
  imports: [CommonModule, FormsModule],
  templateUrl: './modules.html',
  styleUrl: './modules.css'
})
export class Modules implements OnInit {
  private svc = inject(PartsService);

  rows = signal<Module[]>([]);
  searchField = signal<string>('artnr');
  searchTerm = signal<string>('');
  globalSearch = signal<string>('');
  sortField = signal<SortField | ''>('');
  sortDir = signal<SortDir>('');

  predicates: string[] = ['artnr', 'description'];

  filtered = computed(() => {
    let data = this.rows();
    const term = this.searchTerm().toLowerCase();
    const global = this.globalSearch().toLowerCase();
    const field = this.searchField() as keyof Module;

    if (term && field) {
      data = data.filter(r => {
        const val = r[field];
        return val != null && String(val).toLowerCase().includes(term);
      });
    }
    if (global) {
      data = data.filter(r =>
        Object.values(r).some(v => v != null && String(v).toLowerCase().includes(global))
      );
    }
    const sf = this.sortField();
    const sd = this.sortDir();
    if (sf && sd) {
      data = [...data].sort((a, b) => {
        const av = a[sf as keyof Module] ?? '';
        const bv = b[sf as keyof Module] ?? '';
        const cmp = String(av).localeCompare(String(bv), undefined, { numeric: true });
        return sd === 'asc' ? cmp : -cmp;
      });
    }
    return data;
  });

  ngOnInit(): void {
    this.svc.getModules().subscribe(modules => this.rows.set(modules));
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

  onSearchFieldChange(val: string): void {
    this.searchField.set(val);
    this.searchTerm.set('');
  }
}
