resource "azurerm_storage_container" "containers" {
  for_each = local.isBlockStorageSupported ? var.containers : {}

  storage_account_name  = azurerm_storage_account.storage_account.name
  name                  = each.key
  container_access_type = each.value.public_access_level
  metadata              = each.value.metadata
}
