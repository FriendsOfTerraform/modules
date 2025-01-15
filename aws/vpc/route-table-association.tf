locals {
  route_table_associations = flatten([
    for k, v in var.route_tables : [
      for association in v.subnet_associations :
      {
        route_table_name = k
        subnet_name      = association
      }
    ]
  ])
}

resource "aws_route_table_association" "route_table_associations" {
  for_each = toset([for k in local.route_table_associations : "${k.route_table_name}~${k.subnet_name}"])

  subnet_id      = aws_subnet.subnets[split("~", each.value)[1]].id
  route_table_id = aws_route_table.route_tables[split("~", each.value)[0]].id
}
