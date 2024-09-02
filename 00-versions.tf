terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.39"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.15"
    }
  }
}
