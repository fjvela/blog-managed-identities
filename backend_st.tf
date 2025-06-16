terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}
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
