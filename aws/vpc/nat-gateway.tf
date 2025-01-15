resource "aws_nat_gateway" "nat_gateway" {
  for_each = var.create_nat_gateways ? local.public_subnet_ids_by_availability_zones : {}

  allocation_id     = aws_eip.nat_elastic_ips[each.key].allocation_id
  connectivity_type = "public"
  subnet_id         = each.value[0] # one NAT gateway will be deployed in the first public subnet of each availability zone

  tags = merge(
    { Name = "${var.name}-${each.key}-nat-gateway" },
    var.additional_tags_all
  )
}
