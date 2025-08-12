resource "aws_ram_principal_association" "principals" {
  for_each = toset(var.principals)

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.resource_share.arn
}
