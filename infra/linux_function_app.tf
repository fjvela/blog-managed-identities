resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name_unique
  location = local.region
  tags     = local.tags
}

resource "azurerm_storage_account" "st_func_app" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.st_func_app.account_tier
  account_replication_type = var.st_func_app.account_replication_type
}

resource "azurerm_application_insights" "appi" {
  name                = module.naming.application_insights.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "web"
}

resource "azurerm_service_plan" "func_service_plan" {
  name                = module.naming.function_app.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = var.func_service_plan.os_type
  sku_name            = var.func_service_plan.sku_name
}

resource "azurerm_linux_function_app" "func_app_linux" {
  name                = module.naming.function_app.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.st_func_app.name
  storage_account_access_key = azurerm_storage_account.st_func_app.primary_access_key
  service_plan_id            = azurerm_service_plan.func_service_plan.id

  identity {
    type = var.func_app_linux.identity.type
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key

    application_stack {
      dotnet_version              = var.func_app_linux.site_config.application_stack.dotnet_version
      use_dotnet_isolated_runtime = var.func_app_linux.site_config.application_stack.use_dotnet_isolated_runtime
    }
  }
  app_settings = {
    "KV_NAME" = module.naming.key_vault.name_unique
    "FUNCTIONS_WORKER_RUNTIME" : "dotnet-isolated"
  }
}


resource "azurerm_key_vault" "kv" {
  name                        = module.naming.key_vault.name_unique
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = var.kv.enabled_for_disk_encryption
  soft_delete_retention_days  = var.kv.soft_delete_retention_days
  purge_protection_enabled    = var.kv.purge_protection_enabled
  sku_name                    = var.kv.sku_name

  access_policy {
    tenant_id = azurerm_linux_function_app.func_app_linux.identity[0].tenant_id
    object_id = azurerm_linux_function_app.func_app_linux.identity[0].principal_id

    secret_permissions = [
      "Get",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Recover",
      "Purge"
    ]
  }

  depends_on = [
    azurerm_linux_function_app.func_app_linux
  ]
}

resource "random_password" "random_secret" {
  length  = var.kv_secret.length
  special = var.kv_secret.special
}

resource "azurerm_key_vault_secret" "kv_secret" {
  name         = var.kv_secret.name
  value        = random_password.random_secret.result
  key_vault_id = azurerm_key_vault.kv.id
}
