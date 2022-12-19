resource "azurerm_cdn_frontdoor_endpoint" "endpoints" {
  for_each = var.endpoints

  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  enabled                  = each.value.enabled

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    each.value.additional_tags
  )
}