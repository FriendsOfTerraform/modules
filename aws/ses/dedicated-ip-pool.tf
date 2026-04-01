resource "aws_sesv2_dedicated_ip_pool" "dedicated_ip_pools" {
  for_each = var.dedicated_ip_pools

  pool_name    = each.key
  scaling_mode = each.value.scaling_mode
  tags         = merge(local.common_tags, var.additional_tags_all, each.value.additional_tags)
}