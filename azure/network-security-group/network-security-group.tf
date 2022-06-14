resource "azurerm_network_security_group" "network_security_group" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.current.name
  location            = local.location

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.additional_tags
  )
}
