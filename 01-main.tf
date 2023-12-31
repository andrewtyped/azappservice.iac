terraform {
  required_version = ">=0.13"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 3.0.0"
    }
    azuread = {
        source = "hashicorp/azuread"
        version = "~> 2.0"
    }
    time = {
        source = "hashicorp/time"
        version = "~> 0.10.0"
    }
  }
}

provider "azurerm" {
    features {
      key_vault {
        purge_soft_delete_on_destroy = true
        recover_soft_deleted_key_vaults = true
      }
    }
}

 provider "time" {}

data "azuread_client_config" "current" {}