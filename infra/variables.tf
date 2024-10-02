variable "subscription_id" {
  description = "The Azure subscription ID where the resources will be deployed"
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
        dotnet_version              = "8.0"
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
