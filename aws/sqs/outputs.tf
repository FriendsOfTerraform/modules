output "sqs_queue_arn" {
  description = <<EOT
    The ARN of the SQS queue
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_sqs_queue.sqs_queue.arn
}

output "sqs_queue_id" {
  description = <<EOT
    The URL of the SQS queue
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_sqs_queue.sqs_queue.id
}

output "sqs_queue_url" {
  description = <<EOT
    The URL of the SQS queue. Same as `sqs_queue_id`
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_sqs_queue.sqs_queue.url
}
