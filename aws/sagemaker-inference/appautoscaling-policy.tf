locals {
  predefined_metric_types = [
    "SageMakerInferenceComponentConcurrentRequestsPerCopyHighResolution",
    "SageMakerInferenceComponentInvocationsPerCopy",
    "SageMakerVariantConcurrentRequestsPerModelHighResolution",
    "SageMakerVariantInvocationsPerInstance",
    "SageMakerVariantProvisionedConcurrencyUtilization"
  ]

  auto_scaling_policies = flatten([
    for endpoint_name, endpoint_config in local.provisioned_endpoints : [
      for variant_name, variant_config in endpoint_config.provisioned.production_variants : [
        for policy_name, policy_config in variant_config.auto_scaling.policies : {
          endpoint_name       = endpoint_name
          variant_name        = variant_name
          policy_name         = policy_name
          auto_scaling_policy = policy_config
        }
      ] if variant_config.auto_scaling != null
    ]
  ])
}

resource "aws_appautoscaling_policy" "auto_scaling_policies" {
  for_each = tomap({ for auto_scaling_policy in local.auto_scaling_policies : "${auto_scaling_policy.endpoint_name}/${auto_scaling_policy.variant_name}/${auto_scaling_policy.policy_name}" => auto_scaling_policy })

  name               = each.key
  service_namespace  = aws_appautoscaling_target.targets["${each.value.endpoint_name}/${each.value.variant_name}"].service_namespace
  scalable_dimension = aws_appautoscaling_target.targets["${each.value.endpoint_name}/${each.value.variant_name}"].scalable_dimension
  resource_id        = aws_appautoscaling_target.targets["${each.value.endpoint_name}/${each.value.variant_name}"].resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    dynamic "customized_metric_specification" {
      for_each = contains(local.predefined_metric_types, split(" ", each.value.auto_scaling_policy.expression)[0]) ? [] : [1]

      content {
        metric_name = split(" ", each.value.auto_scaling_policy.expression)[0]
        namespace   = "AWS/SageMaker"
        statistic   = title(lower(split(" ", each.value.auto_scaling_policy.expression)[1]))

        dimensions {
          name  = "EndpointName"
          value = each.value.endpoint_name
        }

        dimensions {
          name  = "VariantName"
          value = each.value.variant_name
        }
      }
    }

    dynamic "predefined_metric_specification" {
      for_each = contains(local.predefined_metric_types, split(" ", each.value.auto_scaling_policy.expression)[0]) ? [1] : []

      content {
        predefined_metric_type = split(" ", each.value.auto_scaling_policy.expression)[0]
      }
    }

    disable_scale_in   = !each.value.auto_scaling_policy.enable_scale_in
    target_value       = reverse(split(" ", each.value.auto_scaling_policy.expression))[0]
    scale_in_cooldown  = split(" ", each.value.auto_scaling_policy.scale_in_cooldown_period)[0] * local.time_table[trimsuffix(split(" ", each.value.auto_scaling_policy.scale_in_cooldown_period)[1], "s")]
    scale_out_cooldown = split(" ", each.value.auto_scaling_policy.scale_out_cooldown_period)[0] * local.time_table[trimsuffix(split(" ", each.value.auto_scaling_policy.scale_out_cooldown_period)[1], "s")]
  }
}
