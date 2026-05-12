import { Routes } from '@angular/router';
import { MsalGuard } from '@azure/msal-angular';
import { Parts } from './parts/parts';
import { Resistors } from './resistors/resistors';
import { Modules } from './modules/modules';
import { About } from './about/about';
import { PartDetail } from './part-detail/part-detail';

export const routes: Routes = [
  { path: '', redirectTo: '/parts', pathMatch: 'full' },
  { path: 'parts', component: Parts, canActivate: [MsalGuard] },
  { path: 'parts/:partId', component: PartDetail, canActivate: [MsalGuard] },
  { path: 'resistors', component: Resistors, canActivate: [MsalGuard] },
  { path: 'modules', component: Modules, canActivate: [MsalGuard] },
  { path: 'about', component: About, canActivate: [MsalGuard] },
];
