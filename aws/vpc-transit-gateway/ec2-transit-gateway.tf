resource "aws_ec2_transit_gateway" "transit_gateway" {
  amazon_side_asn                    = var.amazon_side_autonomous_system_numnber
  auto_accept_shared_attachments     = var.auto_accept_shared_attachments ? "enable" : "disable"
  default_route_table_association    = var.enable_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation    = var.enable_default_route_table_propagation ? "enable" : "disable"
  description                        = var.description
  dns_support                        = var.enable_dns_support ? "enable" : "disable"
  security_group_referencing_support = var.enable_security_group_referencing_support ? "enable" : "disable"
  multicast_support                  = var.enable_multicast_support ? "enable" : "disable"
  transit_gateway_cidr_blocks        = var.cidr_blocks
  vpn_ecmp_support                   = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(
    { Name = var.name },
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
