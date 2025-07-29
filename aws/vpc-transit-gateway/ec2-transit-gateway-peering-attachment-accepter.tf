locals {
  peering_connection_attachment_accepters = { for k, v in local.peering_connection_attachments : k => v if v.peering_connection.accept_connection_from != null }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peering_connection_attachment_accepters" {
  for_each = local.peering_connection_attachment_accepters

  transit_gateway_attachment_id = each.value.peering_connection.accept_connection_from

  tags = merge(
    { Name = each.key },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
