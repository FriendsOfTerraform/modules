locals {
  event_destinations = flatten([
    for cs_name, cs in var.configuration_sets : [
      for ed_name, ed in cs.event_destinations : {
        configuration_set_name = cs_name
        event_destination_name = ed_name
        event_destination      = ed
      }
    ]
  ])
}

resource "aws_sesv2_configuration_set_event_destination" "event_destinations" {
  for_each = { for ed in local.event_destinations : "${ed.configuration_set_name}-${ed.event_destination_name}" => ed }

  configuration_set_name = each.value.configuration_set_name
  event_destination_name = each.value.event_destination_name

  event_destination {
    enabled              = each.value.event_destination.enabled
    matching_event_types = [for event_type in each.value.event_destination.event_types : upper(event_type)]

    dynamic "cloud_watch_destination" {
      for_each = each.value.event_destination.destination.cloudwatch == null ? [] : [1]

      content {
        dynamic "dimension_configuration" {
          for_each = each.value.event_destination.destination.cloudwatch.dimensions

          content {
            default_dimension_value = dimension_configuration.value
            dimension_name          = split("/", dimension_configuration.key)[1]
            dimension_value_source  = upper(split("/", dimension_configuration.key)[0])
          }
        }
      }
    }

    dynamic "kinesis_firehose_destination" {
      for_each = each.value.event_destination.destination.kinesis_firehose == null ? [] : [1]

      content {
        delivery_stream_arn = each.value.event_destination.destination.kinesis_firehose.delivery_stream_arn
        iam_role_arn        = each.value.event_destination.destination.kinesis_firehose.role_arn
      }
    }

    dynamic "pinpoint_destination" {
      for_each = each.value.event_destination.destination.pinpoint == null ? [] : [1]

      content {
        application_arn = each.value.event_destination.destination.pinpoint.application_arn
      }
    }

    dynamic "sns_destination" {
      for_each = each.value.event_destination.destination.sns == null ? [] : [1]

      content {
        topic_arn = each.value.event_destination.destination.sns.topic_arn
      }
    }
  }
}