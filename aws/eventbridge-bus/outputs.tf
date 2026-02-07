output "event_bus_arn" {
  description = <<EOT
    ARN of the event bus
    
    @type string
    @since 1.0.0
  EOT
  value = aws_cloudwatch_event_bus.event_bus.arn
}

output "event_bus_id" {
  description = <<EOT
    Name of the event bus
    
    @type string
    @since 1.0.0
  EOT
  value = aws_cloudwatch_event_bus.event_bus.id
}
