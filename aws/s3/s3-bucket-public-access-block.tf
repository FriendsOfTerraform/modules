resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count = var.public_access_block != null ? 1 : 0

  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}