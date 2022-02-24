terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.97.0"
    }
  }

  // using azure storage for storing backend state for terraform
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}