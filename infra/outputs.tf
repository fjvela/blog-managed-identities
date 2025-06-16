output "kv" {
  value = {
    name           = azurerm_key_vault.kv.name
    resource_group = azurerm_key_vault.kv.resource_group_name
  }
}

output "func_app_linux" {
  value = {
    name           = azurerm_linux_function_app.func_app_linux.name
    resource_group = azurerm_linux_function_app.func_app_linux.resource_group_name
  }
}
