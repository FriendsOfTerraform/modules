locals {
  vpc_flow_logs_with_cloudwatch_logs_destination                  = { for k, v in var.flow_logs : k => v if v.destination.cloudwatch_logs != null }
  vpc_flow_logs_with_cloudwatch_logs_destination_service_roles    = { for k, v in local.vpc_flow_logs_with_cloudwatch_logs_destination : k => v if v.destination.cloudwatch_logs.service_role_arn == null }
  subnet_flow_logs_with_cloudwatch_logs_destination               = { for flow_log in local.subnet_flow_logs : "${flow_log.subnet_name}-${flow_log.flow_log_name}" => flow_log if flow_log.destination.cloudwatch_logs != null }
  subnet_flow_logs_with_cloudwatch_logs_destination_service_roles = { for k, v in local.subnet_flow_logs_with_cloudwatch_logs_destination : k => v if v.destination.cloudwatch_logs.service_role_arn == null }
}

resource "aws_iam_policy" "flow_logs_cloudwatch_logs_service_role" {
  count = length(local.vpc_flow_logs_with_cloudwatch_logs_destination_service_roles) > 0 ? 1 : (length(local.subnet_flow_logs_with_cloudwatch_logs_destination_service_roles) > 0 ? 1 : 0)

  name = "vpc-flow-logs-${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}
