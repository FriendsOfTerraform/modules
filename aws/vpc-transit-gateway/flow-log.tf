locals {
  attachment_flow_logs = flatten([
    for attachment_name, attachment_config in var.attachments : [
      for flow_log_name, flow_log_config in attachment_config.flow_logs : {
        flow_log_name                = flow_log_name
        attachment_name              = attachment_name
        destination                  = flow_log_config.destination
        additional_tags              = flow_log_config.additional_tags
        custom_log_record_format     = flow_log_config.custom_log_record_format
        filter                       = flow_log_config.filter
        maximum_aggregation_interval = flow_log_config.maximum_aggregation_interval
      }
    ]
  ])
}

resource "aws_flow_log" "transit_gateway_flow_logs" {
  for_each = var.flow_logs

  traffic_type             = each.value.filter
  iam_role_arn             = each.value.destination.cloudwatch_logs != null ? (each.value.destination.cloudwatch_logs.service_role_arn != null ? each.value.destination.cloudwatch_logs.service_role_arn : aws_iam_role.flow_logs_cloudwatch_logs_service_role[0].arn) : null
  log_destination_type     = each.value.destination.cloudwatch_logs != null ? "cloud-watch-logs" : (each.value.destination.s3 != null ? "s3" : null)
  log_destination          = each.value.destination.cloudwatch_logs != null ? each.value.destination.cloudwatch_logs.log_group_arn : (each.value.destination.s3 != null ? each.value.destination.s3.bucket_arn : null)
  transit_gateway_id       = aws_ec2_transit_gateway.transit_gateway.id
  log_format               = each.value.custom_log_record_format
  max_aggregation_interval = 60

  dynamic "destination_options" {
    for_each = each.value.destination.s3 != null ? [1] : []

    content {
      file_format                = each.value.destination.s3.log_file_format
      hive_compatible_partitions = each.value.destination.s3.enable_hive_compatible_s3_prefix
      per_hour_partition         = each.value.destination.s3.partition_logs_every_hour
    }
  }

  tags = merge(
    { Name = each.key },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}

resource "aws_flow_log" "attachment_flow_logs" {
  for_each = tomap({ for flow_log in local.attachment_flow_logs : "${flow_log.attachment_name}-${flow_log.flow_log_name}" => flow_log })

  traffic_type             = each.value.filter
  iam_role_arn             = each.value.destination.cloudwatch_logs != null ? (each.value.destination.cloudwatch_logs.service_role_arn != null ? each.value.destination.cloudwatch_logs.service_role_arn : aws_iam_role.flow_logs_cloudwatch_logs_service_role[0].arn) : null
  log_destination_type     = each.value.destination.cloudwatch_logs != null ? "cloud-watch-logs" : (each.value.destination.s3 != null ? "s3" : null)
  log_destination          = each.value.destination.cloudwatch_logs != null ? each.value.destination.cloudwatch_logs.log_group_arn : (each.value.destination.s3 != null ? each.value.destination.s3.bucket_arn : null)
  log_format               = each.value.custom_log_record_format
  max_aggregation_interval = each.value.maximum_aggregation_interval

  transit_gateway_attachment_id = contains(keys(aws_ec2_transit_gateway_vpc_attachment.vpc_attachments), each.value.attachment_name) ? aws_ec2_transit_gateway_vpc_attachment.vpc_attachments[each.value.attachment_name].id : (
    contains(keys(aws_ec2_transit_gateway_peering_attachment.peering_connection_attachments), each.value.attachment_name) ? aws_ec2_transit_gateway_peering_attachment.peering_connection_attachments[each.value.attachment_name].id : (
      contains(keys(aws_vpn_connection.vpn_attachments), each.value.attachment_name) ? aws_vpn_connection.vpn_attachments[each.value.attachment_name].transit_gateway_attachment_id : (
        contains(keys(aws_ec2_transit_gateway_peering_attachment_accepter.peering_connection_attachment_accepters), each.value.attachment_name) ? aws_ec2_transit_gateway_peering_attachment_accepter.peering_connection_attachment_accepters[each.value.attachment_name].transit_gateway_attachment_id : null
      )
    )
  )

  dynamic "destination_options" {
    for_each = each.value.destination.s3 != null ? [1] : []

    content {
      file_format                = each.value.destination.s3.log_file_format
      hive_compatible_partitions = each.value.destination.s3.enable_hive_compatible_s3_prefix
      per_hour_partition         = each.value.destination.s3.partition_logs_every_hour
    }
  }

  tags = merge(
    { Name = each.value.flow_log_name },
    each.value.additional_tags,
    var.additional_tags_all
  )
}
