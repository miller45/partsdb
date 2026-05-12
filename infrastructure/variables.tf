variable "app_name" {
  description = "Base name of the application. Used as a prefix for all resources."
  type        = string
  default     = "partsdb"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region where all resources will be deployed."
  type        = string
  default     = "westeurope"
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan (e.g. B1, B2, S1, P1v3)."
  type        = string
  default     = "B1"
}

variable "dotnet_version" {
  description = "The .NET runtime version for the App Service."
  type        = string
  default     = "9.0"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
