resource "aws_ram_resource_share_accepter" "accepters" {
  for_each = toset(var.accept_sharings)

  share_arn = each.value
}
