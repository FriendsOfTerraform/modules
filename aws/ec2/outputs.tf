output "instance_arn" {
  description = <<EOT
    The ARN of the EC2 instance
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_instance.ec2_instance.arn
}

output "instance_password_data" {
  description = <<EOT
    Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for instances running Microsoft Windows. This attribute is only exported if `get_windows_password = true`
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_instance.ec2_instance.password_data
}

output "instance_primary_network_interface_id" {
  description = <<EOT
    ID of the instance's primary network interface
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_instance.ec2_instance.primary_network_interface_id
}

output "instance_private_dns" {
  description = <<EOT
    Private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC
    
    @type string
    @since 1.1.0
  EOT
  value       = aws_instance.ec2_instance.private_dns
}

output "instance_public_dns" {
  description = <<EOT
    Public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC.
    
    @type string
    @since 1.1.0
  EOT
  value       = aws_instance.ec2_instance.public_dns
}
