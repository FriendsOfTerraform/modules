resource "aws_cloudwatch_event_bus_policy" "event_bus_policy" {
  count = var.policy != null ? 1 : 0

  policy         = var.policy
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
}
