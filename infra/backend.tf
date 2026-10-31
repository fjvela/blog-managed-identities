terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.11.0"
    }
  }

  backend "azurerm" {
    # use_oidc             = true                                    # Can also be set via `ARM_USE_OIDC` environment variable.
    # use_azuread_auth     = true                                    # Can also be set via `ARM_USE_AZUREAD` environment variable.

    resource_group_name  = "rg-managed-identites"
    storage_account_name = "stmanagedientiesglobal"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  resource_providers_to_register = [
    "Microsoft.Insights",
    "Microsoft.KeyVault",
    "Microsoft.ManagedIdentity",
    "Microsoft.OperationalInsights",
    "Microsoft.Storage",
    "Microsoft.Web",
  ]

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.4"
}

data "azurerm_client_config" "current" {}

