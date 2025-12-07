terraform {
  required_version = ">= 1.0.0" 
  required_providers {
    azurerm= {
        source = "hashicorp/azurerm"
        version = "~> 4.55"
    }
  }
backend "azurerm" {
  } 
}


provider "azurerm" {
  subscription_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  features {}
}
