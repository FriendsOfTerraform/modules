resource "aws_lambda_alias" "aliases" {
  depends_on = [aws_lambda_function.function]
  for_each   = var.aliases

  name             = each.key
  description      = each.value.description
  function_name    = var.name
  function_version = each.value.function_version

  dynamic "routing_config" {
    for_each = each.value.weighted_alias != null ? [1] : []

    content {
      additional_version_weights = {
        "${each.value.weighted_alias.function_version}" = each.value.weighted_alias.weight / 100
      }
    }
  }
}
