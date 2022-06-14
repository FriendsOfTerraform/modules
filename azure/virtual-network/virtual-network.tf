resource "azurerm_virtual_network" "virtual_network" {
  resource_group_name = data.azurerm_resource_group.current.name
  location            = local.location
  name                = var.name
  address_space       = var.cidr_blocks
  dns_servers         = var.additional_dns_server_addresses

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.additional_tags
  )
}
