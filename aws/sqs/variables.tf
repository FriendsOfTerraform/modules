variable "name" {
  type        = string
  description = "The name of the kubernetes cluster. All associated resources' names will also be prefixed by this value"
}

variable "access_policy" {
  type        = string
  description = "A JSON document that defines the accounts, users and roles that can access this queue, and the actions that are allowed."
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the queue"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "dead_letter_queue" {
  type = object({
    arn              = string
    maximum_receives = optional(number, 10)
  })
  description = "A destination SQS queue for messages that failed to be consumed successfully"
  default     = null
}

variable "delivery_delay" {
  type        = string
  description = "Specify the amount of time to delay the first delivery of each message added to the queue."
  default     = "0 second"
}

variable "enable_server_side_encryption_kms" {
  type = object({
    data_key_reuse_period = optional(string, "5 minutes")
    kms_key_id            = optional(string, "alias/aws/sqs")
  })
  description = "Enable SSE KMS encryption. By default, SSE SQS is enabled"
  default     = null
}

variable "fifo_queue_settings" {
  type = object({
    enable_content_based_deduplication = optional(bool, false)
    deduplication_scope                = optional(string, "queue")
    fifo_throughput_limit              = optional(string, "perQueue")
  })
  description = "Configuration options that apply to FIFO SQS queue"
  default     = {}
}

variable "lambda_triggers" {
  type = map(object({
    additional_tags = optional(map(string), {})
    batch_size      = optional(number, 10)
    batch_window    = optional(number, 0)
    enable_metrics  = optional(bool, false)
    enabled         = optional(bool, true)
    filter_criteria = optional(object({
      patterns    = list(string)
      kms_key_arn = optional(string, null)
    }), null)
    maximum_concurrency        = optional(number, 100)
    report_batch_item_failures = optional(bool, false)
  }))
  description = "Configure the queue to trigger an AWS Lambda function when new messages arrive in the queue"
  default     = {}
}

variable "maximum_message_size" {
  type        = number
  description = "The maximum message size, in Kibibytes (KiB), for your queue. Valid value: 1 - 256"
  default     = 256
}

variable "message_retention_period" {
  type        = string
  description = "The amount of time that Amazon SQS retains a message that does not get deleted"
  default     = "4 days"
}

variable "receive_message_wait_time" {
  type        = string
  description = "The maximum amount of time that polling will wait for messages to become available to receive"
  default     = 0
}

variable "redrive_allow_policy" {
  type        = list(string)
  description = "Specify which source SQS queues can use this queue as the destination dead-letter queue"
  default     = null
}

variable "visibility_timeout" {
  type        = string
  description = "Specify the length of time that a message received from a queue (by one consumer) will not be visible to the other message consumers"
  default     = "30 seconds"
}
