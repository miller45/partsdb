variable "app_name" {
  description = "Base name of the application. Used as a prefix for all resources."
  type        = string
  default     = "partsdb-zfx"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region where all resources will be deployed."
  type        = string
  default     = "northeurope"
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan (e.g. B1, B2, S1, P1v3)."
  type        = string
  default     = "B1"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Django backend – Azure SQL
# ---------------------------------------------------------------------------
variable "django_secret_key" {
  description = "Django SECRET_KEY (use a long random string). Provide via terraform.tfvars or env TF_VAR_django_secret_key."
  type        = string
  sensitive   = true
}

variable "sql_admin_login" {
  description = "Break-glass SQL Server administrator login (rarely used – prefer AAD admin)."
  type        = string
  default     = "partsdbadmin"
}

variable "sql_admin_password" {
  description = "Break-glass SQL Server administrator password."
  type        = string
  sensitive   = true
}

variable "sql_aad_admin_login" {
  description = "Entra ID (Azure AD) user/group that is the SQL Server admin."
  type        = string
}

variable "sql_aad_admin_object_id" {
  description = "Object ID of the Entra ID user/group set as SQL Server admin."
  type        = string
}

variable "sql_db_sku" {
  description = "Azure SQL Database SKU (e.g. Basic, S0, GP_S_Gen5_1 for serverless)."
  type        = string
  default     = "Basic"
}

variable "sql_location" {
  description = "Azure region for the SQL Server / Database. Defaults to var.location, but some subscriptions are restricted from provisioning Azure SQL in certain regions (westeurope) – set this to e.g. 'northeurope' or 'francecentral' to override."
  type        = string
  default     = "northeurope"
}
