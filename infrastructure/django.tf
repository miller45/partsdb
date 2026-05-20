# ---------------------------------------------------------------------------
# Django backend on Linux App Service + Azure SQL Database
#
# This file provisions the second backend (Django/Python) alongside the
# existing .NET Windows App Service. After the cutover, the .NET resources
# in main.tf can be removed.
# ---------------------------------------------------------------------------

# ── Linux App Service Plan (Python) ────────────────────────────────────────
resource "azurerm_service_plan" "django" {
  name                = "${local.prefix}-django-asp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = local.common_tags
}

# ── Linux Web App – Django backend ─────────────────────────────────────────
resource "azurerm_linux_web_app" "django" {
  name                = "${local.prefix}-django-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.django.id
  https_only          = true
  tags                = local.common_tags

  # System-assigned managed identity used to authenticate to Azure SQL
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = false

    application_stack {
      python_version = "3.12"
    }

    # gunicorn entry point (matches plan Phase 6 step 22)
    app_command_line = "gunicorn partsdb.wsgi:application --bind=0.0.0.0:8000 --workers=3"

    cors {
      allowed_origins = [
        "https://${azurerm_static_web_app.frontend.default_host_name}",
      ]
      support_credentials = false
    }
  }

  app_settings = {
    # Django
    "DJANGO_SETTINGS_MODULE"         = "partsdb.settings.prod"
    "DJANGO_SECRET_KEY"              = var.django_secret_key
    "ALLOWED_HOSTS"                  = "${local.prefix}-django-api.azurewebsites.net"
    "ALLOWED_ORIGINS"                = "https://${azurerm_static_web_app.frontend.default_host_name}"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "WEBSITES_PORT"                  = "8000"

    # Entra ID / Azure AD
    "AZURE_AD_TENANT_ID" = data.azurerm_client_config.current.tenant_id
    "AZURE_AD_CLIENT_ID" = azuread_application.partsdb.client_id
    "AZURE_AD_AUDIENCE"  = "api://${data.azurerm_client_config.current.tenant_id}/${local.prefix}"

    # Azure SQL – Managed Identity auth (no password)
    "AZURE_SQL_SERVER"   = azurerm_mssql_server.partsdb.fully_qualified_domain_name
    "AZURE_SQL_DATABASE" = azurerm_mssql_database.partsdb.name
    "AZURE_SQL_USE_MSI"  = "1"
  }

  logs {
    application_logs {
      file_system_level = "Warning"
    }
  }
}

# ── Azure SQL Server ───────────────────────────────────────────────────────
resource "azurerm_mssql_server" "partsdb" {
  name                         = "${local.prefix}-sql"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = var.sql_location != "" ? var.sql_location : azurerm_resource_group.main.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  tags                         = local.common_tags

  # Use Entra ID as the primary auth path; the SQL admin user above is a
  # break-glass fallback.
  azuread_administrator {
    login_username              = var.sql_aad_admin_login
    object_id                   = var.sql_aad_admin_object_id
    azuread_authentication_only = false
  }
}

# Allow other Azure services (including the App Service) to reach the SQL
# server. For tighter isolation, replace with a Private Endpoint.
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.partsdb.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ── Azure SQL Database ─────────────────────────────────────────────────────
resource "azurerm_mssql_database" "partsdb" {
  name                 = "partsdb"
  server_id            = azurerm_mssql_server.partsdb.id
  sku_name             = var.sql_db_sku
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant       = false
  storage_account_type = "Local"
  tags                 = local.common_tags
}

# ---------------------------------------------------------------------------
# Post-deploy manual step (NOT managed by Terraform – AzureRM has no
# resource for granting an MSI access to a SQL database):
#
#   Connect to the SQL DB as the Entra AAD admin and run:
#
#     CREATE USER [partsdb-prod-django-api] FROM EXTERNAL PROVIDER;
#     ALTER ROLE db_datareader ADD MEMBER [partsdb-prod-django-api];
#     ALTER ROLE db_datawriter ADD MEMBER [partsdb-prod-django-api];
#     ALTER ROLE db_ddladmin   ADD MEMBER [partsdb-prod-django-api];
#
#   Substitute the actual App Service name (matches the principal that the
#   system-assigned identity creates in Entra). After that, the App Service
#   can authenticate via Authentication=ActiveDirectoryMsi.
# ---------------------------------------------------------------------------
