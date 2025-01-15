resource "aws_eip" "nat_elastic_ips" {
  for_each = var.create_nat_gateways ? local.public_subnet_ids_by_availability_zones : {}

  domain = "vpc"

  tags = merge(
    { Name = "${var.name}-${each.key}-nat-gateway" },
    var.additional_tags_all
  )
}
