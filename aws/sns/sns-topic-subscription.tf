locals {
  # Break endpoints out to one per object because this is what SNS expects
  subscriptions = flatten([
    for subscription in var.subscriptions : [
      for endpoint in subscription.endpoints :
      {
        protocol                    = subscription.protocol
        endpoint                    = endpoint
        dead_letter_queue_arn       = subscription.dead_letter_queue_arn
        enable_raw_message_delivery = subscription.enable_raw_message_delivery
        filter_policy               = subscription.filter_policy
        filter_policy_scope         = subscription.filter_policy_scope
        subscription_role_arn       = subscription.subscription_role_arn
      }
    ]
  ])

  # Convert subscriptions to a map to avoid having to use count
  # This is to avoid the side effect of count resulting in subsciption replacements when adding/removing subscriptions from the list
  subscription_map = {
    for subscription in local.subscriptions :
    "${subscription.protocol}/${subscription.endpoint}" => {
      dead_letter_queue_arn       = subscription.dead_letter_queue_arn
      enable_raw_message_delivery = subscription.enable_raw_message_delivery
      filter_policy               = subscription.filter_policy
      filter_policy_scope         = subscription.filter_policy_scope
      subscription_role_arn       = subscription.subscription_role_arn
    }
  }
}

resource "aws_sns_topic_subscription" "subscriptions" {
  for_each = local.subscription_map

  topic_arn             = aws_sns_topic.sns_topic.arn
  protocol              = split("/", each.key)[0]
  endpoint              = split("/", each.key)[1]
  subscription_role_arn = each.value.subscription_role_arn
  filter_policy         = each.value.filter_policy
  filter_policy_scope   = each.value.filter_policy != null ? each.value.filter_policy_scope : null
  raw_message_delivery  = each.value.enable_raw_message_delivery

  redrive_policy = each.value.dead_letter_queue_arn != null ? (
    jsonencode({
      deadLetterTargetArn = each.value.dead_letter_queue_arn
    })
  ) : null
}
