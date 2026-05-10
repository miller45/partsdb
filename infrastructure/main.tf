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
# App Service Plan (Linux) – hosts the .NET backend
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "backend" {
  name                = "${local.prefix}-asp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = local.common_tags
}

# ---------------------------------------------------------------------------
# App Service – .NET 9 backend API
# ---------------------------------------------------------------------------
resource "azurerm_linux_web_app" "backend" {
  name                = "${local.prefix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.backend.id
  https_only          = true
  tags                = local.common_tags

  site_config {
    always_on = true

    application_stack {
      dotnet_version = var.dotnet_version
    }

    cors {
      # The Static Web App URL is known only after it is created, so we
      # reference the output directly. Terraform resolves the dependency.
      allowed_origins = [
        "https://${azurerm_static_web_app.frontend.default_host_name}",
      ]
      support_credentials = false
    }
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT"        = var.environment == "prod" ? "Production" : "Development"
    "WEBSITE_RUN_FROM_PACKAGE"      = "1"
    "AllowedOrigins__0"             = "https://${azurerm_static_web_app.frontend.default_host_name}"
  }

  logs {
    http_logs {
      retention_in_days = 7
    }
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
