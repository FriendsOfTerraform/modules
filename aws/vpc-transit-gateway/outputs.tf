output "transit_gateway" {
  description = <<EOT
    Transit gateway

    @type object({
      /// The ARN of the transit gateway
      ///
      /// @since 1.0.0
      arn = string

      /// Identifier of the default association route table
      ///
      /// @since 1.0.0
      association_default_route_table_id = string

      /// The ID of the transit gateway
      ///
      /// @since 1.0.0
      id = string

      /// Identifier of the AWS account that owns the EC2 Transit Gateway
      ///
      /// @since 1.0.0
      owner_id = string

      /// Identifier of the default propagation route table
      ///
      /// @since 1.0.0
      propagation_default_route_table_id = string
    })
    @since 1.0.0
  EOT
  value = {
    arn                                = aws_ec2_transit_gateway.transit_gateway.arn
    association_default_route_table_id = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
    id                                 = aws_ec2_transit_gateway.transit_gateway.id
    owner_id                           = aws_ec2_transit_gateway.transit_gateway.owner_id
    propagation_default_route_table_id = aws_ec2_transit_gateway.transit_gateway.propagation_default_route_table_id
  }
}
