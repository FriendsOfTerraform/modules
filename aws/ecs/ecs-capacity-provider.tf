resource "aws_ecs_capacity_provider" "capacity_providers" {
  for_each = var.ec2_capacity_providers

  name = each.key

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_autoscaling_groups[each.key].arn

    managed_draining = each.value.enable_managed_scaling != null ? (
      each.value.enable_managed_scaling.enable_managed_scaling_draining ? "ENABLED" : "DISABLED"
    ) : "DISABLED"

    managed_termination_protection = each.value.enable_managed_scaling != null ? (
      each.value.enable_managed_scaling.enable_scale_in_protection ? "ENABLED" : "DISABLED"
    ) : "DISABLED"

    dynamic "managed_scaling" {
      for_each = each.value.enable_managed_scaling != null ? [1] : []

      content {
        status          = "ENABLED"
        target_capacity = each.value.enable_managed_scaling.target_capacity_percent
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = concat(
    var.enable_fargate_capacity_provider ? ["FARGATE", "FARGATE_SPOT"] : [],
    keys(aws_ecs_capacity_provider.capacity_providers)
  )

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy

    content {
      base              = default_capacity_provider_strategy.value.base
      weight            = default_capacity_provider_strategy.value.weight
      capacity_provider = default_capacity_provider_strategy.key
    }
  }
}
