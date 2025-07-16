locals {
  vpc_attachments = { for k, v in var.attachments : k => v if v.vpc != null }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachments" {
  for_each = local.vpc_attachments

  subnet_ids                         = each.value.vpc.subnet_ids
  transit_gateway_id                 = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id                             = each.value.vpc.vpc_id
  appliance_mode_support             = each.value.vpc.enable_application_support ? "enable" : "disable"
  dns_support                        = each.value.vpc.enable_dns_support ? "enable" : "disable"
  ipv6_support                       = each.value.vpc.enable_ipv6_support ? "enable" : "disable"
  security_group_referencing_support = each.value.vpc.enable_security_group_referencing_support ? "enable" : "disable"

  tags = merge(
    { Name = each.key },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
