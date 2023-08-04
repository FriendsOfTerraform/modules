resource "aws_s3_bucket" "bucket" {
  bucket              = var.name
  force_destroy       = var.force_destroy
  object_lock_enabled = var.enables_object_lock != null ? (var.enables_object_lock.token == null ? true : false) : false

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
