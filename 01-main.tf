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
    features {}
}

 provider "time" {}