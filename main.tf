locals {
  formatted_display_name = startswith(lower(var.name), "uai") ? var.name : "uai-${var.name}"
}

resource "azurerm_user_assigned_identity" "this" {
  location            = var.location
  name                = local.formatted_display_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id         = azurerm_user_assigned_identity.this.principal_id
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
}

resource "azurerm_key_vault_secret" "client_id" {
  name         = "${local.formatted_display_name}-clientid"
  value        = azurerm_user_assigned_identity.this.client_id
  content_type = "Managed by Terraform."
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "principal_id" {
  name         = "${local.formatted_display_name}-principalid"
  value        = azurerm_user_assigned_identity.this.principal_id
  content_type = "Managed by Terraform."
  key_vault_id = var.key_vault_id
}

resource "azurerm_federated_identity_credential" "github" {
  for_each = var.github_federated_credentials

  name                      = "${each.value.repository_name}-branch-${each.value.branch_name}"
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  user_assigned_identity_id = azurerm_user_assigned_identity.this.id
  subject                   = "repo:Azure-At-Night/${each.value.repository_name}:ref:refs/heads/${each.value.branch_name}"
}
