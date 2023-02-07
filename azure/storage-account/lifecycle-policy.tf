resource "azurerm_storage_management_policy" "lifecycle_policies" {
  for_each = var.lifecycle_policies

  storage_account_id = azurerm_storage_account.storage_account.id

  rule {
    name    = each.key
    enabled = true

    filters {
      blob_types   = each.value.blob_types
      prefix_match = each.value.prefix_match

      dynamic "match_blob_index_tag" {
        for_each = each.value.blob_index_tags_match

        content {
          name  = match_blob_index_tag.key
          value = match_blob_index_tag.value
        }
      }
    }

    actions {
      dynamic "base_blob" {
        for_each = each.value.base_blob != null ? [1] : []

        content {
          tier_to_cool_after_days_since_modification_greater_than        = each.value.base_blob.move_to_cool_storage_after_days_since_last_modification
          tier_to_cool_after_days_since_last_access_time_greater_than    = each.value.base_blob.move_to_cool_storage_after_days_since_last_access
          tier_to_archive_after_days_since_modification_greater_than     = each.value.base_blob.move_to_archive_storage_after_days_since_last_modification
          tier_to_archive_after_days_since_last_access_time_greater_than = each.value.base_blob.move_to_archive_storage_after_days_since_last_access
          delete_after_days_since_modification_greater_than              = each.value.base_blob.delete_after_days_since_last_modification
          delete_after_days_since_last_access_time_greater_than          = each.value.base_blob.delete_after_days_since_last_access
        }
      }

      dynamic "snapshot" {
        for_each = each.value.snapshot != null ? [1] : []

        content {
          change_tier_to_archive_after_days_since_creation = each.value.snapshot.move_to_archive_storage_after_days
          change_tier_to_cool_after_days_since_creation    = each.value.snapshot.move_to_cool_storage_after_days
          delete_after_days_since_creation_greater_than    = each.value.snapshot.delete_after_days
        }
      }

      dynamic "version" {
        for_each = each.value.version != null ? [1] : []

        content {
          change_tier_to_archive_after_days_since_creation = each.value.version.move_to_archive_storage_after_days
          change_tier_to_cool_after_days_since_creation    = each.value.version.move_to_cool_storage_after_days
          delete_after_days_since_creation                 = each.value.version.delete_after_days
        }
      }
    }
  }
}