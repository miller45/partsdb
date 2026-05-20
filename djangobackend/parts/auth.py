"""Entra ID JWT bearer authentication for django-ninja.

Uses ``mozilla-django-oidc``'s ``JWKS``-backed key resolution + signature
verification, then layers explicit audience/issuer/expiry checks via PyJWT
because the stock OIDC backend is geared for browser login flows rather
than API bearer tokens issued to a SPA via MSAL.js.
"""
from __future__ import annotations

import logging
from typing import Any

import jwt
from django.conf import settings
from mozilla_django_oidc.auth import OIDCAuthenticationBackend
from ninja.security import HttpBearer

logger = logging.getLogger(__name__)


class EntraJWTBearer(HttpBearer):
    """Validate Entra ID access tokens presented as ``Authorization: Bearer ...``."""

    openapi_scheme = "bearer"
    openapi_bearer_format = "JWT"

    def __init__(self) -> None:
        super().__init__()
        # Re-use mozilla-django-oidc's JWKS handling. The backend caches keys
        # internally between requests.
        self._oidc = OIDCAuthenticationBackend()
        tenant = settings.AZURE_AD_TENANT_ID
        # Entra issues either v2 tokens (iss …/{tenant}/v2.0) or v1 tokens
        # (iss https://sts.windows.net/{tenant}/) depending on the app's
        # `requestedAccessTokenVersion`. Accept both.
        self._expected_issuers = (
            (
                f"https://login.microsoftonline.com/{tenant}/v2.0",
                f"https://sts.windows.net/{tenant}/",
            )
            if tenant
            else ()
        )
        self._expected_audience = settings.AZURE_AD_AUDIENCE or None

    def authenticate(self, request, token: str) -> dict[str, Any] | None:
        if not token:
            return None
        if not self._expected_audience or not self._expected_issuers:
            logger.error("Entra auth not configured: AZURE_AD_TENANT_ID / AZURE_AD_AUDIENCE missing")
            return None

        try:
            # 1. Signature verification via mozilla-django-oidc (handles JWKS
            #    fetch + key rotation). Raises on invalid signature.
            payload_bytes = self._oidc.verify_token(token)
            if isinstance(payload_bytes, (bytes, bytearray)):
                import json
                claims: dict[str, Any] = json.loads(payload_bytes)
            else:  # already a dict in some versions
                claims = dict(payload_bytes)

            # 2. Audience check (accept both string and list form).
            aud = claims.get("aud")
            aud_ok = (
                aud == self._expected_audience
                or (isinstance(aud, list) and self._expected_audience in aud)
            )
            if not aud_ok:
                logger.warning("JWT audience mismatch: got %r, expected %r", aud, self._expected_audience)
                return None

            # 3. Issuer check (accept v1 or v2).
            iss = claims.get("iss")
            if iss not in self._expected_issuers:
                logger.warning("JWT issuer mismatch: got %r, expected one of %r", iss, self._expected_issuers)
                return None

            # 4. Verify exp / nbf / iat with PyJWT. Signature was already
            #    checked in step 1; decode unsigned only to run the standard
            #    claim checks.
            jwt.decode(
                token,
                options={
                    "verify_signature": False,
                    "verify_exp": True,
                    "verify_nbf": True,
                    "verify_iat": True,
                    "verify_aud": False,
                    "verify_iss": False,
                },
            )
        except Exception as exc:
            logger.info("JWT validation failed: %s", exc)
            return None

        return claims
