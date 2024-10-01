terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
}


provider "azurerm" {
  tenant_id                       = var.tenant_id
  subscription_id                 = var.subscription_id
  use_oidc                        = true
  resource_provider_registrations = "none"
  features {}
}