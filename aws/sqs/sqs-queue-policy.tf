resource "aws_sqs_queue_policy" "access_policy" {
  count = var.access_policy != null ? 1 : 0

  queue_url = aws_sqs_queue.sqs_queue.url
  policy    = var.access_policy
}
