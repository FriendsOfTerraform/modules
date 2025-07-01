locals {
  cluster_instance_cloudwatch_alarms = flatten([
    for cluster_instance_name, cluster_instance_config in var.cluster_instances : [
      for alarm_name, alarm_config in cluster_instance_config.monitoring_config.cloudwatch_alarms : {
        cluster_instance_name  = cluster_instance_name
        alarm_name             = "${cluster_instance_name}-${alarm_name}"
        metric_name            = alarm_config.metric_name
        expression             = alarm_config.expression
        description            = alarm_config.description
        evaluation_periods     = alarm_config.evaluation_periods
        period                 = split(" ", alarm_config.period)[0] * local.time_table[trimsuffix(split(" ", alarm_config.period)[1], "s")]
        notification_sns_topic = alarm_config.notification_sns_topic
      }
    ]
  ])

  comparison_operator_table = {
    ">=" = "GreaterThanOrEqualToThreshold"
    ">"  = "GreaterThanThreshold"
    "<=" = "LessThanOrEqualToThreshold"
    "<"  = "LessThanThreshold"
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_instance_cloudwatch_alarms" {
  for_each = tomap({ for alarm in local.cluster_instance_cloudwatch_alarms : "${alarm.cluster_instance_name}/${alarm.alarm_name}" => alarm })

  alarm_name          = each.value.alarm_name
  comparison_operator = local.comparison_operator_table[split(" ", each.value.expression)[1]]
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/RDS"
  period              = each.value.period
  statistic           = title(lower(split(" ", each.value.expression)[0]))
  threshold           = split(" ", each.value.expression)[2]
  alarm_actions       = [each.value.notification_sns_topic]
  alarm_description   = each.value.description
  dimensions          = { DBInstanceIdentifier = aws_rds_cluster_instance.cluster_instances[each.value.cluster_instance_name].identifier }
  ok_actions          = [each.value.notification_sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "db_instance_cloudwatch_alarms" {
  for_each = var.monitoring_config.cloudwatch_alarms

  alarm_name          = "${var.name}-${each.key}"
  comparison_operator = local.comparison_operator_table[split(" ", each.value.expression)[1]]
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/RDS"
  period              = split(" ", each.value.period)[0] * local.time_table[trimsuffix(split(" ", each.value.period)[1], "s")]
  statistic           = title(lower(split(" ", each.value.expression)[0]))
  threshold           = split(" ", each.value.expression)[2]
  alarm_actions       = [each.value.notification_sns_topic]
  alarm_description   = each.value.description
  dimensions          = { DBInstanceIdentifier = aws_db_instance.db_instance[0].identifier }
  ok_actions          = [each.value.notification_sns_topic]
}
