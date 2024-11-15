resource "aws_s3_bucket_ownership_controls" "object_ownership" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}
