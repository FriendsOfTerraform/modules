output "instance_arn" {
  value = aws_instance.ec2_instance.arn
}

output "instance_password_data" {
  value = aws_instance.ec2_instance.password_data
}

output "instance_primary_network_interface_id" {
  value = aws_instance.ec2_instance.primary_network_interface_id
}

output "instance_private_dns" {
  value = aws_instance.ec2_instance.private_dns
}

output "instance_public_dns" {
  value = aws_instance.ec2_instance.public_dns
}
