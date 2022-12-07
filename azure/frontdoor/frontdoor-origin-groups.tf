resource "azurerm_cdn_frontdoor_origin_group" "origin_groups" {
  for_each = var.origin_groups

  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id

  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing != null ? each.value.load_balancing.latency_sensitivity_milliseconds : null
    sample_size                        = each.value.load_balancing != null ? each.value.load_balancing.sample_size : null
    successful_samples_required        = each.value.load_balancing != null ? each.value.load_balancing.successful_samples_required : null
  }

  dynamic "health_probe" {
    for_each = each.value.health_probe != null ? [1] : []

    content {
      protocol            = each.value.health_probe.protocol != null ? each.value.health_probe.protocol : "Http"
      interval_in_seconds = each.value.health_probe.interval_seconds != null ? each.value.health_probe.interval_seconds : 100
      request_type        = each.value.health_probe.probe_method
      path                = each.value.health_probe.path
    }
  }

  session_affinity_enabled = each.value.session_affinity_enabled
}