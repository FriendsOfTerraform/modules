locals {
  common_tags = {
    managed-by = "Terraform"
  }

  private_subnets                          = [for k, v in var.subnets : k if !v.enable_auto_assign_public_ipv4_address]
  private_subnet_ids_by_availability_zones = { for subnet in values(aws_subnet.subnets) : subnet.availability_zone => subnet.id... if !subnet.map_public_ip_on_launch }
  public_subnets                           = [for k, v in var.subnets : k if v.enable_auto_assign_public_ipv4_address]
  public_subnet_ids_by_availability_zones  = { for subnet in values(aws_subnet.subnets) : subnet.availability_zone => subnet.id... if subnet.map_public_ip_on_launch }
}
