locals {
  nat_gateway_enabled = var.nat_gateway.enabled
  use_public_ip       = var.nat_gateway.public_ip_prefix_length == null
}

resource "azurerm_public_ip" "public_ip" {
  count = local.nat_gateway_enabled ? (local.use_public_ip ? 1 : 0) : 0

  name                = "${var.name}-nat-gateway-public-ip"
  resource_group_name = data.azurerm_resource_group.current.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.nat_gateway.additional_tags
  )
}

resource "azurerm_public_ip_prefix" "public_ip_prefix" {
  count = local.nat_gateway_enabled ? (local.use_public_ip ? 0 : 1) : 0

  name                = "${var.name}-nat-gateway-public-ip-prefix"
  resource_group_name = data.azurerm_resource_group.current.name
  location            = local.location
  prefix_length       = var.nat_gateway.public_ip_prefix_length

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.nat_gateway.additional_tags
  )
}

resource "azurerm_nat_gateway" "nat_gateway" {
  count = local.nat_gateway_enabled ? 1 : 0

  name                = "${var.name}-nat-gateway"
  resource_group_name = data.azurerm_resource_group.current.name
  location            = local.location

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.nat_gateway.additional_tags
  )
}

resource "azurerm_nat_gateway_public_ip_association" "public_ip_association" {
  count = local.nat_gateway_enabled ? (local.use_public_ip ? 1 : 0) : 0

  nat_gateway_id       = azurerm_nat_gateway.nat_gateway[0].id
  public_ip_address_id = azurerm_public_ip.public_ip[0].id
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "public_ip_prefix_association" {
  count = local.nat_gateway_enabled ? (local.use_public_ip ? 0 : 1) : 0

  nat_gateway_id      = azurerm_nat_gateway.nat_gateway[0].id
  public_ip_prefix_id = azurerm_public_ip_prefix.public_ip_prefix[0].id
}
