import { APP_INITIALIZER, ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter, withHashLocation } from '@angular/router';
import { provideHttpClient, withInterceptorsFromDi, HTTP_INTERCEPTORS } from '@angular/common/http';
import {
  MSAL_GUARD_CONFIG,
  MSAL_INSTANCE,
  MSAL_INTERCEPTOR_CONFIG,
  MsalBroadcastService,
  MsalGuard,
  MsalInterceptor,
  MsalService,
} from '@azure/msal-angular';
import { IPublicClientApplication } from '@azure/msal-browser';

import { routes } from './app.routes';
import { MSALInstanceFactory, msalGuardConfig, msalInterceptorConfig } from './auth-config';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes, withHashLocation()),
    // withInterceptorsFromDi() allows class-based interceptors (MsalInterceptor)
    provideHttpClient(withInterceptorsFromDi()),

    // MSAL instance
    { provide: MSAL_INSTANCE, useFactory: MSALInstanceFactory },
    { provide: MSAL_GUARD_CONFIG, useValue: msalGuardConfig },
    { provide: MSAL_INTERCEPTOR_CONFIG, useValue: msalInterceptorConfig },

    // Initialize MSAL and process any pending redirect (auth code) before the
    // app renders. Without this, MsalGuard fires before handleRedirectObservable()
    // in AppComponent.ngOnInit, causing the guard to see no account and trigger
    // a new login redirect that discards the auth code.
    {
      provide: APP_INITIALIZER,
      useFactory: (msal: IPublicClientApplication) => async () => {
        await msal.initialize();
        await msal.handleRedirectPromise();
      },
      deps: [MSAL_INSTANCE],
      multi: true,
    },

    // Automatically attach Bearer tokens to API requests
    { provide: HTTP_INTERCEPTORS, useClass: MsalInterceptor, multi: true },

    MsalService,
    MsalGuard,
    MsalBroadcastService,
  ],
};
