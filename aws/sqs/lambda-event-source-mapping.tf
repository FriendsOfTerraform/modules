resource "aws_lambda_event_source_mapping" "lambda_triggers" {
  for_each = var.lambda_triggers

  batch_size                         = each.value.batch_size
  enabled                            = each.value.enabled
  event_source_arn                   = aws_sqs_queue.sqs_queue.arn
  function_name                      = each.key
  function_response_types            = each.value.report_batch_item_failures ? ["ReportBatchItemFailures"] : null
  kms_key_arn                        = each.value.filter_criteria != null ? each.value.filter_criteria.kms_key_arn : null
  maximum_batching_window_in_seconds = each.value.batch_window

  dynamic "filter_criteria" {
    for_each = each.value.filter_criteria != null ? [1] : []

    content {
      dynamic "filter" {
        for_each = each.value.filter_criteria.patterns

        content {
          pattern = filter.value
        }
      }
    }
  }

  dynamic "metrics_config" {
    for_each = each.value.enable_metrics ? [1] : []

    content {
      metrics = ["EventCount"]
    }
  }

  scaling_config {
    maximum_concurrency = each.value.maximum_concurrency
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
