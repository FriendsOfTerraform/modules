locals {
  provisioned_variants_cloudwatch_alarms = flatten([
    for endpoint_name, endpoint_config in var.endpoints : [
      for variant_name, variant_config in endpoint_config.provisioned.production_variants : [
        for alarm_name, alarm_config in variant_config.cloudwatch_alarms : {
          endpoint_name    = endpoint_name
          variant_name     = variant_name
          alarm_name       = alarm_name
          cloudwatch_alarm = alarm_config
        }
      ]
    ]
  ])
}

resource "aws_cloudwatch_metric_alarm" "provisioned_variants_cloudwatch_alarms" {
  for_each = tomap({ for alarm in local.provisioned_variants_cloudwatch_alarms : "${alarm.endpoint_name}/${alarm.variant_name}/${alarm.alarm_name}" => alarm })

  alarm_name          = each.key
  comparison_operator = local.comparison_operator_table[split(" ", each.value.cloudwatch_alarm.expression)[2]]
  evaluation_periods  = each.value.cloudwatch_alarm.evaluation_periods
  metric_name         = split(" ", each.value.cloudwatch_alarm.expression)[0]
  namespace           = "AWS/SageMaker"
  period              = split(" ", each.value.cloudwatch_alarm.period)[0] * local.time_table[trimsuffix(split(" ", each.value.cloudwatch_alarm.period)[1], "s")]
  statistic           = title(lower(split(" ", each.value.cloudwatch_alarm.expression)[1]))
  threshold           = split(" ", each.value.cloudwatch_alarm.expression)[3]
  alarm_actions       = each.value.cloudwatch_alarm.notification_sns_topic != null ? [each.value.cloudwatch_alarm.notification_sns_topic] : null
  alarm_description   = each.value.cloudwatch_alarm.description
  ok_actions          = each.value.cloudwatch_alarm.notification_sns_topic != null ? [each.value.cloudwatch_alarm.notification_sns_topic] : null

  dimensions = {
    EndpointName = each.value.endpoint_name
    VariantName  = each.value.variant_name
  }

}
