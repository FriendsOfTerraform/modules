resource "aws_ec2_transit_gateway_route_table" "route_tables" {
  for_each = var.route_tables

  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id

  tags = merge(
    { Name = each.key },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
