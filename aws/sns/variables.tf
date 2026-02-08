variable "name" {
  type        = string
  description = <<EOT
    The name of the SNS topic. All associated resources will also have their name prefixed with this value

    @since 1.0.0
  EOT
}

variable "access_policy" {
  type        = string
  description = <<EOT
    Defines who can access the topic. By default, only the topic owner can publish or subscribe to the topic

    @since 1.0.0
  EOT
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the SNS topic

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

variable "data_protection_policy" {
  type = object({
    /// Manages multiple statements in this policy
    ///
    /// @since 1.0.0
    statements = map(object({
      /// The direction of messages to which this statement applies.
      ///
      /// @enum Inbound|Outbound
      /// @since 1.0.0
      data_direction   = string # Inbound, Outbound
      /// A list of data identifiers that represent sensitive data this statement applies to. Please refer to [this documentation][sns-managed-data-identifier] for the valid values. Can also include names specified in the `data_protection_policy.configuration.custom_data_identifiers`
      ///
      /// @link {sns-managed-data-identifier} https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-managed-data-identifiers.html#what-are-data-managed-data-identifiers
      /// @since 1.0.0
      data_identifiers = list(string)
      /// A list of IAM principals this statement applies to
      ///
      /// @since 1.0.0
      principals       = optional(list(string), ["*"])

      /// The [operation to trigger][sns-data-protection-policy-operations] upon finding sensitive data as specified by this statement. You must specify one and only one of the following: `audit`, `deidentify`, `deny`
      ///
      /// @link {sns-data-protection-policy-operations} https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-operations.html#statement-operation-json-properties-deidentify
      /// @since 1.0.0
      operation = object({
        /// Audit matching sensitive data and send audit result to a destination
        ///
        /// @since 1.0.0
        audit = optional(object({
          /// The percentage of messages to audit for sensitive information. Valid value: between `0` to `99`
          ///
          /// @since 1.0.0
          sample_rate = number
          /// The AWS services to send the audit finding results. Must specify at least one of the following: `cloudwatch_log_group`, `s3_bucket_name`, `firehose_delivery_stream`
          ///
          /// @since 1.0.0
          destinations = object({
            /// The Cloudwatch log group to send audit results to
            ///
            /// @since 1.0.0
            cloudwatch_log_group     = optional(string, null)
            /// The name of an S3 bucket to send audit results to
            ///
            /// @since 1.0.0
            s3_bucket_name           = optional(string, null)
            /// The name of a Kinese Firehose Delivery Stream to send audit results to
            ///
            /// @since 1.0.0
            firehose_delivery_stream = optional(string, null)
          })
        }), null)

        /// De-identify matching sensitive data by either redacting them or masking them with a specific character. Must specify one and only one of the following: `mask_with_character`, `redact`
        ///
        /// @since 1.0.0
        deidentify = optional(object({
          /// Replaces the data with single characters. All printable ASCII characters except delete are supported
          ///
          /// @since 1.0.0
          mask_with_character = optional(string, null)
          /// Completely removes the data
          ///
          /// @since 1.0.0
          redact              = optional(bool, null)
        }), null)

        /// Denies the delivery of the message if the message contains sensitive data
        ///
        /// @since 1.0.0
        deny = optional(object({}), null)
      })
    }))

    /// Define Custom Data identifiers that can be used in data protection policy
    ///
    /// @since 1.0.0
    configuration = optional(object({
      /// Map of custom data identifiers in `{Name = Regex}` format
      ///
      /// @since 1.0.0
      custom_data_identifiers = map(string)
    }), null)
  })
  description = <<EOT
    Manages the [data protection policy][sns-data-protection-policy] for this topic.

    @example "Data Protection Policy" #data-protection-policy
    @link {sns-data-protection-policy} https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-policies.html
    @since 1.0.0
  EOT
  default     = null
}

variable "delivery_policy" {
  type = object({
    disable_subscription_overrides = optional(bool, false)

    /// Define the retry policy
    ///
    /// @since 1.0.0
    healthy_retry_policy = optional(object({
      /// The minimum delay for a retry in seconds. Valid value: between `1` and `max_delay_target`
      ///
      /// @since 1.0.0
      min_delay_target      = optional(number, 20)
      /// The maximum delay for a retry in seconds. Valid value: between `min_delay_target` and `3600`
      ///
      /// @since 1.0.0
      max_delay_target      = optional(number, 20)
      /// The total number of retries, including immediate, pre-backoff, backoff, and post-backoff retries. Valid value: between `0` to `100`
      ///
      /// @since 1.0.0
      num_retries           = optional(number, 3)
      /// The number of retries to be done immediately, with no delay between them
      ///
      /// @since 1.0.0
      num_no_delay_retries  = optional(number, 0)
      /// The number of retries in the pre-backoff phase, with the specified `min_delay_target` between them
      ///
      /// @since 1.0.0
      num_min_delay_retries = optional(number, 0)
      /// The number of retries in the post-backoff phase, with the `max_delay_target` between them.
      ///
      /// @since 1.0.0
      num_max_delay_retries = optional(number, 0)
      /// The model for backoff between retries.
      ///
      /// @enum arithmetic|exponential|geometric|linear
      /// @since 1.0.0
      backoff_function      = optional(string, "linear")
    }), null)

    /// Define the throttle policy
    ///
    /// @since 1.0.0
    throttle_policy = optional(object({
      /// The maximum number of deliveries per second, per subscription. Valid value: `1` or greater
      ///
      /// @since 1.0.0
      max_receives_per_second = number
    }), null)

    /// Define the request policy
    ///
    /// @since 1.0.0
    request_policy = optional(object({
      /// The content type of the notification being sent to HTTP/S endpoints.
      ///
      /// @enum application/json|text/plain
      /// @since 1.0.0
      header_content_type = optional(string, "text/plain; charset=UTF-8")
    }), null)
  })
  description = <<EOT
    Topic wide delivery policy that tells SNS how to retry failed message deliveries to endpoints with the `http`, `https` protocol

    @since 1.0.0
  EOT
  default     = null
}

variable "delivery_status_logging" {
  type = object({
    /// Subscriber protocols which logs will be generated for.
    ///
    /// @enum application|http|lambda|sqs|firehose
    /// @since 1.0.0
    protocols                          = list(string)
    /// The percentage of successful message deliveries to log. Valid value: between `0` and `100`
    ///
    /// @since 1.0.0
    success_sample_rate                = number
    /// Arn of an IAM role that gives permission to SNS to write successful delivery logs to Cloudwatch
    ///
    /// @since 1.0.0
    iam_role_for_successful_deliveries = string
    /// Arn of an IAM role that gives permission to SNS to write failed delivery logs to Cloudwatch
    ///
    /// @since 1.0.0
    iam_role_for_failed_deliveries     = string
  })
  description = <<EOT
    Enables logging of the delivery status of notification messages sent to topics

    @since 1.0.0
  EOT
  default     = null
}

variable "display_name" {
  type        = string
  description = <<EOT
    The display name of the topic. Optional for all transports. For SMS subscriptions only the first 10 characters are used. If not specified, the `name` of the topic will be used.

    @since 1.0.0
  EOT
  default     = null
}

variable "enable_active_tracing" {
  type        = bool
  description = <<EOT
    Enable to have AWS X-Ray collect data about the messages that this topic receives. Additional steps are needed, please see [Active Tracing X-Ray resource-based policy](#active-tracing-x-ray-resource-based-policy)

    @since 1.0.0
  EOT
  default     = false
}

variable "enable_content_based_message_deduplication" {
  type        = bool
  description = <<EOT
    Enable default message deduplication based on message content. If false, a deduplication ID must be provided for every publish request

    @since 1.0.0
  EOT
  default     = false
}

variable "enable_encryption" {
  type = object({
    /// The ID of a KMS key used for encryption
    ///
    /// @since 1.0.0
    kms_key_id = optional(string, "alias/aws/sns")
  })
  description = <<EOT
    Enables SNS encryption at-rest

    @since 1.0.0
  EOT
  default     = null
}

variable "subscriptions" {
  type = list(object({
    /// The type of endpoint to subscribe.
    ///
    /// @enum application|firehose|lambda|sms|sqs|email|http|https
    /// @since 1.0.0
    protocol                    = string
    /// List of endpoints to send data to. The contents vary with the protocol. See details below:
    ///
    /// | Protocol    | Endpoint
    /// |-------------|---------------------------------------------------------
    /// | application | ARN of a mobile app and device
    /// | firehose    | ARN of an Amazon Kinesis Data Firehose delivery stream
    /// | lambda      | ARN of an AWS Lambda function
    /// | sms         | Phone number of an SMS-enabled device.
    /// | sqs         | ARN of an Amazon SQS queue
    /// | email       | An email address
    /// | email-json  | An email address
    /// | http        | A URL beginning with http://
    /// | https       | A URL beginning with https://
    ///
    /// @since 1.0.0
    endpoints                   = list(string)
    /// ARN of a SQS queue where SNS will forward messages that can't be delivered to subscribers successfully to
    ///
    /// @since 1.0.0
    dead_letter_queue_arn       = optional(string, null)
    /// Whether to enable raw message delivery, where the original message is directly passed and not wrapped in JSON with the original message in the message property
    ///
    /// @since 1.0.0
    enable_raw_message_delivery = optional(bool, false)
    /// JSON String with the [filter policy][sns-subscription-filter-policy] that will be used in the subscription to filter messages seen by the target resource
    ///
    /// @link {sns-subscription-filter-policy} https://docs.aws.amazon.com/sns/latest/dg/sns-subscription-filter-policies.html
    /// @since 1.0.0
    filter_policy               = optional(string, null)
    /// The [filter policy scope][sns-subscription-filter-policy-scope].
    ///
    /// @enum MessageAttributes|MessageBody
    /// @link {sns-subscription-filter-policy-scope} https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering-scope.html
    /// @since 1.0.0
    filter_policy_scope         = optional(string, "MessageAttributes")
    /// ARN of the IAM role to publish to Kinesis Data Firehose delivery stream. Required only if `protocol = "firehose"`
    ///
    /// @since 1.0.0
    subscription_role_arn       = optional(string, null)
  }))
  description = <<EOT
    Manages multiple subscriptions for this topic.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = []
}
