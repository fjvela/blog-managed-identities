output "kv" {
  value = {
    name = azurerm_key_vault.kv.name
  }
}

output "func_app_linux" {
  value = {
    name = azurerm_linux_function_app.func_app_linux.name
  }
}
