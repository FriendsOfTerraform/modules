locals {
  destinations = var.notification_config == null ? {} : var.notification_config.destinations

  lambda_notifications = flatten([
    for arn in keys(local.destinations) : [
      for notification in local.destinations[arn] : {
        arn           = arn
        events        = notification.events
        filter_prefix = notification.filter_prefix
        filter_suffix = notification.filter_suffix
      } if split(":", arn)[2] == "lambda"
    ]
  ])

  sqs_notifications = flatten([
    for arn in keys(local.destinations) : [
      for notification in local.destinations[arn] : {
        arn           = arn
        events        = notification.events
        filter_prefix = notification.filter_prefix
        filter_suffix = notification.filter_suffix
      } if split(":", arn)[2] == "sqs"
    ]
  ])

  sns_notifications = flatten([
    for arn in keys(local.destinations) : [
      for notification in local.destinations[arn] : {
        arn           = arn
        events        = notification.events
        filter_prefix = notification.filter_prefix
        filter_suffix = notification.filter_suffix
      } if split(":", arn)[2] == "sns"
    ]
  ])
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count = var.notification_config != null ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  dynamic "topic" {
    for_each = toset(local.sns_notifications)

    content {
      topic_arn     = topic.key["arn"]
      events        = topic.key["events"]
      filter_prefix = topic.key["filter_prefix"]
      filter_suffix = topic.key["filter_suffix"]
    }
  }

  dynamic "queue" {
    for_each = toset(local.sqs_notifications)

    content {
      queue_arn     = queue.key["arn"]
      events        = queue.key["events"]
      filter_prefix = queue.key["filter_prefix"]
      filter_suffix = queue.key["filter_suffix"]
    }
  }

  dynamic "lambda_function" {
    for_each = toset(local.lambda_notifications)

    content {
      lambda_function_arn = lambda_function.key["arn"]
      events              = lambda_function.key["events"]
      filter_prefix       = lambda_function.key["filter_prefix"]
      filter_suffix       = lambda_function.key["filter_suffix"]
    }
  }
}
