resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration" {
  count = var.encryption_config != null ? 1 : 0

  bucket                = aws_s3_bucket.bucket.id
  expected_bucket_owner = var.bucket_owner_account_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_config.use_kms_master_key != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.encryption_config.use_kms_master_key
    }

    bucket_key_enabled = var.encryption_config.bucket_key_enabled
  }
}