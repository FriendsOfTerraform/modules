resource "aws_s3_bucket_policy" "bucket_policy" {
  count = var.policy != null ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  policy = var.policy
}