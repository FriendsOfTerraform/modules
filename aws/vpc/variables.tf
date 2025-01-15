variable "cidr_block" {
  type = object({
    ipv4 = object({
      cidr = optional(string, null)
      ipam = optional(object({
        pool_id = string
        netmask = string
      }), null)
    })
  })
  description = "Specify the VPC CIDR block"
}

variable "name" {
  type        = string
  description = "The name of the VPC. All associated resources' names will also be prefixed by this value"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the VPC"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "create_nat_gateways" {
  type        = bool
  description = "Create default NAT gateways"
  default     = false
}

variable "dhcp_options" {
  type = object({
    domain_name          = optional(string, null)
    domain_name_servers  = optional(list(string), ["AmazonProvidedDNS"])
    ntp_servers          = optional(list(string), null)
    netbios_name_servers = optional(list(string), null)
    netbios_node_type    = optional(number, null)
    additional_tags      = optional(map(string), {})
  })
  description = "Configure DHCP options"
  default     = null
}

variable "dns_settings" {
  type = object({
    enable_dns_resolution = optional(bool, true)
    enable_dns_hostnames  = optional(bool, false)
  })
  description = "Configure DNS settings"
  default     = {}
}

variable "enable_network_address_usage_metrics" {
  type        = bool
  description = "Enable Network Address Usage meteric"
  default     = false
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

    additional_tags              = optional(map(string), {})
    custom_log_record_format     = optional(string, null)
    filter                       = optional(string, "ALL")
    maximum_aggregation_interval = optional(number, 600)
  }))
  description = "Configure multiple flow logs"
  default     = {}
}

variable "peering_connection_requests" {
  type = map(object({
    peer_vpc_id                     = string
    additional_tags                 = optional(map(string), {})
    allow_remote_vpc_dns_resolution = optional(bool, false)
    peer_account_id                 = optional(string, null)
    peer_region                     = optional(string, null)
  }))
  description = "Manage peering connection requests"
  default     = {}
}

variable "route_tables" {
  type = map(object({
    additional_tags     = optional(map(string), {})
    routes              = optional(map(string), {})
    subnet_associations = optional(list(string), [])
  }))
  description = "Manage multiple route tables"
  default     = {}
}

variable "subnets" {
  type = map(object({
    availability_zone                      = string
    ipv4_cidr_block                        = string
    additional_tags                        = optional(map(string), {})
    enable_auto_assign_public_ipv4_address = optional(bool, false)

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

      additional_tags              = optional(map(string), {})
      custom_log_record_format     = optional(string, null)
      filter                       = optional(string, "ALL")
      maximum_aggregation_interval = optional(number, 600)
    })), {})

    resource_based_name_settings = optional(object({
      enable_resource_name_dns_a_record_on_launch = optional(bool, false)
      hostname_type                               = optional(string, "ip-name")
    }), {})
  }))
  description = "Configure multiple subnets"
  default     = {}
}

variable "tenancy" {
  type        = string
  description = "Specify the VPC's tenancy"
  default     = "default"
}
