output "function_arn" {
  value = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}

output "function_qualified_arn" {
  value = aws_lambda_function.function.qualified_arn
}

output "function_qualified_invoke_arn" {
  value = aws_lambda_function.function.qualified_invoke_arn
}

output "function_source_code_size" {
  value = aws_lambda_function.function.source_code_size
}

output "function_version" {
  value = aws_lambda_function.function.version
}

output "function_url_endpoint" {
  value = var.enable_function_url != null ? aws_lambda_function_url.function_url[0].function_url : null
}
