variable "name" {
  type        = string
  description = "The name of the VPC transit gateway. All associated resources' names will also be prefixed by this value"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the VPC transit gateway"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "amazon_side_autonomous_system_numnber" {
  type        = number
  description = "The Autonomous System Number (ASN) for the AWS side of a Border Gateway Protocol (BGP) session"
  default     = 64512
}

variable "attachments" {
  type = map(object({
    additional_tags = optional(map(string), {})

    flow_logs = optional(map(object({
      destination = object({
        cloudwatch_logs = optional(object({
          log_group_arn    = string
          service_role_arn = optional(string, null)
        }), null)

        s3 = optional(object({
          bucket_arn                       = string
          log_file_format                  = optional(string, "plain-text")
          enable_hive_compatible_s3_prefix = optional(bool, false)
          partition_logs_every_hour        = optional(bool, false)
        }), null)
      })

      additional_tags          = optional(map(string), {})
      custom_log_record_format = optional(string, null)
      filter                   = optional(string, "ALL")
    })), {})

    peering_connection = optional(object({
      accept_connection_from  = optional(string, null)
      peer_transit_gateway_id = optional(string, null)
      peer_account_id         = optional(string, null)
      peer_region             = optional(string, null)
    }), null)

    vpc = optional(object({
      vpc_id                                    = string
      subnet_ids                                = list(string)
      enable_dns_support                        = optional(bool, true)
      enable_security_group_referencing_support = optional(bool, true)
      enable_ipv6_support                       = optional(bool, false)
      enable_appliance_mode_support             = optional(bool, false)
    }), null)

    vpn = optional(object({
      customer_gateway_id                     = string
      routing_options                         = optional(string, "dynamic")
      preshared_key_storage                   = optional(string, "Standard")
      enable_acceleration                     = optional(bool, false)
      local_ipv4_network_cidr                 = optional(string, "0.0.0.0/0")
      remote_ipv4_network_cidr                = optional(string, "0.0.0.0/0")
      outside_ip_address_type                 = optional(string, "PublicIpv4")
      transport_transit_gateway_attachment_id = optional(string, null)

      tunnel1_options = optional(object({
        dpd_timeout                              = optional(string, "30 seconds")
        dpd_timeout_action                       = optional(string, "clear")
        enable_tunnel_endpoint_lifecycle_control = optional(bool, false)
        ike_version                              = optional(list(string), ["ikev1", "ikev2"])
        inside_ipv4_cidr                         = optional(string, null)
        phase1_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        phase1_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        phase1_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        phase1_lifetime                          = optional(string, "8 hours")
        phase2_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        phase2_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        phase2_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        phase2_lifetime                          = optional(string, "1 hour")
        preshared_key                            = optional(string, null)
        rekey_fuzz_percentage                    = optional(number, 100)
        rekey_margin_time                        = optional(string, "270 seconds")
        replay_window_size                       = optional(number, 1024)
        startup_action                           = optional(string, "add")

        enable_tunnel_activity_log = optional(object({
          cloudwatch_log_group_arn = string
          output_format            = optional(string, "json")
        }), null)
      }), null)

      tunnel2_options = optional(object({
        dpd_timeout                              = optional(string, "30 seconds")
        dpd_timeout_action                       = optional(string, "clear")
        enable_tunnel_endpoint_lifecycle_control = optional(bool, false)
        ike_version                              = optional(list(string), ["ikev1", "ikev2"])
        inside_ipv4_cidr                         = optional(string, null)
        phase1_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        phase1_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        phase1_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        phase1_lifetime                          = optional(string, "8 hours")
        phase2_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        phase2_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        phase2_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        phase2_lifetime                          = optional(string, "1 hour")
        preshared_key                            = optional(string, null)
        rekey_fuzz_percentage                    = optional(number, 100)
        rekey_margin_time                        = optional(string, "270 seconds")
        replay_window_size                       = optional(number, 1024)
        startup_action                           = optional(string, "add")

        enable_tunnel_activity_log = optional(object({
          cloudwatch_log_group_arn = string
          output_format            = optional(string, "json")
        }), null)
      }), null)
    }), null)
  }))
  description = "Manages multiple transit gateway attachments"
  default     = {}
}

variable "description" {
  type        = string
  description = "The description of the VPC transit gateway"
  default     = null
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable Domain Name System resolution for VPCs attached to this transit gateway."
  default     = true
}

variable "enable_security_group_referencing_support" {
  type        = bool
  description = "Enable Security Group referencing for VPCs attached to this transit gateway."
  default     = false
}

variable "enable_vpn_ecmp_support" {
  type        = bool
  description = "Equal cost multipath (ECMP) routing for VPN Connections that are attached to this transit gateway."
  default     = true
}

variable "enable_default_route_table_association" {
  type        = bool
  description = "Automatically associate transit gateway attachments with this transit gateway's default route table."
  default     = true
}

variable "enable_default_route_table_propagation" {
  type        = bool
  description = "Automatically propagate transit gateway attachments with this transit gateway's default route table."
  default     = true
}

variable "enable_multicast_support" {
  type        = bool
  description = "Enables the ability to create multicast domains in this transit gateway."
  default     = false
}

variable "auto_accept_shared_attachments" {
  type        = bool
  description = "Automatically accept cross-account attachments that are attached to this transit gateway."
  default     = false
}

variable "cidr_blocks" {
  type        = list(string)
  description = "You can associate any public or private IP address range, except for addresses in the 169.254.0.0/16 range, and ranges that overlap with the addresses for your VPC attachments and on-premises networks."
  default     = null
}

variable "flow_logs" {
  type = map(object({
    destination = object({
      cloudwatch_logs = optional(object({
        log_group_arn    = string
        service_role_arn = optional(string, null)
      }), null)

      s3 = optional(object({
        bucket_arn                       = string
        log_file_format                  = optional(string, "plain-text")
        enable_hive_compatible_s3_prefix = optional(bool, false)
        partition_logs_every_hour        = optional(bool, false)
      }), null)
    })

    additional_tags          = optional(map(string), {})
    custom_log_record_format = optional(string, null)
    filter                   = optional(string, "ALL")
  }))
  description = "Configure multiple transit gateway flow logs"
  default     = {}
}

variable "route_tables" {
  type = map(object({
    additional_tags         = optional(map(string), {})
    routes                  = optional(map(string), {})
    attachment_associations = optional(list(string), [])
    propagations            = optional(list(string), [])
  }))
  description = "Manage multiple route tables"
  default     = {}
}
