resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  count = var.dhcp_options != null ? 1 : 0

  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options[0].id
}
