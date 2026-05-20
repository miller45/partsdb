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
