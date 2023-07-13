resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_configuration" {
  count = var.lifecycle_rules != null ? 1 : 0

  bucket                = aws_s3_bucket.bucket.id
  expected_bucket_owner = var.bucket_owner_account_id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.key
      status = "Enabled"

      filter {
        dynamic "and" {
          for_each = length(distinct(values(rule.value.filter))) > 1 ? [1] : []

          content {
            object_size_greater_than = rule.value.filter.minimum_object_size
            object_size_less_than    = rule.value.filter.maximum_object_size
            prefix                   = rule.value.filter.prefix
            tags                     = rule.value.filter.object_tags
          }
        }

        object_size_greater_than = length(distinct(values(rule.value.filter))) > 1 ? null : rule.value.filter.minimum_object_size
        object_size_less_than    = length(distinct(values(rule.value.filter))) > 1 ? null : rule.value.filter.maximum_object_size
        prefix                   = length(distinct(values(rule.value.filter))) > 1 ? null : rule.value.filter.prefix
        tags                     = length(distinct(values(rule.value.filter))) > 1 ? null : rule.value.filter.object_tags
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.clean_up_incomplete_multipart_uploads_after != null ? [1] : []

        content {
          days_after_initiation = rule.value.clean_up_incomplete_multipart_uploads_after
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [1] : []

        content {
          days                         = rule.value.expiration.days_after_object_creation
          expired_object_delete_marker = rule.value.expiration.clean_up_expired_object_delete_markers
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [1] : []

        content {
          newer_noncurrent_versions = rule.value.noncurrent_version_expiration.number_of_newer_versions_to_retain
          noncurrent_days           = rule.value.noncurrent_version_expiration.days_after_objects_become_noncurrent
        }
      }

      dynamic "transition" {
        for_each = toset(rule.value.transitions)

        content {
          days          = transition.value.days_after_object_creation
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = toset(rule.value.noncurrent_version_transitions)

        content {
          newer_noncurrent_versions = noncurrent_version_transition.value.number_of_newer_versions_to_retain
          noncurrent_days           = noncurrent_version_transition.value.days_after_objects_become_noncurrent
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}
