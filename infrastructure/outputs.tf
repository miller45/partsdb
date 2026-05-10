output "resource_group_name" {
  description = "Name of the resource group containing all partsdb resources."
  value       = azurerm_resource_group.main.name
}

output "backend_api_url" {
  description = "HTTPS URL of the .NET backend API."
  value       = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "backend_app_name" {
  description = "Azure App Service name for the backend (used for deployment)."
  value       = azurerm_linux_web_app.backend.name
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
