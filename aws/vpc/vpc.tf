resource "aws_vpc" "vpc" {
  cidr_block                           = var.cidr_block.ipv4.cidr
  instance_tenancy                     = var.tenancy
  ipv4_ipam_pool_id                    = var.cidr_block.ipv4.ipam != null ? var.cidr_block.ipv4.ipam.pool_id : null
  ipv4_netmask_length                  = var.cidr_block.ipv4.ipam != null ? var.cidr_block.ipv4.ipam.netmask : null
  enable_dns_support                   = var.dns_settings.enable_dns_resolution
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics
  enable_dns_hostnames                 = var.dns_settings.enable_dns_hostnames

  tags = merge(
    { Name = var.name },
    var.additional_tags,
    var.additional_tags_all
  )
}
