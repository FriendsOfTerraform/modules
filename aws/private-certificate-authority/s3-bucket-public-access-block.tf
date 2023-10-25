resource "aws_s3_bucket_public_access_block" "crl_bucket_bpa" {
  count = var.crl_configuration != null ? (
    var.crl_configuration.create_s3_bucket != null ? 1 : 0
  ) : 0

  bucket = aws_s3_bucket.crl_bucket[0].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
