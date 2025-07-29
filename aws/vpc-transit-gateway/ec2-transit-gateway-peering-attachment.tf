locals {
  peering_connection_attachments           = { for k, v in var.attachments : k => v if v.peering_connection != null }
  peering_connection_attachment_requestors = { for k, v in local.peering_connection_attachments : k => v if v.peering_connection.peer_transit_gateway_id != null }
}

resource "aws_ec2_transit_gateway_peering_attachment" "peering_connection_attachments" {
  for_each = local.peering_connection_attachment_requestors

  peer_account_id         = each.value.peering_connection.peer_account_id
  peer_region             = each.value.peering_connection.peer_region != null ? each.value.peering_connection.peer_region : data.aws_region.current.region
  peer_transit_gateway_id = each.value.peering_connection.peer_transit_gateway_id
  transit_gateway_id      = aws_ec2_transit_gateway.transit_gateway.id

  tags = merge(
    { Name = each.key },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
