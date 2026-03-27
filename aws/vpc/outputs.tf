output "dhcp_options" {
  description = <<EOT
    DHCP option
    
    @type map(object({
      /// The ARN of the DHCP option
      /// 
      /// @since 1.0.0
      arn = string

      /// The ID of the DHCP option
      /// 
      /// @since 1.0.0
      id = string
    }))
    @since 1.0.0
  EOT
  value = var.dhcp_options != null ? {
    id  = aws_vpc_dhcp_options.dhcp_options[0].id
    arn = aws_vpc_dhcp_options.dhcp_options[0].arn
  } : {}
}

output "internet_gateway" {
  description = <<EOT
    The default internet gateway
    
    @type map(object({
      /// The ARN of the internet gateway
      /// 
      /// @since 1.0.0
      arn = string

      /// The ID of the internet gateway
      /// 
      /// @since 1.0.0
      id = string

      /// The ID of the AWS account that owns the internet gateway
      /// 
      /// @since 1.0.0
      owner_id = string
    }))
    @since 1.0.0
  EOT
  value = length(local.public_subnets) > 0 ? {
    id       = aws_internet_gateway.internet_gateway[0].id
    arn      = aws_internet_gateway.internet_gateway[0].arn
    owner_id = aws_internet_gateway.internet_gateway[0].owner_id
  } : {}
}

output "nat_gateways" {
  description = <<EOT
    Map of default NAT gateways. The key of the map is the NAT gateway's name
    
    @type map(object({
      /// The availability of the NAT gateway
      /// 
      /// @since 1.0.0
      availability_zone = string

      /// The association ID of the Elastic IP address that's associated with the NAT Gateway
      /// 
      /// @since 1.0.0
      association_id = string

      /// The ID of the NAT gateway
      /// 
      /// @since 1.0.0
      id = string

      /// The ID of the network interface associated with the NAT Gateway
      /// 
      /// @since 1.0.0
      network_interface_id = string

      /// The Elastic IP address associated with the NAT Gateway
      /// 
      /// @since 1.0.0
      public_ip = string
    }))
    @since 1.0.0
  EOT
  value = var.create_nat_gateways != null ? {
    for k, v in aws_nat_gateway.nat_gateway :
    v.tags.Name => {
      availability_zone    = k
      association_id       = v.association_id
      id                   = v.id
      network_interface_id = v.network_interface_id
      public_ip            = v.public_ip
    }
  } : {}
}

output "peering_connection_requests" {
  description = <<EOT
    Map of peering connection requests. The key of the map is the peering connection request's name
    
    @type map(object({
      /// The peering connection ID
      /// 
      /// @since 1.0.0
      id = string

      /// The status of the VPC Peering Connection request
      /// 
      /// @since 1.0.0
      accept_status = string
    }))
    @since 1.0.0
  EOT
  value = {
    for k, v in aws_vpc_peering_connection.peering_connection_requests :
    k => {
      id            = v.id
      accept_status = v.accept_status
    }
  }
}

output "route_tables" {
  description = <<EOT
    Map of route tables. The key of the map is the route table's name
    
    @type map(object({
      /// The ARN of the route tables
      /// 
      /// @since 1.0.0
      arn = string

      /// The ID of the route tables
      /// 
      /// @since 1.0.0
      id = string
    }))
    @since 1.0.0
  EOT
  value = {
    for k, v in aws_route_table.route_tables :
    k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "subnets" {
  description = <<EOT
    Map of subnets. The key of the map is the subnet's name
    
    @type map(object({
      /// The ARN of the subnets
      /// 
      /// @since 1.0.0
      arn = string

      /// The ID of the subnets
      /// 
      /// @since 1.0.0
      id = string

      /// The ID of the AWS account that owns the subnet
      /// 
      /// @since 1.0.0
      owner_id = string
    }))
    @since 1.0.0
  EOT
  value = {
    for k, v in aws_subnet.subnets :
    k => {
      id       = v.id
      arn      = v.arn
      owner_id = v.owner_id
    }
  }
}

output "vpc_arn" {
  description = <<EOT
    The ARN of the VPC
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_vpc.vpc.arn
}

output "vpc_id" {
  description = <<EOT
    The ID of the VPC
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_vpc.vpc.id
}
