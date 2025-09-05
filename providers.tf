terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0, < 4.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">=1.12.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

