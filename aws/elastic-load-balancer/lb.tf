resource "aws_lb" "load_balancer" {
  name                                        = var.name
  internal                                    = !var.internet_facing
  ip_address_type                             = var.ip_address_type
  load_balancer_type                          = local.application_load_balancer ? "application" : (local.network_load_balancer ? "network" : "gateway")
  security_groups                             = var.security_group_ids
  client_keep_alive                           = local.application_load_balancer ? split(" ", var.application_load_balancer.attributes.http_client_keepalive_duration)[0] * local.time_table[trimsuffix(split(" ", var.application_load_balancer.attributes.http_client_keepalive_duration)[1], "s")] : null
  desync_mitigation_mode                      = local.application_load_balancer ? var.application_load_balancer.attributes.desync_mitigation_mode : null
  dns_record_client_routing_policy            = local.network_load_balancer ? var.network_load_balancer.attributes.client_routing_policy : null
  drop_invalid_header_fields                  = local.application_load_balancer ? var.application_load_balancer.attributes.drop_invalid_header_fields : null
  enable_cross_zone_load_balancing            = local.network_load_balancer ? var.network_load_balancer.attributes.enable_cross_zone_load_balancing : (local.gateway_load_balancer ? var.gateway_load_balancer.attributes.enable_cross_zone_load_balancing : null)
  enable_deletion_protection                  = var.enable_deletion_protection
  enable_http2                                = local.application_load_balancer ? var.application_load_balancer.attributes.enable_http2 : null
  enable_tls_version_and_cipher_suite_headers = local.application_load_balancer ? var.application_load_balancer.attributes.enable_tls_version_and_cipher_headers : null
  enable_xff_client_port                      = local.application_load_balancer ? var.application_load_balancer.attributes.enable_x_forwarded_for_client_port_preservation : null
  enable_waf_fail_open                        = local.application_load_balancer ? var.application_load_balancer.attributes.enable_waf_fail_open : null
  enable_zonal_shift                          = local.application_load_balancer ? var.application_load_balancer.attributes.enable_arc_zonal_shift_integration : (local.network_load_balancer ? var.network_load_balancer.attributes.enable_arc_zonal_shift_integration : null)
  idle_timeout                                = local.application_load_balancer ? split(" ", var.application_load_balancer.attributes.connection_idle_timeout)[0] * local.time_table[trimsuffix(split(" ", var.application_load_balancer.attributes.connection_idle_timeout)[1], "s")] : null
  preserve_host_header                        = local.application_load_balancer ? var.application_load_balancer.attributes.preserve_host_header : null
  xff_header_processing_mode                  = local.application_load_balancer ? var.application_load_balancer.attributes.x_forwarded_for_header_processing_mode : null

  dynamic "subnet_mapping" {
    for_each = var.network_mapping.subnets

    content {
      subnet_id            = subnet_mapping.key
      allocation_id        = subnet_mapping.value.elastic_ip_allocation_id
      ipv6_address         = subnet_mapping.value.ipv6_address
      private_ipv4_address = subnet_mapping.value.private_ipv4_address
    }
  }

  dynamic "ipam_pools" {
    for_each = local.application_load_balancer ? (var.network_mapping.ipam_pool_id != null ? [1] : []) : []

    content {
      ipv4_ipam_pool_id = var.network_mapping.ipam_pool_id
    }
  }

  dynamic "minimum_load_balancer_capacity" {
    for_each = var.capacity_unit_reservation != null ? [1] : []

    content {
      capacity_units = var.capacity_unit_reservation
    }
  }

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
