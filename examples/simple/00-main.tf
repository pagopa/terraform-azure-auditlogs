terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.39"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfinfdevopslab"
  #   container_name       = "terraform-state"
  #   key                  = "terraform-azure-auditlogs.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_id" "unique" {
  byte_length = 3
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

locals {
  project = "${var.prefix}-${random_id.unique.hex}"
}
