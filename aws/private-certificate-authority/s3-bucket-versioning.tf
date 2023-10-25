resource "aws_s3_bucket_versioning" "crl_bucket_versioning" {
  count = var.crl_configuration != null ? (
    var.crl_configuration.create_s3_bucket != null ? (
      var.crl_configuration.create_s3_bucket.enable_versioning ? 1 : 0
    ) : 0
  ) : 0

  bucket = aws_s3_bucket.crl_bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}
