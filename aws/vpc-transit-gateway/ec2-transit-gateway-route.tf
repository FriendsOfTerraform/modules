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

resource "aws_ec2_transit_gateway_route" "routes" {
  for_each = tomap({ for route in local.routes : "${route.route_table_name}~${route.route_destination}" => route })

  destination_cidr_block         = each.value.route_destination
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route_tables[each.value.route_table_name].id
  blackhole                      = each.value.route_target == "blackhole"

  transit_gateway_attachment_id = each.value.route_target != "blackhole" ? (
    contains(keys(aws_ec2_transit_gateway_vpc_attachment.vpc_attachments), each.value.route_target) ? aws_ec2_transit_gateway_vpc_attachment.vpc_attachments[each.value.route_target].id : (
      contains(keys(aws_ec2_transit_gateway_peering_attachment.peering_connection_attachments), each.value.route_target) ? aws_ec2_transit_gateway_peering_attachment.peering_connection_attachments[each.value.route_target].id : (
        contains(keys(aws_vpn_connection.vpn_attachments), each.value.route_target) ? aws_vpn_connection.vpn_attachments[each.value.route_target].transit_gateway_attachment_id : (
          contains(keys(aws_ec2_transit_gateway_peering_attachment_accepter.peering_connection_attachment_accepters), each.value.route_target) ? aws_ec2_transit_gateway_peering_attachment_accepter.peering_connection_attachment_accepters[each.value.route_target].transit_gateway_attachment_id : null
        )
      )
    )
  ) : null
}
