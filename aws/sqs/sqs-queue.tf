locals {
  time_table = {
    second = 1
    minute = 60
    hour   = 3600
    day    = 86400
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  content_based_deduplication       = endswith(var.name, ".fifo") ? var.fifo_queue_settings.enable_content_based_deduplication : null
  deduplication_scope               = endswith(var.name, ".fifo") ? var.fifo_queue_settings.deduplication_scope : null
  delay_seconds                     = split(" ", var.delivery_delay)[0] * local.time_table[trimsuffix(split(" ", var.delivery_delay)[1], "s")]
  fifo_queue                        = endswith(var.name, ".fifo")
  fifo_throughput_limit             = endswith(var.name, ".fifo") ? var.fifo_queue_settings.fifo_throughput_limit : null
  kms_data_key_reuse_period_seconds = var.enable_server_side_encryption_kms != null ? split(" ", var.enable_server_side_encryption_kms.data_key_reuse_period)[0] * local.time_table[trimsuffix(split(" ", var.enable_server_side_encryption_kms.data_key_reuse_period)[1], "s")] : null
  kms_master_key_id                 = var.enable_server_side_encryption_kms != null ? var.enable_server_side_encryption_kms.kms_key_id : null
  max_message_size                  = var.maximum_message_size * 1024
  message_retention_seconds         = split(" ", var.message_retention_period)[0] * local.time_table[trimsuffix(split(" ", var.message_retention_period)[1], "s")]
  name                              = var.name
  receive_wait_time_seconds         = var.receive_message_wait_time
  sqs_managed_sse_enabled           = var.enable_server_side_encryption_kms == null
  visibility_timeout_seconds        = split(" ", var.visibility_timeout)[0] * local.time_table[trimsuffix(split(" ", var.visibility_timeout)[1], "s")]

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
