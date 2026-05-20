"""Base Django settings shared by dev and prod."""
from __future__ import annotations

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent

SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY", "dev-insecure-secret-change-me")
DEBUG = os.environ.get("DJANGO_DEBUG", "false").lower() in ("1", "true", "yes")

ALLOWED_HOSTS = [
    h.strip() for h in os.environ.get("ALLOWED_HOSTS", "localhost,127.0.0.1").split(",") if h.strip()
]

INSTALLED_APPS = [
    "django.contrib.contenttypes",
    "django.contrib.auth",
    "django.contrib.staticfiles",
    "corsheaders",
    "parts",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.middleware.common.CommonMiddleware",
]

ROOT_URLCONF = "partsdb.urls"
WSGI_APPLICATION = "partsdb.wsgi.application"
ASGI_APPLICATION = "partsdb.asgi.application"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {"context_processors": []},
    },
]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = False
USE_TZ = True

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

# CORS
CORS_ALLOWED_ORIGINS = [
    o.strip()
    for o in os.environ.get("ALLOWED_ORIGINS", "http://localhost:4200,https://localhost:4200").split(",")
    if o.strip()
]

# Entra ID
AZURE_AD_TENANT_ID = os.environ.get("AZURE_AD_TENANT_ID", "")
AZURE_AD_AUDIENCE = os.environ.get("AZURE_AD_AUDIENCE", "")
AZURE_AD_CLIENT_ID = os.environ.get("AZURE_AD_CLIENT_ID", "")

# mozilla-django-oidc configuration (we only use the JWKS/key handling)
OIDC_RP_SIGN_ALGO = "RS256"
OIDC_RP_CLIENT_ID = AZURE_AD_CLIENT_ID
OIDC_OP_JWKS_ENDPOINT = (
    f"https://login.microsoftonline.com/{AZURE_AD_TENANT_ID}/discovery/v2.0/keys"
    if AZURE_AD_TENANT_ID
    else ""
)
OIDC_OP_AUTHORIZATION_ENDPOINT = (
    f"https://login.microsoftonline.com/{AZURE_AD_TENANT_ID}/oauth2/v2.0/authorize"
    if AZURE_AD_TENANT_ID
    else ""
)
OIDC_OP_TOKEN_ENDPOINT = (
    f"https://login.microsoftonline.com/{AZURE_AD_TENANT_ID}/oauth2/v2.0/token"
    if AZURE_AD_TENANT_ID
    else ""
)
OIDC_OP_USER_ENDPOINT = "https://graph.microsoft.com/oidc/userinfo"
OIDC_RP_CLIENT_SECRET = ""  # not used; bearer-token validation only

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {"console": {"class": "logging.StreamHandler"}},
    "root": {"handlers": ["console"], "level": os.environ.get("DJANGO_LOG_LEVEL", "INFO")},
}
