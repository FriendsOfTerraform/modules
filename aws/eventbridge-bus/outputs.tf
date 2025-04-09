output "event_bus_arn" {
  value = aws_cloudwatch_event_bus.event_bus.arn
}

output "event_bus_id" {
  value = aws_cloudwatch_event_bus.event_bus.id
}
