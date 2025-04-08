resource "aws_scheduler_schedule" "schedules" {
  for_each = var.schedules

  description                  = each.value.description
  end_date                     = each.value.schedule_pattern.end_date_and_time
  group_name                   = aws_scheduler_schedule_group.schedule_group.name
  kms_key_arn                  = each.value.kms_key_arn
  name                         = each.key
  schedule_expression_timezone = each.value.schedule_pattern.time_zone
  start_date                   = each.value.schedule_pattern.start_date_and_time
  state                        = each.value.state

  flexible_time_window {
    maximum_window_in_minutes = each.value.schedule_pattern.flexible_time_window
    mode                      = each.value.schedule_pattern.flexible_time_window != null ? "FLEXIBLE" : "OFF"
  }

  schedule_expression = each.value.schedule_pattern.one_time_schedule != null ? "at(${each.value.schedule_pattern.one_time_schedule.date_and_time})" : (
    each.value.schedule_pattern.rate_based_schedule != null ? "rate(${each.value.schedule_pattern.rate_based_schedule.rate_expression})" : (
      each.value.schedule_pattern.cron_based_schedule != null ? "cron(${each.value.schedule_pattern.cron_based_schedule.cron_expression})" : null
    )
  )

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:${each.value.target.aws_api_action}"
    input    = each.value.target.input
    role_arn = each.value.target.iam_role_arn

    dynamic "retry_policy" {
      for_each = each.value.target.retry_policy != null ? [1] : []

      content {
        maximum_event_age_in_seconds = each.value.target.retry_policy.maximum_age_of_event
        maximum_retry_attempts       = each.value.target.retry_policy.retry_attempts
      }
    }

    dynamic "dead_letter_config" {
      for_each = each.value.target.retry_policy != null ? (each.value.target.retry_policy.dead_letter_queue != null ? [1] : []) : []

      content {
        arn = each.value.target.retry_policy.dead_letter_queue
      }
    }
  }
}
