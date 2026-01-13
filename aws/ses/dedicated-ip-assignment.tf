locals {
  pool_with_dedicated_ips = { for pool_name, pool in var.dedicated_ip_pools : pool_name => pool if length(pool.ip_addresses) > 0 }
  dedicated_ip_assignments = flatten([
    for pool_name, pool in local.pool_with_dedicated_ips : [
      for ip in pool.ip_addresses : {
        ip                    = ip
        destination_pool_name = pool_name
      }
    ]
  ])
}

resource "aws_sesv2_dedicated_ip_assignment" "dedicated_ip_assignments" {
  for_each = { for assignment in local.dedicated_ip_assignments : "${assignment.ip}-${assignment.destination_pool_name}" => assignment }

  ip                    = each.value.ip
  destination_pool_name = each.value.destination_pool_name
}