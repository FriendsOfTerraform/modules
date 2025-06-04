resource "aws_sqs_queue_redrive_policy" "redrive_policy" {
  count = var.dead_letter_queue != null ? 1 : 0

  queue_url = aws_sqs_queue.sqs_queue.url

  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dead_letter_queue.arn
    maxReceiveCount     = var.dead_letter_queue.maximum_receives
  })
}
