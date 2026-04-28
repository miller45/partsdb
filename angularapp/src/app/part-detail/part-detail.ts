import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { PartsService } from '../parts';
import { Part } from '../models/part.model';

@Component({
  selector: 'app-part-detail',
  imports: [CommonModule, RouterLink],
  templateUrl: './part-detail.html',
  styleUrl: './part-detail.css'
})
export class PartDetail implements OnInit {
  private route = inject(ActivatedRoute);
  private svc = inject(PartsService);

  part = signal<Part | null>(null);
  notFound = signal(false);

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('partId') ?? '';
    this.svc.getParts().subscribe(res => {
      const found = res.parts.find(p => p.artnr === decodeURIComponent(id));
      if (found) {
        this.part.set(found);
      } else {
        this.notFound.set(true);
      }
    });
  }
}
