resource "aws_route53_zone" "hosted_zone" {
  name    = var.domain_name
  comment = var.description

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )

  dynamic "vpc" {
    for_each = var.primary_private_zone_vpc_association != null ? [1] : []

    content {
      vpc_id     = var.primary_private_zone_vpc_association.vpc_id
      vpc_region = var.primary_private_zone_vpc_association.region != null ? var.primary_private_zone_vpc_association.region : data.aws_region.current.region
    }
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}
