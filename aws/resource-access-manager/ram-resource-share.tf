resource "aws_ram_resource_share" "resource_share" {
  name                      = var.name
  allow_external_principals = var.allow_external_principals

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
