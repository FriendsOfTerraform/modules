output "function_arn" {
  description = <<EOT
    The ARN of the Lambda function
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  description = <<EOT
    ARN to be used for invoking Lambda Function from API Gateway
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_lambda_function.function.invoke_arn
}

output "function_qualified_arn" {
  description = <<EOT
    ARN identifying the Lambda Function Version
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_lambda_function.function.qualified_arn
}

output "function_qualified_invoke_arn" {
  description = <<EOT
    Qualified ARN (ARN with lambda version number) to be used for invoking Lambda Function from API Gateway
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_lambda_function.function.qualified_invoke_arn
}

output "function_source_code_size" {
  description = <<EOT
    Size in bytes of the function's deployment package (.zip file)
    
    @type number
    @since 1.0.0
  EOT
  value       = aws_lambda_function.function.source_code_size
}

output "function_version" {
  description = <<EOT
    Latest published version of the Lambda Function
    
    @type object
    @since 1.0.0
  EOT
  value       = aws_lambda_function.function.version
}

output "function_url_endpoint" {
  description = <<EOT
    The HTTP URL endpoint for the function
    
    @type object
    @since 1.0.0
  EOT
  value       = var.enable_function_url != null ? aws_lambda_function_url.function_url[0].function_url : null
}
