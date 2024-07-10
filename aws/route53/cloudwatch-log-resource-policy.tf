resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  count = var.enable_query_logging != null ? (
    var.enable_query_logging.cloudwatch_log_group_arn != null ? 0 : (var.enable_query_logging.create_resource_policy ? 1 : 0)
  ) : 0

  policy_name = "AWSServiceRoleForRoute53"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Route53LogsToCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    ]
  })
}
