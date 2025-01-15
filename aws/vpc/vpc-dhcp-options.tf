resource "aws_vpc_dhcp_options" "dhcp_options" {
  count = var.dhcp_options != null ? 1 : 0

  domain_name          = var.dhcp_options.domain_name
  domain_name_servers  = var.dhcp_options.domain_name_servers
  ntp_servers          = var.dhcp_options.ntp_servers
  netbios_name_servers = var.dhcp_options.netbios_name_servers
  netbios_node_type    = var.dhcp_options.netbios_node_type

  tags = merge(
    {
      Name = "${var.name}-dhcp-options"
    },
    var.dhcp_options.additional_tags,
    var.additional_tags_all
  )
}
