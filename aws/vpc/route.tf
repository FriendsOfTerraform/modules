locals {
  routes = flatten([
    for k, v in var.route_tables : [
      for route_dest, route_target in v.routes : {
        route_table_name  = k,
        route_destination = route_dest
        route_target      = route_target
      }
    ]
  ])
}

resource "aws_route" "routes" {
  for_each = tomap({ for route in local.routes : "${route.route_table_name}~${route.route_destination}" => route })

  route_table_id              = aws_route_table.route_tables[each.value.route_table_name].id
  destination_cidr_block      = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9]))$", each.value.route_destination)) > 0 ? each.value.route_destination : null
  destination_ipv6_cidr_block = length(regexall("^s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\\/(12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))$", each.value.route_destination)) > 0 ? each.value.route_destination : null
  destination_prefix_list_id  = length(regexall("pl-[0-9a-f]{8}", each.value.route_destination)) > 0 ? each.value.route_destination : null

  carrier_gateway_id        = startswith(each.value.route_target, "cagw-") ? each.value.route_target : null
  core_network_arn          = startswith(each.value.route_target, "arn:") ? each.value.route_target : null
  egress_only_gateway_id    = startswith(each.value.route_target, "eigw-") ? each.value.route_target : null
  gateway_id                = each.value.route_target == "default-internet-gateway" ? aws_internet_gateway.internet_gateway[0].id : (startswith(each.value.route_target, "vgw-") ? each.value.route_target : null)
  nat_gateway_id            = startswith(each.value.route_target, "default-nat-gateway/") ? aws_nat_gateway.nat_gateway[split("/", each.value.route_target)[1]].id : (startswith(each.value.route_target, "nat-") ? each.value.route_target : null)
  local_gateway_id          = startswith(each.value.route_target, "lgw-") ? each.value.route_target : null
  network_interface_id      = startswith(each.value.route_target, "eni-") ? each.value.route_target : null
  transit_gateway_id        = startswith(each.value.route_target, "tgw-") ? each.value.route_target : null
  vpc_endpoint_id           = startswith(each.value.route_target, "vpce-") ? each.value.route_target : null
  vpc_peering_connection_id = contains(keys(var.peering_connection_requests), each.value.route_target) ? aws_vpc_peering_connection.peering_connection_requests[each.value.route_target].id : (startswith(each.value.route_target, "pcx-") ? each.value.route_target : null)
}
