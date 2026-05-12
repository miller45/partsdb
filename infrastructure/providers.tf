terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Uncomment and configure to store state in Azure Storage
  # backend "azurerm" {
  #   resource_group_name  = "partsdb-tfstate-rg"
  #   storage_account_name = "partsdbtfstate"
  #   container_name       = "tfstate"
  #   key                  = "partsdb.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# azuread provider inherits credentials from the azurerm provider (same ARM login)
provider "azuread" {}

# Used to read the current tenant/subscription for referencing in resources
data "azurerm_client_config" "current" {}
