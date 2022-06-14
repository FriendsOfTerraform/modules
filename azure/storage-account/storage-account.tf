resource "azurerm_storage_account" "storage_account" {
  //
  // Common config
  //

  name                     = var.name
  resource_group_name      = data.azurerm_resource_group.current.name
  location                 = local.location
  account_kind             = var.storage_account_type
  account_tier             = local.isPremiumAccessTier ? "Premium" : "Standard"
  account_replication_type = var.redundancy

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.additional_tags
  )

  //
  // blob storage configurations
  //

  cross_tenant_replication_enabled = local.isBlockStorageSupported ? var.blob_service_config.allow_cross_tenant_replication : null
  access_tier                      = local.isBlockStorageSupported ? var.blob_service_config.access_tier : null
  is_hns_enabled                   = local.isBlockStorageSupported ? var.blob_service_config.enable_hierarchical_namespace : null
  nfsv3_enabled                    = local.isBlockStorageSupported ? var.blob_service_config.enable_network_file_system_v3 : null

  dynamic "blob_properties" {
    for_each = local.isBlockStorageSupported ? [1] : []

    content {
      dynamic "delete_retention_policy" {
        for_each = var.blob_service_config.soft_delete_for_blobs != null ? (var.blob_service_config.soft_delete_for_blobs.enabled ? [1] : []) : []

        content {
          days = var.blob_service_config.soft_delete_for_blobs.retention_period
        }
      }

      versioning_enabled  = var.blob_service_config.enable_versioning
      change_feed_enabled = var.blob_service_config.enable_change_feed

      dynamic "container_delete_retention_policy" {
        for_each = var.blob_service_config.soft_delete_for_containers != null ? (var.blob_service_config.soft_delete_for_containers.enabled ? [1] : []) : []

        content {
          days = var.blob_service_config.soft_delete_for_containers.retention_period
        }
      }
    }
  }

  //
  // File config
  //

  large_file_share_enabled = local.isFileShareSupported ? (var.file_service_config != null ? var.file_service_config.enable_large_file_share : null) : null

  dynamic "share_properties" {
    for_each = local.isFileShareSupported ? (var.file_service_config != null ? [1] : []) : []

    content {
      dynamic "retention_policy" {
        for_each = var.file_service_config.soft_delete != null ? (var.file_service_config.soft_delete.enabled ? [1] : []) : []

        content {
          days = var.file_service_config.soft_delete.retention_period
        }
      }
    }
  }

  //
  // Security config
  //

  shared_access_key_enabled = var.security_config.enable_storage_account_key_access
}
