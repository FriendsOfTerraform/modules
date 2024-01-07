resource "aws_lambda_function_event_invoke_config" "asynchronous_invocation_config" {
  depends_on = [aws_lambda_function.function]
  count      = var.asynchronous_invocation != null ? 1 : 0

  function_name                = var.name
  maximum_event_age_in_seconds = var.asynchronous_invocation.retries != null ? var.asynchronous_invocation.retries.maximum_event_age_in_seconds : null
  maximum_retry_attempts       = var.asynchronous_invocation.retries != null ? var.asynchronous_invocation.retries.maximum_retry_attempts : null

  dynamic "destination_config" {
    for_each = var.asynchronous_invocation.on_failure_destination_arn != null ? [1] : (
      var.asynchronous_invocation.on_success_destination_arn != null ? [1] : []
    )

    content {
      dynamic "on_failure" {
        for_each = var.asynchronous_invocation.on_failure_destination_arn != null ? [1] : []

        content {
          destination = var.asynchronous_invocation.on_failure_destination_arn
        }
      }

      dynamic "on_success" {
        for_each = var.asynchronous_invocation.on_success_destination_arn != null ? [1] : []

        content {
          destination = var.asynchronous_invocation.on_success_destination_arn
        }
      }
    }
  }
}
