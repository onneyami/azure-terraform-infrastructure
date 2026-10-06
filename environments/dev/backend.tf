terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-andrei"
    storage_account_name = "sttfstatedev2026" # Replace with your state storage account
    container_name       = "tfstate"
    key                  = "dev.aks.tfstate"
  }
}

provider "azurerm" {
  features {}
}