resource "azurerm_storage_share" "file_shares" {
  for_each = local.isFileShareSupported ? var.file_shares : {}

  storage_account_name = azurerm_storage_account.storage_account.name
  name                 = each.key
  access_tier          = each.value.access_tier
  enabled_protocol     = each.value.protocol
  quota                = each.value.quota
  metadata             = each.value.metadata
}
