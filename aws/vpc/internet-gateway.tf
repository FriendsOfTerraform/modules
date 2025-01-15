resource "aws_internet_gateway" "internet_gateway" {
  count = length(local.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { Name = "${var.name}-internet-gateway" },
    var.additional_tags_all
  )
}
