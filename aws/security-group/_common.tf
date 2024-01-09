locals {
  common_tags = {
    managed-by = "Terraform"
  }

  all_port_range  = ["all_tcp", "all_udp"] # These protocols cover all port ranges
  icmp_port_range = ["icmp", "icmpv6"]     # These protocols cover all ICMP ranges
}
