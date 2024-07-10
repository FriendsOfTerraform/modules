resource "aws_route53_query_log" "query_log" {
  count = var.enable_query_logging != null ? 1 : 0

  cloudwatch_log_group_arn = var.enable_query_logging.cloudwatch_log_group_arn != null ? var.enable_query_logging.cloudwatch_log_group_arn : aws_cloudwatch_log_group.query_logging_cloudwatch_log_group[0].arn
  zone_id                  = aws_route53_zone.hosted_zone.zone_id
}
