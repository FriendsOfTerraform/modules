resource "aws_cloudwatch_event_bus" "event_bus" {
  name               = var.name
  description        = var.description
  kms_key_identifier = var.kms_key_arn

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
