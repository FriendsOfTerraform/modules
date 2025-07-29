locals {
  route_table_associations = flatten([
    for k, v in var.route_tables : [
      for association in v.attachment_associations :
      {
        route_table_name = k
        attachment_name  = association
      }
    ]
  ])
}

resource "aws_ec2_transit_gateway_route_table_association" "route_table_associations" {
  for_each = toset([for k in local.route_table_associations : "${k.route_table_name}~${k.attachment_name}"])

  transit_gateway_attachment_id = contains(keys(aws_ec2_transit_gateway_vpc_attachment.vpc_attachments), split("~", each.value)[1]) ? aws_ec2_transit_gateway_vpc_attachment.vpc_attachments[split("~", each.value)[1]].id : (
    contains(keys(aws_ec2_transit_gateway_peering_attachment.peering_connection_attachments), split("~", each.value)[1]) ? aws_ec2_transit_gateway_peering_attachment.peering_connection_attachments[split("~", each.value)[1]].id : (
      contains(keys(aws_vpn_connection.vpn_attachments), split("~", each.value)[1]) ? aws_vpn_connection.vpn_attachments[split("~", each.value)[1]].transit_gateway_attachment_id : (
        contains(keys(aws_ec2_transit_gateway_peering_attachment_accepter.peering_connection_attachment_accepters), split("~", each.value)[1]) ? aws_ec2_transit_gateway_peering_attachment_accepter.peering_connection_attachment_accepters[split("~", each.value)[1]].transit_gateway_attachment_id : null
      )
    )
  )
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route_tables[split("~", each.value)[0]].id
}
