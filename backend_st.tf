terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.11.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.13.0"
    }
  }
}
provider "azurerm" {
    subscription_id = var.subscription_id
    features {
    }
}

provider "github" {
  owner = var.github_organization_name
  token = var.github_token
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg_st_tfstate" {
  name     = "rg-managed-identites"
  location = "West Europe"
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "st_tfstate" {
  name                     = "stmanagedientiesglobal"
  resource_group_name      = azurerm_resource_group.rg_st_tfstate.name
  location                 = azurerm_resource_group.rg_st_tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  lifecycle {
    prevent_destroy = true
  }
}
