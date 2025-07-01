resource "aws_appautoscaling_policy" "auto_scaling_policies" {
  for_each = var.auto_scaling_policies

  name               = each.key
  service_namespace  = aws_appautoscaling_target.targets[each.key].service_namespace
  scalable_dimension = aws_appautoscaling_target.targets[each.key].scalable_dimension
  resource_id        = aws_appautoscaling_target.targets[each.key].resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.target_metric.average_cpu_utilization_of_aurora_replicas != null ? "RDSReaderAverageCPUUtilization" : "RDSReaderAverageDatabaseConnections"
    }

    disable_scale_in   = !each.value.enable_scale_in
    target_value       = each.value.target_metric.average_cpu_utilization_of_aurora_replicas != null ? each.value.target_metric.average_cpu_utilization_of_aurora_replicas : each.value.target_metric.average_connections_of_aurora_replicas
    scale_in_cooldown  = split(" ", each.value.scale_in_cooldown_period)[0] * local.time_table[trimsuffix(split(" ", each.value.scale_in_cooldown_period)[1], "s")]
    scale_out_cooldown = split(" ", each.value.scale_out_cooldown_period)[0] * local.time_table[trimsuffix(split(" ", each.value.scale_out_cooldown_period)[1], "s")]
  }
}
