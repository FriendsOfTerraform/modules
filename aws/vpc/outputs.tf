output "dhcp_options" {
  value = var.dhcp_options != null ? {
    id  = aws_vpc_dhcp_options.dhcp_options[0].id
    arn = aws_vpc_dhcp_options.dhcp_options[0].arn
  } : {}
}

output "internet_gateway" {
  value = length(local.public_subnets) > 0 ? {
    id       = aws_internet_gateway.internet_gateway[0].id
    arn      = aws_internet_gateway.internet_gateway[0].arn
    owner_id = aws_internet_gateway.internet_gateway[0].owner_id
  } : {}
}

output "nat_gateways" {
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
  value = {
    for k, v in aws_vpc_peering_connection.peering_connection_requests :
    k => {
      id            = v.id
      accept_status = v.accept_status
    }
  }
}

output "route_tables" {
  value = {
    for k, v in aws_route_table.route_tables :
    k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "subnets" {
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
  value = aws_vpc.vpc.arn
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
