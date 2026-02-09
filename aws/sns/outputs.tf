output "sns_topic_arn" {
  description = <<EOT
    The ARN of the SNS topic
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_sns_topic.sns_topic.arn
}

output "sns_topic_subscription_arns" {
  description = <<EOT
    The ARNs of the subscribers for this SNS topic
    
    @type string
    @since 1.0.0
  EOT
  value = length(var.subscriptions) > 0 ? {
    for k, v in aws_sns_topic_subscription.subscriptions :
    k => v.arn
  } : {}
}
