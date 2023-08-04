resource "aws_s3_bucket_accelerate_configuration" "transfer_accelerate" {
  count = var.transfer_acceleration_enabled ? 1 : 0

  bucket                = aws_s3_bucket.bucket.id
  expected_bucket_owner = var.bucket_owner_account_id
  status                = "Enabled"
}
