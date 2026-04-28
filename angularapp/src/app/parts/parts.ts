import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { PartsService } from '../parts';
import { Part } from '../models/part.model';
type SortField = keyof Part;
type SortDir = 'asc' | 'desc' | '';

@Component({
  selector: 'app-parts',
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './parts.html',
  styleUrl: './parts.css'
})
export class Parts implements OnInit {
  private svc = inject(PartsService);

  rows = signal<Part[]>([]);
  searchField = signal<string>('batch');
  searchTerm = signal<string>('');
  globalSearch = signal<string>('');
  sortField = signal<SortField | ''>('');
  sortDir = signal<SortDir>('');

  predicates: string[] = ['batch', 'artnr', 'description', 'class', 'value1', 'value2'];

  filtered = computed(() => {
    let data = this.rows();
    const term = this.searchTerm().toLowerCase();
    const global = this.globalSearch().toLowerCase();
    const field = this.searchField() as keyof Part;

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
        const av = a[sf as keyof Part] ?? '';
        const bv = b[sf as keyof Part] ?? '';
        const cmp = String(av).localeCompare(String(bv), undefined, { numeric: true });
        return sd === 'asc' ? cmp : -cmp;
      });
    }
    return data;
  });

  ngOnInit(): void {
    this.svc.getParts().subscribe(parts => this.rows.set(parts));
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
