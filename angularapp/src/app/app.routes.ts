import { Routes } from '@angular/router';
import { Parts } from './parts/parts';
import { Resistors } from './resistors/resistors';
import { Modules } from './modules/modules';
import { About } from './about/about';
import { PartDetail } from './part-detail/part-detail';

export const routes: Routes = [
  { path: '', redirectTo: '/parts', pathMatch: 'full' },
  { path: 'parts', component: Parts },
  { path: 'parts/:partId', component: PartDetail },
  { path: 'resistors', component: Resistors },
  { path: 'modules', component: Modules },
  { path: 'about', component: About },
];
