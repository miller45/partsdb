output "resource_group_name" {
  description = "Name of the resource group containing all partsdb resources."
  value       = azurerm_resource_group.main.name
}

output "frontend_url" {
  description = "HTTPS URL of the Angular Static Web App."
  value       = "https://${azurerm_static_web_app.frontend.default_host_name}"
}

output "static_web_app_api_key" {
  description = "Deployment token for the Angular Static Web App (use in CI/CD)."
  value       = azurerm_static_web_app.frontend.api_key
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Entra ID / OIDC – values needed in the Angular environment files
# ---------------------------------------------------------------------------
output "entra_tenant_id" {
  description = "Azure AD Tenant ID. Set as environment.auth.tenantId in the Angular app."
  value       = data.azurerm_client_config.current.tenant_id
}

output "entra_client_id" {
  description = "Client (Application) ID of the Entra app registration."
  value       = azuread_application.partsdb.client_id
}

output "entra_scope" {
  description = "Full scope URI the Angular app must request when calling the backend API."
  value       = "api://${data.azurerm_client_config.current.tenant_id}/${local.prefix}/access_as_user"
}

# ---------------------------------------------------------------------------
# Django backend
# ---------------------------------------------------------------------------
output "django_backend_url" {
  description = "HTTPS URL of the Django backend API."
  value       = "https://${azurerm_linux_web_app.django.default_hostname}"
}

output "django_backend_app_name" {
  description = "Azure App Service name for the Django backend (used for deployment)."
  value       = azurerm_linux_web_app.django.name
}

output "django_backend_principal_id" {
  description = "Principal (object) ID of the Django App Service managed identity. Grant DB access to this principal."
  value       = azurerm_linux_web_app.django.identity[0].principal_id
}

output "sql_server_fqdn" {
  description = "Fully-qualified DNS name of the Azure SQL Server."
  value       = azurerm_mssql_server.partsdb.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Azure SQL Database name."
  value       = azurerm_mssql_database.partsdb.name
}
