resource "aws_s3_bucket" "bucket" {
  bucket              = var.name
  object_lock_enabled = var.object_lock_enabled

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )

  force_destroy = var.force_destroy
}
