# Default ENI
resource "aws_network_interface" "primary_network_interface" {
  subnet_id      = var.network_interface.subnet_id
  description    = var.network_interface.description
  interface_type = var.network_interface.enable_elastic_fabric_adapter ? "efa" : null

  ipv4_prefix_count = var.network_interface.prefix_delegation != null ? (
    var.network_interface.prefix_delegation.ipv4 != null ? (
      var.network_interface.prefix_delegation.ipv4.auto_assign_count
    ) : null
  ) : null

  ipv4_prefixes = var.network_interface.prefix_delegation != null ? (
    var.network_interface.prefix_delegation.ipv4 != null ? (
      var.network_interface.prefix_delegation.ipv4.custom_prefixes
    ) : null
  ) : null

  private_ip_list = var.network_interface.private_ip_addresses != null ? var.network_interface.private_ip_addresses.ipv4 : null

  private_ip_list_enabled = var.network_interface.private_ip_addresses != null ? (
    var.network_interface.private_ip_addresses.ipv4 != null ? true : null
  ) : null

  security_groups   = var.network_interface.security_group_ids
  source_dest_check = var.network_interface.enable_source_destination_checking

  tags = merge(
    { Name = "${var.name}-primary" },
    local.common_tags,
    var.network_interface.additional_tags,
    var.additional_tags_all
  )
}

# Additional ENIs
resource "aws_network_interface" "additional_network_interfaces" {
  for_each = var.additional_network_interfaces

  subnet_id      = each.value.subnet_id
  description    = each.value.description
  interface_type = each.value.enable_elastic_fabric_adapter ? "efa" : null

  ipv4_prefix_count = each.value.prefix_delegation != null ? (
    each.value.prefix_delegation.ipv4 != null ? (
      each.value.prefix_delegation.ipv4.auto_assign_count
    ) : null
  ) : null

  ipv4_prefixes = each.value.prefix_delegation != null ? (
    each.value.prefix_delegation.ipv4 != null ? (
      each.value.prefix_delegation.ipv4.custom_prefixes
    ) : null
  ) : null

  private_ip_list = each.value.private_ip_addresses != null ? each.value.private_ip_addresses.ipv4 : null

  private_ip_list_enabled = each.value.private_ip_addresses != null ? (
    each.value.private_ip_addresses.ipv4 != null ? true : null
  ) : null

  security_groups   = each.value.security_group_ids
  source_dest_check = each.value.enable_source_destination_checking

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}

resource "aws_network_interface_attachment" "additional_eni_attachments" {
  for_each = var.additional_network_interfaces

  instance_id          = aws_instance.ec2_instance.id
  network_interface_id = aws_network_interface.additional_network_interfaces[each.key].id
  device_index         = each.value.device_index
}
