locals {
  routes = flatten([
    for endpoint_name, endpoint_value in var.endpoints : [
      for route_name, route_value in endpoint_value.routes : {
        name                      = route_name
        endpoint_name             = endpoint_name
        origin_group_name         = route_value.origin_group_name
        forwarding_protocol       = route_value.forwarding_protocol != null ? route_value.forwarding_protocol : "MatchRequest"
        patterns_to_match         = route_value.patterns_to_match != null ? route_value.patterns_to_match : ["/*"]
        supported_protocols       = route_value.accepted_protocols != null ? route_value.accepted_protocols : ["Http", "Https"]
        cdn_frontdoor_origin_path = route_value.origin_path
        https_redirect_enabled    = route_value.https_redirect_enabled
        link_to_default_domain    = route_value.link_to_default_domain
        enabled                   = route_value.enabled
      }
    ] if endpoint_value.routes != null
  ])
}

resource "azurerm_cdn_frontdoor_route" "routes" {
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.origin_groups,
    azurerm_cdn_frontdoor_origin.origins
  ]

  count = length(local.routes)

  name                          = local.routes[count.index].name
  cdn_frontdoor_endpoint_id     = data.azurerm_cdn_frontdoor_endpoint.endpoints[local.routes[count.index].endpoint_name].id
  cdn_frontdoor_origin_group_id = data.azurerm_cdn_frontdoor_origin_group.origin_groups[local.origins[count.index].origin_group_name].id
  cdn_frontdoor_origin_ids      = local.origin_ids_by_origin_group[local.routes[count.index].origin_group_name]
  forwarding_protocol           = local.routes[count.index].forwarding_protocol
  patterns_to_match             = local.routes[count.index].patterns_to_match
  supported_protocols           = local.routes[count.index].supported_protocols
  cdn_frontdoor_origin_path     = local.routes[count.index].cdn_frontdoor_origin_path
  enabled                       = local.routes[count.index].enabled
  https_redirect_enabled        = local.routes[count.index].https_redirect_enabled
  link_to_default_domain        = local.routes[count.index].link_to_default_domain
}