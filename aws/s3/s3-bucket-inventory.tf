resource "aws_s3_bucket_inventory" "inventories" {
  for_each = var.inventory_config

  bucket                   = aws_s3_bucket.bucket.id
  name                     = each.key
  included_object_versions = each.value.include_noncurrent_objects ? "All" : "Current"

  schedule {
    frequency = each.value.frequency
  }

  destination {
    bucket {
      account_id = each.value.destination != null ? each.value.destination.account_id : null
      bucket_arn = each.value.destination != null ? (each.value.destination.bucket_arn != null ? each.value.destination.bucket_arn : aws_s3_bucket.bucket.arn) : aws_s3_bucket.bucket.arn
      format     = each.value.output_format

      dynamic "encryption" {
        for_each = each.value.encrypt_inventory_report != null ? [1] : []

        content {
          dynamic "sse_kms" {
            for_each = each.value.encrypt_inventory_report.kms_key_id != null ? [1] : []

            content {
              key_id = each.value.encrypt_inventory_report.kms_key_id
            }
          }

          dynamic "sse_s3" {
            for_each = each.value.encrypt_inventory_report.kms_key_id != null ? [] : [1]

            content {}
          }
        }
      }
    }
  }

  dynamic "filter" {
    for_each = each.value.filter != null ? [1] : []

    content {
      prefix = each.value.filter.prefix
    }
  }

  optional_fields = each.value.additional_metadata_fields
}
