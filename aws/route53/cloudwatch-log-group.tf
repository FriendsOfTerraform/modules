resource "aws_cloudwatch_log_group" "query_logging_cloudwatch_log_group" {
  count = var.enable_query_logging != null ? (
    var.enable_query_logging.cloudwatch_log_group_arn != null ? 0 : 1
  ) : 0

  name              = "/aws/route53/${var.domain_name}"
  log_group_class   = var.enable_query_logging.log_group_class
  retention_in_days = var.enable_query_logging.retention

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}
