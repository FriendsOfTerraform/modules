resource "aws_s3_bucket_intelligent_tiering_configuration" "intelligent_tiering_configuration" {
  for_each = var.intelligent_tiering_archive_configurations

  bucket = aws_s3_bucket.bucket.id
  name   = each.key
  status = "Enabled"

  dynamic "filter" {
    for_each = each.value.filter != null ? [1] : []

    content {
      prefix = each.value.filter.prefix
      tags   = each.value.filter.object_tags
    }
  }

  tiering {
    access_tier = each.value.access_tier
    days        = each.value.days_until_transition
  }
}