locals {
  auto_scaling_targets = flatten([
    for endpoint_name, endpoint_config in local.provisioned_endpoints : [
      for variant_name, variant_config in endpoint_config.provisioned.production_variants : {
        endpoint_name = endpoint_name
        variant_name  = variant_name
        auto_scaling  = variant_config.auto_scaling
      } if variant_config.auto_scaling != null
    ]
  ])
}

resource "aws_appautoscaling_target" "targets" {
  for_each   = tomap({ for auto_scaling_target in local.auto_scaling_targets : "${auto_scaling_target.endpoint_name}/${auto_scaling_target.variant_name}" => auto_scaling_target })
  depends_on = [aws_sagemaker_endpoint.provisioned_endpoints, aws_sagemaker_endpoint.serverless_endpoints]

  max_capacity       = each.value.auto_scaling.maximum_capacity
  min_capacity       = each.value.auto_scaling.minimum_capacity
  resource_id        = "endpoint/${each.value.endpoint_name}/variant/${each.value.variant_name}"
  scalable_dimension = "sagemaker:variant:DesiredInstanceCount"
  service_namespace  = "sagemaker"
}
