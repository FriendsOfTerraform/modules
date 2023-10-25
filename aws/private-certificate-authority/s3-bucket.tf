resource "aws_s3_bucket" "crl_bucket" {
  count = var.crl_configuration != null ? (
    var.crl_configuration.create_s3_bucket != null ? 1 : 0
  ) : 0

  bucket        = var.crl_configuration.create_s3_bucket.bucket_name
  force_destroy = true

  tags = merge(
    local.common_tags,
    var.crl_configuration.create_s3_bucket.additional_tags,
    var.additional_tags_all
  )
}
