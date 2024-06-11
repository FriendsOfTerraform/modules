output "ec2_capacity_provider_arns" {
  value = {
    for name, provider in var.ec2_capacity_providers :
    name => aws_ecs_capacity_provider.capacity_providers[name].arn
  }
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.ecs_cluster.arn
}
