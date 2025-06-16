variable "subscription_id" {
  description = "The Azure subscription ID where the resources will be deployed"
}

variable "github_organization_name" {
  description = "Name of the GitHub organization"
  default     = "fjvela"
}

variable "github_token" {
  description = "GitHub token with permissions to manage repository secrets"
  type        = string
  sensitive   = true
}

variable "branches" {
  description = "List of git branches to add as subject to the federated identity credential"
  default = [
    "main"
  ]
}

variable "github_repository_name" {
  description = "Name of the repository to setup the secrets needed"
  default     = "blog-managed-identities"
}

variable "st_func_app" {
  default = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

variable "func_service_plan" {
  default = {
    os_type  = "Linux"
    sku_name = "B1"
  }
}

variable "func_app_linux" {
  default = {
    identity = {
      type = "SystemAssigned"
    }

    site_config = {
      application_stack = {
        dotnet_version              = "9.0"
        use_dotnet_isolated_runtime = true
      }
    }
  }
}

variable "kv" {
  default = {
    enabled_for_disk_encryption = true
    soft_delete_retention_days  = 7
    purge_protection_enabled    = false
    sku_name                    = "standard"
  }
}

variable "kv_secret" {
  default = {
    name    = "secret-sauce"
    length  = 32
    special = true
  }
}
