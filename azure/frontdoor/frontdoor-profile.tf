resource "azurerm_cdn_frontdoor_profile" "profile" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.current.name
  sku_name            = "${title(var.tier)}_AzureFrontDoor"

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.additional_tags
  )
}