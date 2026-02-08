variable "name" {
  type        = string
  description = <<EOT
    The name of the SQS queue. All associated resources' names will also be prefixed by this value. If the name is suffixed with `".fifo"`, a FIFO queue will be created. For example: `"demo-sqs.fifo"`

    @since 1.0.0
  EOT
}

variable "access_policy" {
  type        = string
  description = <<EOT
    A JSON document that defines the accounts, users and roles that can access this queue, and the actions that are allowed. Note that you MUST explicitly set `Version = "2012-10-17"` in the policy document otherwise AWS will hang indefinitely.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the SQS queue

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "dead_letter_queue" {
  type = object({
    /// The ARN of the destination SQS queue
    ///
    /// @since 1.0.0
    arn              = string
    /// The number of times a consumer can receive a message from a source queue before it is moved to a dead-letter queue
    ///
    /// @since 1.0.0
    maximum_receives = optional(number, 10)
  })
  description = <<EOT
    A destination SQS queue for messages that failed to be consumed successfully.

    @example "Dead Letter Queue" #dead-letter-queue
    @since 1.0.0
  EOT
  default     = null
}

variable "delivery_delay" {
  type        = string
  description = <<EOT
    Specify the amount of time to delay the first delivery of each message added to the queue. In `"value unit"` format. Supported units: `"seconds"`, `"minutes"`. Valid value: `"0 second"` - `"15 minutes"`

    @since 1.0.0
  EOT
  default     = "0 second"
}

variable "enable_server_side_encryption_kms" {
  type = object({
    /// The time period in which Amazon SQS can cache and use a data key before calling KMS again to obtain a new data key. In `"value unit"` format. Supported units: `"minutes"`, `"hours"`. Valid value: `"1 minute"` - `"24 hours"`
    ///
    /// @since 1.0.0
    data_key_reuse_period = optional(string, "5 minutes")
    /// The KMS key to be used for encryption
    ///
    /// @since 1.0.0
    kms_key_id            = optional(string, "alias/aws/sqs")
  })
  description = <<EOT
    Enable SSE KMS encryption. If not specified, SSE SQS is enabled by default

    @since 1.0.0
  EOT
  default     = null
}

variable "fifo_queue_settings" {
  type = object({
    /// When enabled, the message deduplication ID is optional.
    ///
    /// @since 1.0.0
    enable_content_based_deduplication = optional(bool, false)
    /// Specify the scope of deduplication for a FIFO queue.
    ///
    /// @enum queue|messageGroup
    /// @since 1.0.0
    deduplication_scope                = optional(string, "queue")
    /// Specify how to apply the throughput limit on FIFO queue.
    ///
    /// @enum perQueue|perMessageGroupId
    /// @since 1.0.0
    fifo_throughput_limit              = optional(string, "perQueue")
  })
  description = <<EOT
    Configuration options that apply to FIFO SQS queue

    @since 1.0.0
  EOT
  default     = {}
}

variable "lambda_triggers" {
  type = map(object({
    /// Additional tags associated to the lambda trigger
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
    /// The maximum number of records in each batch to send to the function. The maximum is `10000` for standard queues and `10` for FIFO queues.
    ///
    /// @since 1.0.0
    batch_size      = optional(number, 10)
    /// The maximum amount of time to gather records before invoking the function, in seconds. When the batch size is greater than 10, set the batch window to at least 1 second.
    ///
    /// @since 1.0.0
    batch_window    = optional(number, 0)
    /// Monitor your event source with metrics. You can view those metrics in CloudWatch console. Enabling this feature incurs additional costs
    ///
    /// @since 1.0.0
    enable_metrics  = optional(bool, false)
    /// Whether this lambda trigger is enabled
    ///
    /// @since 1.0.0
    enabled         = optional(bool, true)
    /// Define the filtering criteria to determine whether or not to process an event
    ///
    /// @since 1.0.0
    filter_criteria = optional(object({
      /// You can specify up to 5 filter patterns. Please refer to [this documentation][lambda-event-source-mapping-filter-rule-syntax] for a list of valid filter syntaxes
      ///
      /// @link {lambda-event-source-mapping-filter-rule-syntax} https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventfiltering.html#filtering-syntax
      /// @since 1.0.0
      patterns    = list(string)
      /// The KMS key to encrypt and decrypt the filter criteria
      ///
      /// @since 1.0.0
      kms_key_arn = optional(string, null)
    }), null)
    /// The maximum number of concurrent function instances that the SQS event source can invoke. Valid values: `2 - 1000`
    ///
    /// @since 1.0.0
    maximum_concurrency        = optional(number, 100)
    /// Allow your function to return a partial successful response for a batch of records.
    ///
    /// @since 1.0.0
    report_batch_item_failures = optional(bool, false)
  }))
  description = <<EOT
    Configure the queue to trigger an AWS Lambda function when new messages arrive in the queue.

    @example "Lambda Triggers" #lambda-triggers
    @since 1.0.0
  EOT
  default     = {}
}

variable "maximum_message_size" {
  type        = number
  description = <<EOT
    The maximum message size, in Kibibytes (KiB), for your queue. Valid value: `1 - 256`

    @since 1.0.0
  EOT
  default     = 256
}

variable "message_retention_period" {
  type        = string
  description = <<EOT
    The amount of time that Amazon SQS retains a message that does not get deleted. In `"value unit"` format. Supported units: `"minutes"`, `"hours"`, `"days"`. Valid value: `"1 minute"` - `"14 days"`

    @since 1.0.0
  EOT
  default     = "4 days"
}

variable "receive_message_wait_time" {
  type        = string
  description = <<EOT
    The maximum amount of time, in seconds, that polling will wait for messages to become available to receive. Valid value: `0 - 20`

    @since 1.0.0
  EOT
  default     = 0
}

variable "redrive_allow_policy" {
  type        = list(string)
  description = <<EOT
    Specify which source SQS queues can use this queue as the destination dead-letter queue.

    @example "Dead Letter Queue" #dead-letter-queue
    @since 1.0.0
  EOT
  default     = null
}

variable "visibility_timeout" {
  type        = string
  description = <<EOT
    Specify the length of time that a message received from a queue (by one consumer) will not be visible to the other message consumers. In `"value unit"` format. Supported units: `"seconds"`, `"minutes"`, `"hours"`. Valid value: `"0 second"` - `"12 hours"`

    @since 1.0.0
  EOT
  default     = "30 seconds"
}
