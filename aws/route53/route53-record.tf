resource "aws_route53_record" "records" {
  for_each = var.records

  zone_id         = aws_route53_zone.hosted_zone.zone_id
  name            = split("/", each.key)[0]
  type            = each.value.type
  ttl             = each.value.alias != null ? null : each.value.ttl
  records         = each.value.values
  set_identifier  = length(split("/", each.key)) > 1 ? split("/", each.key)[1] : null
  health_check_id = each.value.health_check != null ? aws_route53_health_check.health_checks[each.key].id : each.value.health_check_id

  dynamic "alias" {
    for_each = each.value.alias != null ? [1] : []

    content {
      name                   = each.value.alias.target
      zone_id                = each.value.alias.hosted_zone_id
      evaluate_target_health = each.value.alias.evaluate_target_health
    }
  }

  # for some reason, set_identifier is required even when multivalue_answer_routing_policy is set to false...
  # using null instead
  multivalue_answer_routing_policy = each.value.multivalue_answer_routing_policy != null ? (
    each.value.multivalue_answer_routing_policy.enabled ? true : null
  ) : null

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [1] : []

    content {
      type = each.value.failover_routing_policy.failover_record_type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [1] : []

    content {
      continent = lookup(local.continents, title(lower(each.value.geolocation_routing_policy.location)), null)

      # If country is not specified
      country = lookup(local.countries, title(lower(each.value.geolocation_routing_policy.location)), null) == null ? (
        # Set country code to "US" if a US subdivision is specified
        lookup(local.united_states_subdivisions, title(lower(each.value.geolocation_routing_policy.location)), null) != null ? "US" : (
          # Set country code to "UA" if a Ukrain subdivision is specified, otherwise, set country code to null
          lookup(local.ukraine_subdivisions, title(lower(each.value.geolocation_routing_policy.location)), null) != null ? "UA" : null
        )
      ) : local.countries[title(lower(each.value.geolocation_routing_policy.location))]

      subdivision = lookup(local.united_states_subdivisions, title(lower(each.value.geolocation_routing_policy.location)), null) == null ? (
        lookup(local.ukraine_subdivisions, title(lower(each.value.geolocation_routing_policy.location)), null)
      ) : local.united_states_subdivisions[title(lower(each.value.geolocation_routing_policy.location))]
    }
  }

  dynamic "geoproximity_routing_policy" {
    for_each = each.value.geoproximity_routing_policy != null ? [1] : []

    content {
      aws_region       = each.value.geoproximity_routing_policy.region
      bias             = each.value.geoproximity_routing_policy.bias
      local_zone_group = each.value.geoproximity_routing_policy.local_zone_group

      dynamic "coordinates" {
        for_each = each.value.geoproximity_routing_policy.coordinates != null ? [1] : []

        content {
          latitude  = each.value.geoproximity_routing_policy.coordinates.latitude
          longitude = each.value.geoproximity_routing_policy.coordinates.longitude
        }
      }
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [1] : []

    content {
      region = each.value.latency_routing_policy.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [1] : []

    content {
      weight = each.value.weighted_routing_policy.weight
    }
  }
}
