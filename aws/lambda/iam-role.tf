#########################
# Lambda execution role #
#########################

data "aws_iam_policy_document" "lambda_assume_role" {
  count = local.execution_role_provided ? 0 : 1

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  # Create execution role if one isn't provided
  count = local.execution_role_provided ? 0 : 1

  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role_attachment" {
  count = local.execution_role_provided ? 0 : 1

  role       = aws_iam_role.lambda_iam_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_eni_management_access_attachment" {
  # Attach AWSLambdaENIManagementAccess if vpc_config is specified
  count = local.execution_role_provided ? 0 : (var.vpc_config != null ? 1 : 0)

  role       = aws_iam_role.lambda_iam_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_asynchronous_invocation_destination" {
  count = local.execution_role_provided ? 0 : (var.asynchronous_invocation != null ? 1 : 0)

  role       = aws_iam_role.lambda_iam_role[0].name
  policy_arn = aws_iam_policy.lambda_asynchronous_invocation_destination[0].arn
}

resource "aws_iam_role_policy_attachment" "active_tracing" {
  count = local.execution_role_provided ? 0 : (var.enable_active_tracing != null ? 1 : 0)

  role       = aws_iam_role.lambda_iam_role[0].name
  policy_arn = aws_iam_policy.active_tracing[0].arn
}

resource "aws_iam_role_policy_attachment" "additional_execution_role_policies" {
  for_each = local.execution_role_provided ? toset([]) : toset(var.additional_execution_role_policies)

  role       = aws_iam_role.lambda_iam_role[0].name
  policy_arn = each.key
}
