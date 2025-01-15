resource "aws_iam_role" "flow_logs_cloudwatch_logs_service_role" {
  count = length(local.vpc_flow_logs_with_cloudwatch_logs_destination_service_roles) > 0 ? 1 : (length(local.subnet_flow_logs_with_cloudwatch_logs_destination_service_roles) > 0 ? 1 : 0)

  name = "vpc-flow-logs-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flow_logs_cloudwatch_logs_service_role" {
  count = length(local.vpc_flow_logs_with_cloudwatch_logs_destination_service_roles) > 0 ? 1 : (length(local.subnet_flow_logs_with_cloudwatch_logs_destination_service_roles) > 0 ? 1 : 0)

  role       = aws_iam_role.flow_logs_cloudwatch_logs_service_role[0].name
  policy_arn = aws_iam_policy.flow_logs_cloudwatch_logs_service_role[0].arn
}
