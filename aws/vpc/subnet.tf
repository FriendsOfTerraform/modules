resource "aws_subnet" "subnets" {
  for_each = var.subnets

  availability_zone                           = each.value.availability_zone
  cidr_block                                  = each.value.ipv4_cidr_block
  enable_resource_name_dns_a_record_on_launch = each.value.resource_based_name_settings.enable_resource_name_dns_a_record_on_launch
  map_public_ip_on_launch                     = each.value.enable_auto_assign_public_ipv4_address
  private_dns_hostname_type_on_launch         = each.value.resource_based_name_settings.hostname_type
  vpc_id                                      = aws_vpc.vpc.id

  tags = merge(
    {
      Name = each.key
    },
    each.value.additional_tags,
    var.additional_tags_all
  )
}
