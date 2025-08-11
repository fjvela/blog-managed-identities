terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.39.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-managed-identites"
    storage_account_name = "stmanagedientiesglobal"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "naming" {
  source = "Azure/naming/azurerm"
}

provider "github" {
  owner = var.github_organization_name
  token = var.github_token
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

