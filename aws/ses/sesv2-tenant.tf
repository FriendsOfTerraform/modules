resource "aws_sesv2_tenant" "tenants" {
  for_each = var.tenants

  tenant_name = each.key
  tags        = merge(local.common_tags, var.additional_tags_all, each.value.additional_tags)
}