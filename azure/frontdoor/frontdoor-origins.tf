locals {
  origins = flatten([
    for og_name, og_value in var.origin_groups : [
      for o_name, o_value in og_value.origins : {
        origin_group_name              = og_name
        origin_name                    = o_name
        hostname                       = o_value.hostname
        certificate_check_name_enabled = o_value.certificate_subject_name_validation != null ? o_value.certificate_subject_name_validation : true
        http_port                      = o_value.http_port
        https_port                     = o_value.https_port
        origin_host_header             = o_value.origin_host_header != null ? o_value.origin_host_header : o_value.hostname
        priority                       = o_value.priority
        weight                         = o_value.weight
        enabled                        = o_value.enabled != null ? o_value.enabled : true
      }
    ] if og_value.origins != null
  ])
}

resource "azurerm_cdn_frontdoor_origin" "origins" {
  count = length(local.origins)

  name                           = local.origins[count.index].origin_name
  cdn_frontdoor_origin_group_id  = data.azurerm_cdn_frontdoor_origin_group.origin_groups[local.origins[count.index].origin_group_name].id
  host_name                      = local.origins[count.index].hostname
  certificate_name_check_enabled = local.origins[count.index].certificate_check_name_enabled
  http_port                      = local.origins[count.index].http_port
  https_port                     = local.origins[count.index].https_port
  origin_host_header             = local.origins[count.index].origin_host_header
  priority                       = local.origins[count.index].priority
  weight                         = local.origins[count.index].weight
  enabled                        = local.origins[count.index].enabled
}