locals {
  is_fifo_topic = endswith(var.name, ".fifo")

  delivery_policy = var.delivery_policy != null ? (
    jsonencode({
      http = merge(
        var.delivery_policy.healthy_retry_policy != null ? (
          {
            defaultHealthyRetryPolicy = {
              minDelayTarget     = var.delivery_policy.healthy_retry_policy.min_delay_target
              maxDelayTarget     = var.delivery_policy.healthy_retry_policy.max_delay_target
              numRetries         = var.delivery_policy.healthy_retry_policy.num_retries
              numNoDelayRetries  = var.delivery_policy.healthy_retry_policy.num_no_delay_retries
              numMinDelayRetries = var.delivery_policy.healthy_retry_policy.num_min_delay_retries
              numMaxDelayRetries = var.delivery_policy.healthy_retry_policy.num_max_delay_retries
              backoffFunction    = var.delivery_policy.healthy_retry_policy.backoff_function
            }
          }
        ) : {},

        var.delivery_policy.throttle_policy != null ? (
          {
            defaultThrottlePolicy = {
              maxReceivesPerSecond = var.delivery_policy.throttle_policy.max_receives_per_second
            }
          }
        ) : {},

        var.delivery_policy.request_policy != null ? (
          {
            defaultRequestPolicy = {
              headerContentType = var.delivery_policy.request_policy.header_content_type
            }
          }
        ) : {},

        { disableSubscriptionOverrides = var.delivery_policy.disable_subscription_overrides }
      )
    })
  ) : null
}

resource "aws_sns_topic" "sns_topic" {
  name                                     = var.name
  display_name                             = var.display_name != null ? var.display_name : (local.is_fifo_topic ? trimsuffix(var.name, ".fifo") : var.name)
  fifo_topic                               = local.is_fifo_topic
  content_based_deduplication              = local.is_fifo_topic ? var.enable_content_based_message_deduplication : null
  kms_master_key_id                        = var.enable_encryption != null ? var.enable_encryption.kms_key_id : null
  tracing_config                           = var.enable_active_tracing ? "Active" : "PassThrough"
  delivery_policy                          = local.delivery_policy
  application_success_feedback_role_arn    = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "application") ? var.delivery_status_logging.iam_role_for_successful_deliveries : null) : null
  application_success_feedback_sample_rate = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "application") ? var.delivery_status_logging.success_sample_rate : null) : null
  application_failure_feedback_role_arn    = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "application") ? var.delivery_status_logging.iam_role_for_failed_deliveries : null) : null
  http_success_feedback_role_arn           = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "http") ? var.delivery_status_logging.iam_role_for_successful_deliveries : null) : null
  http_success_feedback_sample_rate        = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "http") ? var.delivery_status_logging.success_sample_rate : null) : null
  http_failure_feedback_role_arn           = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "http") ? var.delivery_status_logging.iam_role_for_failed_deliveries : null) : null
  lambda_success_feedback_role_arn         = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "lambda") ? var.delivery_status_logging.iam_role_for_successful_deliveries : null) : null
  lambda_success_feedback_sample_rate      = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "lambda") ? var.delivery_status_logging.success_sample_rate : null) : null
  lambda_failure_feedback_role_arn         = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "lambda") ? var.delivery_status_logging.iam_role_for_failed_deliveries : null) : null
  sqs_success_feedback_role_arn            = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "sqs") ? var.delivery_status_logging.iam_role_for_successful_deliveries : null) : null
  sqs_success_feedback_sample_rate         = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "sqs") ? var.delivery_status_logging.success_sample_rate : null) : null
  sqs_failure_feedback_role_arn            = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "sqs") ? var.delivery_status_logging.iam_role_for_failed_deliveries : null) : null
  firehose_success_feedback_role_arn       = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "firehose") ? var.delivery_status_logging.iam_role_for_successful_deliveries : null) : null
  firehose_success_feedback_sample_rate    = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "firehose") ? var.delivery_status_logging.success_sample_rate : null) : null
  firehose_failure_feedback_role_arn       = var.delivery_status_logging != null ? (contains(var.delivery_status_logging.protocols, "firehose") ? var.delivery_status_logging.iam_role_for_failed_deliveries : null) : null

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
