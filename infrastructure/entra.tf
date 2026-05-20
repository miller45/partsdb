# ---------------------------------------------------------------------------
# Stable UUID for the custom OAuth 2.0 permission scope
# (must be preserved across applies, so we use random_uuid with a keeper)
# ---------------------------------------------------------------------------
resource "random_uuid" "oauth2_scope_id" {}

# ---------------------------------------------------------------------------
# App Registration – covers both the Angular SPA client and the API resource
# ---------------------------------------------------------------------------
resource "azuread_application" "partsdb" {
  display_name     = "${local.prefix}-app"
  sign_in_audience = "AzureADMyOrg" # single-tenant; set to AzureADMultipleOrgs for multi-tenant

  # Application ID URI – format: api://<tenantId>/<name> satisfies the tenant's
  # default app policy without requiring a self-reference to the app's client_id.
  identifier_uris = ["api://${data.azurerm_client_config.current.tenant_id}/${local.prefix}"]

  # Expose a delegated permission scope so the SPA can request tokens for the API
  api {
    # Issue v2.0 access tokens (iss = https://login.microsoftonline.com/{tenant}/v2.0)
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${local.prefix} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${local.prefix}"
      enabled                    = true
      id                         = random_uuid.oauth2_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to access ${local.prefix} on your behalf."
      user_consent_display_name  = "Access ${local.prefix}"
      value                      = "access_as_user"
    }
  }

  # SPA platform – enables PKCE Authorization Code Flow (no client secret)
  single_page_application {
    redirect_uris = [
      "http://localhost:4200/",
      "https://${azurerm_static_web_app.frontend.default_host_name}/",
    ]
  }

  # Implicit grant disabled – PKCE is used instead (more secure for SPAs)
  web {
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }

  # Microsoft Graph – User.Read (read signed-in user's profile)
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read (delegated)
      type = "Scope"
    }
  }
}

# Service Principal – required for the app to appear in the tenant's enterprise apps
resource "azuread_service_principal" "partsdb" {
  client_id = azuread_application.partsdb.client_id
}
