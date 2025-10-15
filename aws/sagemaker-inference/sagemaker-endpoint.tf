resource "aws_sagemaker_endpoint" "provisioned_endpoints" {
  for_each = local.provisioned_endpoints

  name                 = each.key
  endpoint_config_name = aws_sagemaker_endpoint_configuration.provisioned_endpoint_configurations[each.key].name

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}

resource "aws_sagemaker_endpoint" "serverless_endpoints" {
  for_each = local.serverless_endpoints

  name                 = each.key
  endpoint_config_name = aws_sagemaker_endpoint_configuration.serverless_endpoint_configurations[each.key].name

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
