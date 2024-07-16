resource "aws_sns_topic_policy" "access_policy" {
  count = var.access_policy != null ? 1 : 0

  arn    = aws_sns_topic.sns_topic.arn
  policy = var.access_policy
}
