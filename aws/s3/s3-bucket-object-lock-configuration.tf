resource "aws_s3_bucket_object_lock_configuration" "object_lock_config" {
  count = var.enables_object_lock != null ? 1 : 0

  bucket                = aws_s3_bucket.bucket.id
  expected_bucket_owner = var.bucket_owner_account_id

  dynamic "rule" {
    for_each = var.enables_object_lock.default_retention != null ? [1] : []

    content {
      default_retention {
        days = var.enables_object_lock.default_retention.retention_days
        mode = var.enables_object_lock.default_retention.retention_mode
      }
    }
  }

  token = var.enables_object_lock.token
}
