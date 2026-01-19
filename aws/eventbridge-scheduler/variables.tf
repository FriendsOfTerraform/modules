variable "name" {
  type        = string
  description = <<EOT
    The name of the schedule group
    
    @since 1.0.0
  EOT
}

variable "schedules" {
  type = map(object({
    /// The description of the schedule
    /// 
    /// @since 1.0.0
    description = optional(string, null)
    /// ARN for the customer managed KMS key that EventBridge Scheduler will use to encrypt and decrypt your data
    /// 
    /// @since 1.0.0
    kms_key_arn = optional(string, null)
    /// Specifies whether the schedule is enabled or disabled. Valid values: `"ENABLED"`, `"DISABLED"`
    /// 
    /// @since 1.0.0
    state       = optional(string, "ENABLED")

    /// Define a one-time, or recurring invocation for the schedule. Must define one of: `one_time_schedule`, `rate_based_schedule`, `cron_based_schedule`
    /// 
    /// @since 1.0.0
    schedule_pattern = object({
      /// Specify the time window that Scheduler invokes your schedule within, in minutes. For example, if you choose 15 minutes, your schedule runs within 15 minutes after the schedule start time. Valid value: `1` to `1440` minutes
      /// 
      /// @since 1.0.0
      flexible_time_window = optional(number, null)
      /// Timezone in which the scheduling expression is evaluated. For example: `"America/Los_Angeles"`
      /// 
      /// @since 1.0.0
      time_zone            = optional(string, "UTC")
      /// The date, in UTC, after which the schedule can begin invoking its target. Depending on the schedule's recurrence expression, invocations might occur on, or after, the start date you specify. EventBridge Scheduler ignores the start date for one-time schedules. Example: `"2030-01-01T01:00:00Z"`
      /// 
      /// @since 1.0.0
      start_date_and_time  = optional(string, null)
      /// The date, in UTC, before which the schedule can invoke its target. Depending on the schedule's recurrence expression, invocations might stop on, or before, the end date you specify. EventBridge Scheduler ignores the end date for one-time schedules. Example: `"2030-01-01T01:00:00Z"`
      /// 
      /// @since 1.0.0
      end_date_and_time    = optional(string, null)

      /// A one-time schedule invokes it's target only once at the date, time, and in the time zone that you provide
      /// 
      /// @since 1.0.0
      one_time_schedule = optional(object({
        /// The date and time this schedule run, in `yyyy-mm-ddThh:mm:ss` format. For example: `"2030-01-01T01:00:00"`
        /// 
        /// @since 1.0.0
        date_and_time = string # yyyy-mm-ddThh:mm:ss
      }), null)

      /// A rate-based schedule runs at a regular rate, such as every 10 minutes
      /// 
      /// @since 1.0.0
      rate_based_schedule = optional(object({
        /// The rate to invoke this trigger, in `value unit` format. For example: `"1 hour"`
        /// 
        /// @since 1.0.0
        rate_expression = string # value unit
      }), null)

      /// A schedule set using a cron expression that runs at a specific time, such as every day 1 of the month, at 12:00AM.
      /// 
      /// @since 1.0.0
      cron_based_schedule = optional(object({
        /// Specify the cron expression for the schedule, for example: `"0 0 1 * *"`
        /// 
        /// @since 1.0.0
        cron_expression = string
      }), null)
    })

    /// A target is an AWS API operation that EventBridge Scheduler invokes at the time and using the pattern that you specify when you configure your schedule
    /// 
    /// @since 1.0.0
    target = object({
      /// The AWS API to invoke. For example: `"lambda:invoke"`, `"ecs:runTask"`. Please refer to [this documentation][eventbridge-scheduler-universal-target] for more details.
      /// 
      /// @since 1.0.0
      aws_api_action = string
      /// A JSON document containing the parameters to pass into the API. The available options depend on the AWS API to invoke, please refer to their respective API reference for valid values. For example: [lambda:invoke][lambda-invoke-api-reference]
      /// 
      /// @since 1.0.0
      input          = string
      /// The ARN of an IAM role EventBridge Scheduler assumes to send events to the target
      /// 
      /// @since 1.0.0
      iam_role_arn   = optional(string, null)

      /// Configures retry policy and dead-letter queue
      /// 
      /// @since 1.0.0
      retry_policy = optional(object({
        /// The age in seconds to continue to make retry attempts.
        /// 
        /// @since 1.0.0
        maximum_age_of_event = optional(number, 86400)
        /// The maximum number of retry attempts to make before the request fails
        /// 
        /// @since 1.0.0
        retry_attempts       = optional(number, 185)
        /// The ARN of the SQS queue specified as the target for the dead-letter queue.
        /// 
        /// @since 1.0.0
        dead_letter_queue    = optional(string, null)
      }), {})
    })
  }))
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Manage multiple schedules for the group. Please [see example](#basic-usage)
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for the schedule group
    
    @since 1.0.0
  EOT
  default     = {}
}
