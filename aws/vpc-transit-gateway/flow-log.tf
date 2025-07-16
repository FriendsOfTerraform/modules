# locals {
#   subnet_flow_logs = flatten([
#     for subnet_name, subnet_config in var.subnets : [
#       for flow_log_name, flow_log_config in subnet_config.flow_logs : {
#         flow_log_name                = flow_log_name
#         subnet_name                  = subnet_name
#         destination                  = flow_log_config.destination
#         additional_tags              = flow_log_config.additional_tags
#         custom_log_record_format     = flow_log_config.custom_log_record_format
#         filter                       = flow_log_config.filter
#         maximum_aggregation_interval = flow_log_config.maximum_aggregation_interval
#       }
#     ]
#   ])
# }

resource "aws_flow_log" "transit_gateway_flow_logs" {
  for_each = var.flow_logs

  traffic_type             = each.value.filter
  iam_role_arn             = each.value.destination.cloudwatch_logs != null ? (each.value.destination.cloudwatch_logs.service_role_arn != null ? each.value.destination.cloudwatch_logs.service_role_arn : aws_iam_role.flow_logs_cloudwatch_logs_service_role[0].arn) : null
  log_destination_type     = each.value.destination.cloudwatch_logs != null ? "cloud-watch-logs" : (each.value.destination.s3 != null ? "s3" : null)
  log_destination          = each.value.destination.cloudwatch_logs != null ? each.value.destination.cloudwatch_logs.log_group_arn : (each.value.destination.s3 != null ? each.value.destination.s3.bucket_arn : null)
  transit_gateway_id       = aws_ec2_transit_gateway.transit_gateway.id
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

# resource "aws_flow_log" "subnet_flow_logs" {
#   for_each = tomap({ for flow_log in local.subnet_flow_logs : "${flow_log.subnet_name}-${flow_log.flow_log_name}" => flow_log })

#   traffic_type             = each.value.filter
#   iam_role_arn             = each.value.destination.cloudwatch_logs != null ? (each.value.destination.cloudwatch_logs.service_role_arn != null ? each.value.destination.cloudwatch_logs.service_role_arn : aws_iam_role.flow_logs_cloudwatch_logs_service_role[0].arn) : null
#   log_destination_type     = each.value.destination.cloudwatch_logs != null ? "cloud-watch-logs" : (each.value.destination.s3 != null ? "s3" : null)
#   log_destination          = each.value.destination.cloudwatch_logs != null ? each.value.destination.cloudwatch_logs.log_group_arn : (each.value.destination.s3 != null ? each.value.destination.s3.bucket_arn : null)
#   subnet_id                = aws_subnet.subnets[each.value.subnet_name].id
#   max_aggregation_interval = each.value.maximum_aggregation_interval

#   dynamic "destination_options" {
#     for_each = each.value.destination.s3 != null ? [1] : []

#     content {
#       file_format                = each.value.destination.s3.log_file_format
#       hive_compatible_partitions = each.value.destination.s3.enable_hive_compatible_s3_prefix
#       per_hour_partition         = each.value.destination.s3.partition_logs_every_hour
#     }
#   }

#   tags = merge(
#     { Name = each.value.flow_log_name },
#     each.value.additional_tags,
#     var.additional_tags_all
#   )
# }
