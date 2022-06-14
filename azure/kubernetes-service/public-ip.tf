resource "azurerm_public_ip" "outbound_lb_public_ip" {
  name                = "${var.name}-outbound-lb-public-ip"
  resource_group_name = data.azurerm_resource_group.current.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}
