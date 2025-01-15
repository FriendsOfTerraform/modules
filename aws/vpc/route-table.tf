resource "aws_route_table" "route_tables" {
  for_each = var.route_tables

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { Name = each.key },
    each.value.additional_tags,
    var.additional_tags_all
  )
}
