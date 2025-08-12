resource "aws_ram_resource_association" "resources" {
  for_each = toset(var.resources)

  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.resource_share.arn
}
