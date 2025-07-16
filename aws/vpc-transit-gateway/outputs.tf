output "transit_gateway" {
  value = {
    arn                                = aws_ec2_transit_gateway.transit_gateway.arn
    association_default_route_table_id = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
    id                                 = aws_ec2_transit_gateway.transit_gateway.id
    owner_id                           = aws_ec2_transit_gateway.transit_gateway.owner_id
    propagation_default_route_table_id = aws_ec2_transit_gateway.transit_gateway.propagation_default_route_table_id
  }
}

output "vpc_attachments" {
  value = { for k, v in local.local.vpc_attachments : k => {
    id           = aws_ec2_transit_gateway_vpc_attachment.vpc_attachments[k].id
    vpc_owner_id = aws_ec2_transit_gateway_vpc_attachment.vpc_attachments[k].vpc_owner_id
  } }
}
