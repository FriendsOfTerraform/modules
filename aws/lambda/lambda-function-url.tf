resource "aws_lambda_function_url" "function_url" {
  depends_on = [aws_lambda_function.function]
  count      = var.enable_function_url != null ? 1 : 0

  authorization_type = var.enable_function_url.auth_type
  function_name      = var.name
  invoke_mode        = var.enable_function_url.invoke_mode

  dynamic "cors" {
    for_each = var.enable_function_url.cors_config != null ? [1] : []

    content {
      allow_credentials = var.enable_function_url.cors_config.allow_credentials
      allow_headers     = var.enable_function_url.cors_config.allow_headers
      allow_methods     = var.enable_function_url.cors_config.allow_methods
      allow_origins     = var.enable_function_url.cors_config.allow_origins
      expose_headers    = var.enable_function_url.cors_config.expose_headers
      max_age           = var.enable_function_url.cors_config.max_age_seconds
    }
  }
}
