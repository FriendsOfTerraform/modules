resource "aws_route53_vpc_association_authorization" "vpc_association_authorizations" {
  for_each = toset(var.vpc_association_authorizations)

  vpc_id  = each.value
  zone_id = aws_route53_zone.hosted_zone.id
}
