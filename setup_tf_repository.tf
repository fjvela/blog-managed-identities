resource "azurerm_user_assigned_identity" "uid" {
  name                = "gh-${var.github_organization_name}-${var.github_repository_name}"
  resource_group_name = azurerm_resource_group.rg_st_tfstate.name
  location            = azurerm_resource_group.rg_st_tfstate.location
}

resource "azurerm_federated_identity_credential" "federated_identity_credential" {
  for_each                  = toset(var.branches)
  name                      = "gh-${var.github_organization_name}-${var.github_repository_name}-${each.value}"
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  user_assigned_identity_id = azurerm_user_assigned_identity.uid.id
  subject                   = "repo:${var.github_organization_name}/${var.github_repository_name}:ref:refs/heads/${each.value}"
}

resource "azurerm_role_assignment" "uid_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.uid.principal_id
  principal_type       = "ServicePrincipal"
}

# GitHub Setup
data "github_repository" "this" {
  name = var.github_repository_name
}

resource "github_actions_secret" "azure_client_id" {
  repository      = data.github_repository.this.name
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azurerm_user_assigned_identity.uid.client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository      = data.github_repository.this.name
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_subscription.current.tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = data.github_repository.this.name
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}
