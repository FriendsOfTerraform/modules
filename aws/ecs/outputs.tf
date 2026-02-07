output "ec2_capacity_provider_arns" {
  description = <<EOT
    Map of ARNs of all EC2 capacity providers
    
    @type map(string)
    @since 1.0.0
  EOT
  value = {
    for name, provider in var.ec2_capacity_providers :
    name => aws_ecs_capacity_provider.capacity_providers[name].arn
  }
}

output "ecs_cluster_arn" {
  description = <<EOT
    The ARN of the ECS cluster
    
    @type string
    @since 1.0.0
  EOT
  value = aws_ecs_cluster.ecs_cluster.arn
}
