resource "aws_sqs_queue_redrive_allow_policy" "redrive_allow_policy" {
  count = var.redrive_allow_policy != null ? 1 : 0

  queue_url = aws_sqs_queue.sqs_queue.url
  redrive_allow_policy = jsonencode(merge(
    { redrivePermission = length(var.redrive_allow_policy) > 0 ? "byQueue" : "denyAll" },
    length(var.redrive_allow_policy) > 0 ? { sourceQueueArns = var.redrive_allow_policy } : {}
  ))
}
