output "sns_topic_arn" {
  value = aws_sns_topic.sns_topic.arn
}

output "sns_topic_subscription_arns" {
  value = length(var.subscriptions) > 0 ? {
    for k, v in aws_sns_topic_subscription.subscriptions :
    k => v.arn
  } : {}
}
