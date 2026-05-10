locals {
  prefix = "${var.app_name}-${var.environment}"

  common_tags = merge(var.tags, {
    application = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  })
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------
# App Service Plan (Windows) – D1 Shared / B1 Basic are Windows SKUs
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "backend" {
  name                = "${local.prefix}-asp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Windows"
  sku_name            = var.app_service_sku
  tags                = local.common_tags
}

# ---------------------------------------------------------------------------
# App Service – .NET 9 backend API (Windows)
# ---------------------------------------------------------------------------
resource "azurerm_windows_web_app" "backend" {
  name                = "${local.prefix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.backend.id
  https_only          = true
  tags                = local.common_tags

  site_config {
    # always_on is not supported on F1/D1 (Free/Shared) tiers
    always_on = false

    application_stack {
      current_stack  = "dotnet"
      # azurerm 3.x validation only lists up to v8.0, but ASP.NET Core is
      # self-contained in the deployment package (WEBSITE_RUN_FROM_PACKAGE=1),
      # so the actual .NET 9 runtime comes from the zip, not this setting.
      dotnet_version = "v8.0"
    }

    cors {
      allowed_origins = [
        "https://${azurerm_static_web_app.frontend.default_host_name}",
      ]
      support_credentials = false
    }
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT"   = var.environment == "prod" ? "Production" : "Development"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AllowedOrigins__0"        = "https://${azurerm_static_web_app.frontend.default_host_name}"

    # Microsoft Entra ID – injected at runtime so the API can validate JWT tokens.
    # The dotnet config system maps double-underscore to the ':' separator,
    # matching the AzureAd:TenantId / AzureAd:ClientId keys in appsettings.json.
    "AzureAd__Instance" = "https://login.microsoftonline.com/"
    "AzureAd__TenantId" = data.azurerm_client_config.current.tenant_id
    "AzureAd__ClientId" = azuread_application.partsdb.client_id
    "AzureAd__Audience" = "api://${data.azurerm_client_config.current.tenant_id}/${local.prefix}"
  }

  logs {
    application_logs {
      file_system_level = "Warning"
    }
  }
}

# ---------------------------------------------------------------------------
# Static Web App – Angular SPA frontend
# ---------------------------------------------------------------------------
resource "azurerm_static_web_app" "frontend" {
  name                = "${local.prefix}-swa"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  # Free tier is sufficient for most SPAs; change to "Standard" for custom auth
  sku_tier = "Free"
  sku_size = "Free"
  tags     = local.common_tags
}
