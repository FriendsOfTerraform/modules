data "azurerm_resource_group" "current" {
  name = var.azure.resource_group_name
}

data "azurerm_cdn_frontdoor_endpoint" "endpoints" {
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.endpoints,
    azurerm_cdn_frontdoor_profile.profile
  ]

  for_each = var.endpoints

  name                = each.key
  profile_name        = azurerm_cdn_frontdoor_profile.profile.name
  resource_group_name = data.azurerm_resource_group.current.name
}

data "azurerm_cdn_frontdoor_origin_group" "origin_groups" {
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.origin_groups,
    azurerm_cdn_frontdoor_profile.profile
  ]

  for_each = var.origin_groups

  name                = each.key
  profile_name        = azurerm_cdn_frontdoor_profile.profile.name
  resource_group_name = data.azurerm_resource_group.current.name
}

locals {
  common_tags = {
    managed-by = "Terraform"
  }

  location = var.azure.location != null ? var.azure.location : data.azurerm_resource_group.current.location

  # {resource_group_id}/providers/Microsoft.Cdn/profiles/{profileName}/originGroups/{originGroupName}/origins/{originName}
  origin_ids_by_origin_group = {
    for og_name, og_value in var.origin_groups :
    og_name => [
      for o_name, o_value in og_value.origins :
      "${data.azurerm_resource_group.current.id}/providers/Microsoft.Cdn/profiles/${var.name}/originGroups/${og_name}/origins/${o_name}"
    ] if og_value.origins != null
  }
}
