"""Development settings: SQLite, DEBUG=True."""
import os

from .base import *  # noqa: F401,F403

DEBUG = True
ALLOWED_HOSTS = ["*"]

# Entra ID dev defaults — match angularapp/src/environments/environment.ts.
# Override via env vars (AZURE_AD_TENANT_ID, AZURE_AD_CLIENT_ID,
# AZURE_AD_AUDIENCE) if you point dev at a different app registration.
AZURE_AD_TENANT_ID = os.environ.get(
    "AZURE_AD_TENANT_ID", "9724bf58-84e1-4bde-9e1c-29e2fc60d72c"
)
AZURE_AD_CLIENT_ID = os.environ.get(
    "AZURE_AD_CLIENT_ID", "654aab0f-fd87-4b7f-a392-cb4e0aa4c9d0"
)
AZURE_AD_AUDIENCE = os.environ.get(
    "AZURE_AD_AUDIENCE",
    f"api://{AZURE_AD_TENANT_ID}/partsdb-zfx-prod",
)

# Re-derive OIDC endpoints with the now-populated tenant id.
OIDC_RP_CLIENT_ID = AZURE_AD_CLIENT_ID
OIDC_OP_JWKS_ENDPOINT = (
    f"https://login.microsoftonline.com/{AZURE_AD_TENANT_ID}/discovery/v2.0/keys"
)
OIDC_OP_AUTHORIZATION_ENDPOINT = (
    f"https://login.microsoftonline.com/{AZURE_AD_TENANT_ID}/oauth2/v2.0/authorize"
)
OIDC_OP_TOKEN_ENDPOINT = (
    f"https://login.microsoftonline.com/{AZURE_AD_TENANT_ID}/oauth2/v2.0/token"
)
