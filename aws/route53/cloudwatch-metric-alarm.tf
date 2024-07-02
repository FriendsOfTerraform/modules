locals {
  cloudwatch_alarms = flatten([
    for record_name, record_config in var.records : [
      for alarm_name, alarm_config in record_config.health_check.cloudwatch_alarms : {
        record_name            = record_name
        alarm_name             = alarm_name
        metric_name            = alarm_config.metric_name
        expression             = alarm_config.expression
        evaluation_periods     = alarm_config.evaluation_periods
        period                 = alarm_config.period
        notification_sns_topic = alarm_config.notification_sns_topic
      }
    ] if record_config.health_check != null
  ])

  comparison_operator_table = {
    ">=" = "GreaterThanOrEqualToThreshold"
    ">"  = "GreaterThanThreshold"
    "<=" = "LessThanOrEqualToThreshold"
    "<"  = "LessThanThreshold"
  }
}

resource "aws_cloudwatch_metric_alarm" "health_check_cloudwatch_alarms" {
  count = length(local.cloudwatch_alarms)

  alarm_name          = local.cloudwatch_alarms[count.index].alarm_name
  comparison_operator = local.comparison_operator_table[split(" ", local.cloudwatch_alarms[count.index].expression)[1]]
  evaluation_periods  = local.cloudwatch_alarms[count.index].evaluation_periods
  metric_name         = local.cloudwatch_alarms[count.index].metric_name
  namespace           = "AWS/Route53"
  period              = local.cloudwatch_alarms[count.index].period
  statistic           = split(" ", local.cloudwatch_alarms[count.index].expression)[0]
  threshold           = split(" ", local.cloudwatch_alarms[count.index].expression)[2]
  alarm_actions       = local.cloudwatch_alarms[count.index].notification_sns_topic != null ? [local.cloudwatch_alarms[count.index].notification_sns_topic] : null
  alarm_description   = null # TODOs
  dimensions          = { HealthCheckId = aws_route53_health_check.health_checks[local.cloudwatch_alarms[count.index].record_name].id }
  ok_actions          = local.cloudwatch_alarms[count.index].notification_sns_topic != null ? [local.cloudwatch_alarms[count.index].notification_sns_topic] : null
}
