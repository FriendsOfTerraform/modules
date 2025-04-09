variable "name" {
  type        = string
  description = "The name of the event bus. All associated resources' names will also be prefixed by this value"
}

variable "schedules" {
  type = map(object({
    description = optional(string, null)
    kms_key_arn = optional(string, null)
    state       = optional(string, "ENABLED")

    schedule_pattern = object({
      flexible_time_window = optional(number, null)
      time_zone            = optional(string, "UTC")
      start_date_and_time  = optional(string, null)
      end_date_and_time    = optional(string, null)

      one_time_schedule = optional(object({
        date_and_time = string # yyyy-mm-ddThh:mm:ss
      }), null)

      rate_based_schedule = optional(object({
        rate_expression = string # value unit
      }), null)

      cron_based_schedule = optional(object({
        cron_expression = string
      }), null)
    })

    target = object({
      aws_api_action = string
      input          = string
      iam_role_arn   = optional(string, null)

      retry_policy = optional(object({
        maximum_age_of_event = optional(number, 86400)
        retry_attempts       = optional(number, 185)
        dead_letter_queue    = optional(string, null)
      }), {})
    })
  }))
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the kubernetes cluster"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}
