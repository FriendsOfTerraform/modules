resource "aws_s3_bucket_versioning" "versioning" {
  count = var.versioning_enabled ? 1 : 0

  bucket                = aws_s3_bucket.bucket.id
  expected_bucket_owner = var.bucket_owner_account_id

  versioning_configuration {
    status = "Enabled"
  }
}