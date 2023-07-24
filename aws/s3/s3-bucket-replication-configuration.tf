resource "aws_s3_bucket_replication_configuration" "replication_configurations" {
  count = var.replication_config != null ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  role   = var.replication_config.iam_role_arn != null ? var.replication_config.iam_role_arn : aws_iam_role.bucket_replication_role[0].arn

  dynamic "rule" {
    for_each = var.replication_config.rules

    content {
      dynamic "delete_marker_replication" {
        for_each = rule.value.additional_replication_options != null ? (rule.value.additional_replication_options.delete_marker_replication_enabled ? [1] : []) : []

        content {
          status = "Enabled"
        }
      }

      destination {
        dynamic "access_control_translation" {
          for_each = rule.value.change_object_ownership_to_destination_bucket_owner != null ? [1] : []

          content {
            owner = "Destination"
          }
        }

        account = rule.value.change_object_ownership_to_destination_bucket_owner != null ? rule.value.change_object_ownership_to_destination_bucket_owner.destination_account_id : null
        bucket  = rule.value.destination_bucket_arn

        dynamic "encryption_configuration" {
          for_each = rule.value.replicate_encrypted_objects != null ? [1] : []

          content {
            replica_kms_key_id = rule.value.replicate_encrypted_objects.kms_key_for_encrypting_destination_objects
          }
        }

        dynamic "metrics" {
          for_each = rule.value.additional_replication_options != null ? (rule.value.additional_replication_options.replication_metrics_enabled ? [1] : []) : []

          content {
            status = "Enabled"

            event_threshold {
              minutes = 15
            }
          }
        }

        dynamic "replication_time" {
          for_each = rule.value.additional_replication_options != null ? (rule.value.additional_replication_options.replication_time_control_enabled ? [1] : []) : []

          content {
            status = "Enabled"

            time {
              minutes = 15
            }
          }
        }

        storage_class = rule.value.destination_storage_class
      }

      filter {
        dynamic "and" {
          for_each = rule.value.filter != null ? (
            rule.value.filter.object_tags != null ? (
              length(rule.value.filter.object_tags) > 1 ? [1] : (
                length({ for k, v in rule.value.filter : k => v if v != null }) > 1 ? [1] : []
              )
            ) : length({ for k, v in rule.value.filter : k => v if v != null }) > 1 ? [1] : []
          ) : []

          content {
            prefix = rule.value.filter.prefix
            tags   = rule.value.filter.object_tags
          }
        }

        prefix = rule.value.filter != null ? (
          rule.value.filter.object_tags != null ? (
            length(rule.value.filter.object_tags) > 1 ? null : (
              length({ for k, v in rule.value.filter : k => v if v != null }) > 1 ? null : rule.value.filter.prefix
            )
          ) : length({ for k, v in rule.value.filter : k => v if v != null }) > 1 ? null : rule.value.filter.prefix
        ) : null

        dynamic "tag" {
          for_each = rule.value.filter != null ? (
            rule.value.filter.object_tags != null ? (
              length(rule.value.filter.object_tags) > 1 ? {} : (
                length({ for k, v in rule.value.filter : k => v if v != null }) > 1 ? {} : rule.value.filter.object_tags
              )
            ) : {}
          ) : {}

          content {
            key   = tag.key
            value = tag.value
          }
        }
      }

      id       = rule.key
      priority = rule.value.priority

      dynamic "source_selection_criteria" {
        for_each = rule.value.additional_replication_options != null ? [1] : rule.value.replicate_encrypted_objects != null ? [1] : []

        content {
          dynamic "replica_modifications" {
            for_each = rule.value.additional_replication_options != null ? (
              rule.value.additional_replication_options.replica_modification_sync_enabled ? [1] : []
            ) : []

            content {
              status = "Enabled"
            }
          }

          dynamic "sse_kms_encrypted_objects" {
            for_each = rule.value.replicate_encrypted_objects != null ? [1] : []

            content {
              status = "Enabled"
            }
          }
        }
      }

      status = "Enabled"
    }
  }

  token = var.replication_config.token
}
