variable "name" {
  type        = string
  description = "The name of the SNS topic"
}

variable "access_policy" {
  type        = string
  description = "defines who can access your topic. By default, only the topic owner can publish or subscribe to the topic"
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the SNS topic"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "data_protection_policy" {
  type = object({
    # key is sid of statements
    statements = map(object({
      data_direction   = string # Inbound, Outbound
      data_identifiers = list(string)
      principals       = optional(list(string), ["*"])

      operation = object({
        audit = optional(object({
          sample_rate = number
          destinations = object({
            cloudwatch_log_group     = optional(string, null)
            s3_bucket_name           = optional(string, null)
            firehose_delivery_stream = optional(string, null)
          })
        }), null)

        deidentify = optional(object({
          mask_with_character = optional(string, null)
          redact              = optional(bool, null)
        }), null)

        deny = optional(object({}), null)
      })
    }))

    configuration = optional(object({
      custom_data_identifiers = map(string)
    }), null)
  })
  description = "Manages the data protection policy for this topic"
  default     = null
}

variable "delivery_policy" {
  type = object({
    disable_subscription_overrides = optional(bool, false)

    healthy_retry_policy = optional(object({
      min_delay_target      = optional(number, 20)
      max_delay_target      = optional(number, 20)
      num_retries           = optional(number, 3)
      num_no_delay_retries  = optional(number, 0)
      num_min_delay_retries = optional(number, 0)
      num_max_delay_retries = optional(number, 0)
      backoff_function      = optional(string, "linear")
    }), null)

    throttle_policy = optional(object({
      max_receives_per_second = number
    }), null)

    request_policy = optional(object({
      header_content_type = optional(string, "text/plain; charset=UTF-8")
    }), null)
  })
  description = "Topic wide delivery policy that tells SNS how to retry failed message deliveries to HTTP/S endpoints"
  default     = null
}

variable "delivery_status_logging" {
  type = object({
    protocols                          = list(string)
    success_sample_rate                = number
    iam_role_for_successful_deliveries = string
    iam_role_for_failed_deliveries     = string
  })
  description = "Enables logging of the delivery status of notification messages sent to topics"
  default     = null
}

variable "display_name" {
  type        = string
  description = "The display name of the topic"
  default     = null
}

variable "enable_active_tracing" {
  type        = bool
  description = "Enable AWS X-Ray active tracing for this topic to view its traces and service map in Amazon CloudWatch"
  default     = false
}

variable "enable_content_based_message_deduplication" {
  type        = bool
  description = "Enable default message deduplication based on message content"
  default     = false
}

variable "enable_encryption" {
  type = object({
    kms_key_id = optional(string, "alias/aws/sns")
  })
  description = "Enables SNS at-rest encryption"
  default     = null
}

variable "subscriptions" {
  type = list(object({
    protocol                    = string
    endpoints                   = list(string)
    dead_letter_queue_arn       = optional(string, null)
    enable_raw_message_delivery = optional(bool, false)
    filter_policy               = optional(string, null)
    filter_policy_scope         = optional(string, "MessageAttributes")
    subscription_role_arn       = optional(string, null)
  }))
  description = "Manages multiple subscriptions for this topic"
  default     = []
}
