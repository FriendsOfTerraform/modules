locals {
  private_zone_vpc_associations_to_create = flatten([
    for region, vpc_ids in var.private_zone_vpc_associations : [
      for vpc_id in vpc_ids : {
        region = region
        vpc_id = vpc_id
      }
    ]
  ])
}

resource "aws_route53_zone_association" "private_zone_vpc_associations" {
  for_each = tomap({ for vpc_association in local.private_zone_vpc_associations_to_create : "${vpc_association.region}-${vpc_association.vpc_id}" => vpc_association })

  zone_id    = aws_route53_zone.hosted_zone.zone_id
  vpc_id     = each.value.vpc_id
  vpc_region = each.value.region
}