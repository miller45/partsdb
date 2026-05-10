terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
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
