resource "aws_lambda_provisioned_concurrency_config" "provisioned_concurrencies" {
  depends_on = [aws_lambda_function.function]
  for_each   = var.concurrency != null ? var.concurrency.provisioned_concurrencies : {}

  function_name                     = var.name
  provisioned_concurrent_executions = each.value
  qualifier                         = each.key
}
