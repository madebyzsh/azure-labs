terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-lab"
    storage_account_name = "tfstate2661228621"
    container_name       = "tfstate"
    key                  = "lab.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}
