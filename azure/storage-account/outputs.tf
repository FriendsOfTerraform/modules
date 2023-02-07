output "storage_account_id" {
  value = azurerm_storage_account.storage_account.id
}

output "container_ids" {
  value = {
    for k, v in var.containers : k => azurerm_storage_container.containers[k].id
  }
}

output "file_share_ids" {
  value = {
    for k, v in var.file_shares : k => azurerm_storage_share.file_shares[k].id
  }
}