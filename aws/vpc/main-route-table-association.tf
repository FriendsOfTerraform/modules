locals {
  main_route_table = [for k, v in var.route_tables : k if v.main_route_table]
}

resource "aws_main_route_table_association" "main_route_table" {
  count = length(local.main_route_table) > 0 ? 1 : 0

  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route_tables[local.main_route_table[0]].id
}
