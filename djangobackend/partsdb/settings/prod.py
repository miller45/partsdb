"""Production settings: Azure SQL via mssql-django."""
from __future__ import annotations

import os

from .base import *  # noqa: F401,F403

DEBUG = False

AZURE_SQL_SERVER = os.environ["AZURE_SQL_SERVER"]
AZURE_SQL_DATABASE = os.environ["AZURE_SQL_DATABASE"]
AZURE_SQL_USE_MSI = os.environ.get("AZURE_SQL_USE_MSI", "0") == "1"

_options: dict[str, str] = {"driver": "ODBC Driver 18 for SQL Server"}
if AZURE_SQL_USE_MSI:
    # Managed Identity: no user/password
    _options["extra_params"] = "Authentication=ActiveDirectoryMsi;Encrypt=yes"
    _db_user = ""
    _db_password = ""
else:
    _options["extra_params"] = "Encrypt=yes"
    _db_user = os.environ["AZURE_SQL_USER"]
    _db_password = os.environ["AZURE_SQL_PASSWORD"]

DATABASES = {
    "default": {
        "ENGINE": "mssql",
        "NAME": AZURE_SQL_DATABASE,
        "HOST": AZURE_SQL_SERVER,
        "PORT": "1433",
        "USER": _db_user,
        "PASSWORD": _db_password,
        "OPTIONS": _options,
    }
}

# Security hardening for production
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SECURE_SSL_REDIRECT = os.environ.get("SECURE_SSL_REDIRECT", "false").lower() == "true"
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
