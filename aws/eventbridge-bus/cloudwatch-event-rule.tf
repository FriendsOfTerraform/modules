resource "aws_cloudwatch_event_rule" "event_rules" {
  for_each = var.rules

  name           = each.key
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
  event_pattern  = each.value.event_pattern
  description    = each.value.description
  state          = each.value.state

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
