output "storage_account_id" {
  description = <<EOT
    The ID of the storage account

    @type string
    @since 1.0.0
  EOT
  value = azurerm_storage_account.storage_account.id
}

output "container_ids" {
  description = <<EOT
    A map of IDs of the container

    @type map(string)
    @since 1.0.0
  EOT
  value = {
    for k, v in var.containers : k => azurerm_storage_container.containers[k].id
  }
}

output "file_share_ids" {
  description = <<EOT
    A map of IDS of the file share

    @type map(string)
    @since 1.0.0
  EOT
  value = {
    for k, v in var.file_shares : k => azurerm_storage_share.file_shares[k].id
  }
}
