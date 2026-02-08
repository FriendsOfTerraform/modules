output "security_group_arn" {
  description = <<EOT
    ARN of the security group
    
    @type string
    @since 1.0.0
  EOT
  value = aws_security_group.security_group.arn
}

output "security_group_id" {
  description = <<EOT
    ID of the security group
    
    @type string
    @since 1.0.0
  EOT
  value = aws_security_group.security_group.id
}
