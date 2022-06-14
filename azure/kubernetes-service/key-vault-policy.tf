data "azurerm_key_vault" "key_vault" {
  count = local.add_ons.azure_key_vault_secrets_provider_enabled ? (
    var.add_ons.azure_key_vault_secrets_provider.key_vault_name != null ? 1 : 0
  ) : 0

  name                = var.add_ons.azure_key_vault_secrets_provider.key_vault_name
  resource_group_name = data.azurerm_resource_group.current.name
}

resource "azurerm_key_vault_access_policy" "secrets_provider_access_policy" {
  count = local.add_ons.azure_key_vault_secrets_provider_enabled ? (
    var.add_ons.azure_key_vault_secrets_provider.key_vault_name != null ? 1 : 0
  ) : 0

  key_vault_id            = data.azurerm_key_vault.key_vault[0].id
  tenant_id               = data.azurerm_key_vault.key_vault[0].tenant_id
  object_id               = azurerm_kubernetes_cluster.kubernetes_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
  certificate_permissions = ["Get"]
  key_permissions         = ["Get"]
  secret_permissions      = ["Get"]
}
