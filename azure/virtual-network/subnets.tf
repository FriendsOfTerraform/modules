resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  resource_group_name  = data.azurerm_resource_group.current.name
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [each.value.cidr_block]

  service_endpoints = distinct(concat(
    each.value.service_endpoints != null ? each.value.service_endpoints : [],
    var.service_endpoints
  ))
}

resource "azurerm_subnet_nat_gateway_association" "nat_gateway_associations" {
  for_each = var.nat_gateway.enabled ? var.subnets : {}

  nat_gateway_id = azurerm_nat_gateway.nat_gateway[0].id
  subnet_id      = azurerm_subnet.subnets[each.key].id
}
