resource "aws_appautoscaling_target" "targets" {
  for_each = var.auto_scaling_policies

  max_capacity       = each.value.maximum_capacity
  min_capacity       = each.value.minimum_capacity
  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster[0].id}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}
