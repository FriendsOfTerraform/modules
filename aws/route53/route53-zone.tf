resource "aws_route53_zone" "hosted_zone" {
  name    = var.domain_name
  comment = var.description

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )

  dynamic "vpc" {
    for_each = toset(flatten([
      for region, vpc_ids in var.private_zone_vpc_associations : [
        for vpc_id in vpc_ids : {
          region = region
          vpc_id = vpc_id
        }
      ]
    ]))

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.region
    }
  }
}
