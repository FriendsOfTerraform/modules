locals {
  vpn_attachments = { for k, v in var.attachments : k => v if v.vpn != null }

  time_table = {
    second = 1
    minute = 60
    hour   = 3600
  }
}

resource "aws_vpn_connection" "vpn_attachments" {
  for_each = local.vpn_attachments

  customer_gateway_id                     = each.value.vpn.customer_gateway_id
  transit_gateway_id                      = aws_ec2_transit_gateway.transit_gateway.id
  type                                    = "ipsec.1"
  static_routes_only                      = each.value.vpn.routing_options == "static"
  enable_acceleration                     = each.value.vpn.enable_acceleration
  preshared_key_storage                   = each.value.vpn.preshared_key_storage
  local_ipv4_network_cidr                 = each.value.vpn.local_ipv4_network_cidr
  outside_ip_address_type                 = each.value.vpn.outside_ip_address_type
  remote_ipv4_network_cidr                = each.value.vpn.remote_ipv4_network_cidr
  transport_transit_gateway_attachment_id = each.value.vpn.transport_transit_gateway_attachment_id
  tunnel1_dpd_timeout_action              = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.dpd_timeout_action : null
  tunnel1_dpd_timeout_seconds             = each.value.vpn.tunnel1_options != null ? split(" ", each.value.vpn.tunnel1_options.dpd_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.vpn.tunnel1_options.dpd_timeout)[1], "s")] : null
  tunnel1_enable_tunnel_lifecycle_control = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.enable_tunnel_endpoint_lifecycle_control : null
  tunnel1_ike_versions                    = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.ike_version : null
  tunnel1_inside_cidr                     = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.inside_ipv4_cidr : null
  tunnel1_phase1_dh_group_numbers         = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.phase1_dh_group_numbers : null
  tunnel1_phase1_encryption_algorithms    = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.phase1_encryption_algorithms : null
  tunnel1_phase1_integrity_algorithms     = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.phase1_integrity_algorithms : null
  tunnel1_phase1_lifetime_seconds         = each.value.vpn.tunnel1_options != null ? split(" ", each.value.vpn.tunnel1_options.phase1_lifetime)[0] * local.time_table[trimsuffix(split(" ", each.value.vpn.tunnel1_options.phase1_lifetime)[1], "s")] : null
  tunnel1_phase2_dh_group_numbers         = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.phase2_dh_group_numbers : null
  tunnel1_phase2_encryption_algorithms    = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.phase2_encryption_algorithms : null
  tunnel1_phase2_integrity_algorithms     = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.phase2_integrity_algorithms : null
  tunnel1_phase2_lifetime_seconds         = each.value.vpn.tunnel1_options != null ? split(" ", each.value.vpn.tunnel1_options.phase2_lifetime)[0] * local.time_table[trimsuffix(split(" ", each.value.vpn.tunnel1_options.phase2_lifetime)[1], "s")] : null
  tunnel1_preshared_key                   = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.preshared_key : null
  tunnel1_rekey_fuzz_percentage           = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.rekey_fuzz_percentage : null
  tunnel1_replay_window_size              = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.replay_window_size : null
  tunnel1_startup_action                  = each.value.vpn.tunnel1_options != null ? each.value.vpn.tunnel1_options.startup_action : null
  tunnel2_dpd_timeout_action              = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.dpd_timeout_action : null
  tunnel2_dpd_timeout_seconds             = each.value.vpn.tunnel2_options != null ? split(" ", each.value.vpn.tunnel2_options.dpd_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.vpn.tunnel2_options.dpd_timeout)[1], "s")] : null
  tunnel2_enable_tunnel_lifecycle_control = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.enable_tunnel_endpoint_lifecycle_control : null
  tunnel2_ike_versions                    = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.ike_version : null
  tunnel2_inside_cidr                     = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.inside_ipv4_cidr : null
  tunnel2_phase1_dh_group_numbers         = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.phase1_dh_group_numbers : null
  tunnel2_phase1_encryption_algorithms    = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.phase1_encryption_algorithms : null
  tunnel2_phase1_integrity_algorithms     = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.phase1_integrity_algorithms : null
  tunnel2_phase1_lifetime_seconds         = each.value.vpn.tunnel2_options != null ? split(" ", each.value.vpn.tunnel2_options.phase1_lifetime)[0] * local.time_table[trimsuffix(split(" ", each.value.vpn.tunnel2_options.phase1_lifetime)[1], "s")] : null
  tunnel2_phase2_dh_group_numbers         = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.phase2_dh_group_numbers : null
  tunnel2_phase2_encryption_algorithms    = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.phase2_encryption_algorithms : null
  tunnel2_phase2_integrity_algorithms     = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.phase2_integrity_algorithms : null
  tunnel2_phase2_lifetime_seconds         = each.value.vpn.tunnel2_options != null ? split(" ", each.value.vpn.tunnel2_options.phase2_lifetime)[0] * local.time_table[trimsuffix(split(" ", each.value.vpn.tunnel2_options.phase2_lifetime)[1], "s")] : null
  tunnel2_preshared_key                   = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.preshared_key : null
  tunnel2_rekey_fuzz_percentage           = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.rekey_fuzz_percentage : null
  tunnel2_replay_window_size              = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.replay_window_size : null
  tunnel2_startup_action                  = each.value.vpn.tunnel2_options != null ? each.value.vpn.tunnel2_options.startup_action : null

  dynamic "tunnel1_log_options" {
    for_each = each.value.vpn.tunnel1_options != null ? (each.value.vpn.tunnel1_options.enable_tunnel_activity_log != null ? [1] : []) : []

    content {
      cloudwatch_log_options {
        log_enabled       = true
        log_group_arn     = each.value.vpn.tunnel1_options.enable_tunnel_activity_log.cloudwatch_log_group_arn
        log_output_format = each.value.vpn.tunnel1_options.enable_tunnel_activity_log.output_format
      }
    }
  }

  dynamic "tunnel2_log_options" {
    for_each = each.value.vpn.tunnel2_options != null ? (each.value.vpn.tunnel2_options.enable_tunnel_activity_log != null ? [1] : []) : []

    content {
      cloudwatch_log_options {
        log_enabled       = true
        log_group_arn     = each.value.vpn.tunnel2_options.enable_tunnel_activity_log.cloudwatch_log_group_arn
        log_output_format = each.value.vpn.tunnel2_options.enable_tunnel_activity_log.output_format
      }
    }
  }

  tags = merge(
    { Name = each.key },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
