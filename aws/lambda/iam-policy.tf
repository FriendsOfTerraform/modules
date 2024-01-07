################################################
# Asynchronous invocation destination policies #
################################################

resource "aws_iam_policy" "lambda_asynchronous_invocation_destination" {
  # Create IAM policy for asynchronous invocation destination if execution role isn't provided
  # and asynchronous_invocation is specified
  count = local.execution_role_provided ? 0 : (var.asynchronous_invocation != null ? 1 : 0)

  description = "Minimal permissions required for asynchronous invocation destination"
  name        = "${var.name}-async-invocation-destination-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      var.asynchronous_invocation.on_failure_destination_arn != null ? (
        [{
          Sid      = "OnFailure"
          Effect   = "Allow"
          Resource = var.asynchronous_invocation.on_failure_destination_arn

          # Action can be SNS, SQS, Lambda, EventBridge
          Action = strcontains(var.asynchronous_invocation.on_failure_destination_arn, "sns") ? "sns:Publish" : (
            strcontains(var.asynchronous_invocation.on_failure_destination_arn, "sqs") ? "sqs:SendMessage" : (
              strcontains(var.asynchronous_invocation.on_failure_destination_arn, "lambda") ? "lambda:InvokeFunction" : (
                strcontains(var.asynchronous_invocation.on_failure_destination_arn, "event-bus") ? "events:PutEvents" : []
              )
            )
          )
        }]
      ) : [],

      var.asynchronous_invocation.on_success_destination_arn != null ? (
        [{
          Sid      = "OnSuccess"
          Effect   = "Allow"
          Resource = var.asynchronous_invocation.on_success_destination_arn

          # Action can be SNS, SQS, Lambda, EventBridge
          Action = strcontains(var.asynchronous_invocation.on_success_destination_arn, "sns") ? "sns:Publish" : (
            strcontains(var.asynchronous_invocation.on_success_destination_arn, "sqs") ? "sqs:SendMessage" : (
              strcontains(var.asynchronous_invocation.on_success_destination_arn, "lambda") ? "lambda:InvokeFunction" : (
                strcontains(var.asynchronous_invocation.on_success_destination_arn, "event-bus") ? "events:PutEvents" : []
              )
            )
          )
        }]
      ) : []
    )
  })
}

#########################
# Active Tracing Policy #
#########################
resource "aws_iam_policy" "active_tracing" {
  # Create IAM policy for active tracing if execution role isn't provided
  # and active tracing is specified
  count = local.execution_role_provided ? 0 : (var.enable_active_tracing != null ? 1 : 0)

  description = "Minimal permissions required for active tracing"
  name        = "${var.name}-active-tracing-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
      Resource = "*"
    }]
  })
}
