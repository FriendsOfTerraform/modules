variable "name" {
  type        = string
  description = <<EOT
    The name of the VPC transit gateway. All associated resources' names will also be prefixed by this value

    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the VPC transit gateway

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "amazon_side_autonomous_system_numnber" {
  type        = number
  description = <<EOT
    The Autonomous System Number (ASN) for the AWS side of a Border Gateway Protocol (BGP) session

    @since 1.0.0
  EOT
  default     = 64512
}

variable "attachments" {
  type = map(object({
    /// Additional tags for the attachment
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Configures multiple attachment level flow logs.
    ///
    /// @since 1.0.0
    flow_logs = optional(map(object({
      /// Where the flow log will be sent to. Must specify only one of the following: `cloudwatch_logs`, `s3`
      ///
      /// @since 1.0.0
      destination = object({
        /// Configures CloudWatch Logs as destination
        ///
        /// @since 1.0.0
        cloudwatch_logs = optional(object({
          /// The ARN of the CloudWatch log group to send logs to
          ///
          /// @since 1.0.0
          log_group_arn    = string
          /// Arn of an IAM role that [gives permission to flow logs to send logs to CloudWatch][vpc-flow-logs-cloudwatch-service-role]. A default service role will be created if not specified
          ///
          /// @link {vpc-flow-logs-cloudwatch-service-role} https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-iam-role.html
          /// @since 1.0.0
          service_role_arn = optional(string, null)
        }), null)

        /// Configures S3 as destination
        ///
        /// @since 1.0.0
        s3 = optional(object({
          /// The ARN of the S3 bucket to send logs to
          ///
          /// @since 1.0.0
          bucket_arn                       = string
          /// The format for the flow log.
          ///
          /// @enum plain-text|parquet
          /// @since 1.0.0
          log_file_format                  = optional(string, "plain-text")
          /// Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3
          ///
          /// @since 1.0.0
          enable_hive_compatible_s3_prefix = optional(bool, false)
          /// Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries.
          ///
          /// @since 1.0.0
          partition_logs_every_hour        = optional(bool, false)
        }), null)
      })

      /// Additional tags for the flow log
      ///
      /// @since 1.0.0
      additional_tags          = optional(map(string), {})
      /// The fields to include in the flow log record. Accepted format example: `"$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"`. Please refer to [this documentation][vpc-flow-logs-log-record-available-fields] for a list of available fields
      ///
      /// @link {vpc-flow-logs-log-record-available-fields} https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html#flow-logs-fields
      /// @since 1.0.0
      custom_log_record_format = optional(string, null)
      /// The type of traffic to capture.
      ///
      /// @enum ALL|ACCEPT|REJECT
      /// @since 1.0.0
      filter                   = optional(string, "ALL")
    })), {})

    /// Creates a new peering connection or accepting an incoming peering connection.
    ///
    /// @since 1.0.0
    peering_connection = optional(object({
      /// The attachment ID of an incoming peering connection request. Mutually exclusive to `peer_transit_gateway_id`
      ///
      /// @since 1.0.0
      accept_connection_from  = optional(string, null)
      /// The ID of a remote transit gateway to request a new peering connection. Mutually exclusive to `accept_connection_from`
      ///
      /// @since 1.0.0
      peer_transit_gateway_id = optional(string, null)
      /// The account ID of the peer. If unspecified, the account ID of the current provider will be used
      ///
      /// @since 1.0.0
      peer_account_id         = optional(string, null)
      /// The region of the peer. If unspecified, the region of the current provider will be used
      ///
      /// @since 1.0.0
      peer_region             = optional(string, null)
    }), null)

    /// Creates a VPC attachment
    ///
    /// @since 1.0.0
    vpc = optional(object({
      /// Specify the VPC to attach to the transit gateway
      ///
      /// @since 1.0.0
      vpc_id                                    = string
      /// The subnets in which to create the transit gateway VPC attachment. You can only specify one subnet in each availability zone
      ///
      /// @since 1.0.0
      subnet_ids                                = list(string)
      /// Enable Domain Name System resolution for this VPC attachment.
      ///
      /// @since 1.0.0
      enable_dns_support                        = optional(bool, true)
      /// Enable Security Group Referencing for this VPC attachment.
      ///
      /// @since 1.0.0
      enable_security_group_referencing_support = optional(bool, true)
      /// Enable IPv6 for this attachment.
      ///
      /// @since 1.0.0
      enable_ipv6_support                       = optional(bool, false)
      /// When appliance mode is enabled, traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow.
      ///
      /// @since 1.0.0
      enable_appliance_mode_support             = optional(bool, false)
    }), null)

    /// Creates a VPN attachment
    ///
    /// @since 1.0.0
    vpn = optional(object({
      /// Specify the VPN customer gateway
      ///
      /// @since 1.0.0
      customer_gateway_id                     = string
      /// Specify the routing option. Note: `dynamic` requires BGP.
      ///
      /// @enum dynamic|static
      /// @since 1.0.0
      routing_options                         = optional(string, "dynamic")
      /// Choose how the pre-shared key (PSK) is stored and managed.
      ///
      /// - `Standard`: stored in the Site-to-Site VPN service
      /// - `SecretsManager`: stored in AWS Secrets Manager
      ///
      ///
      /// @enum Standard|SecretsManager
      /// @since 1.0.0
      preshared_key_storage                   = optional(string, "Standard")
      /// Enable Acceleration improves performance of VPN tunnels via AWS Global Accelerator and the AWS global network
      ///
      /// @since 1.0.0
      enable_acceleration                     = optional(bool, false)
      /// The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection.
      ///
      /// @since 1.0.0
      local_ipv4_network_cidr                 = optional(string, "0.0.0.0/0")
      /// The IPv4 CIDR on the AWS side of the VPN connection.
      ///
      /// @since 1.0.0
      remote_ipv4_network_cidr                = optional(string, "0.0.0.0/0")
      /// Specifies whether the customer gateway device is using a public or private IPv4 address.
      ///
      /// @enum PublicIpv4|PrivateIpv4
      /// @since 1.0.0
      outside_ip_address_type                 = optional(string, "PublicIpv4")
      /// The transport transit gateway attachment ID for the AWS Direct Connect gateway to be used for the private IP VPN connection. Only applicable if `outside_ip_address_type = "PrivateIpv4"`
      ///
      /// @since 1.0.0
      transport_transit_gateway_attachment_id = optional(string, null)

      /// Configures advanced options for the first VPN tunnel
      ///
      /// @since 1.0.0
      tunnel1_options = optional(object({
        /// The time after which a DPD timeout occurs. Must be `"30 seconds"` or higher
        ///
        /// @since 1.0.0
        dpd_timeout                              = optional(string, "30 seconds")
        /// The action to take after dead peer detection (DPD) timeout occurs.
        ///
        /// - `clear`: the IKE session is stopped, the tunnel goes down, and the routes are removed
        /// - `restart`: restart the IKE initiation
        ///
        /// @enum clear|restart|none
        /// @since 1.0.0
        dpd_timeout_action                       = optional(string, "clear")
        /// Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business.
        ///
        /// @since 1.0.0
        enable_tunnel_endpoint_lifecycle_control = optional(bool, false)
        /// List of internet key exchange (IKE) versions permitted for the VPN tunnel.
        ///
        /// @enum ikev1|ikev2
        /// @since 1.0.0
        ike_version                              = optional(list(string), ["ikev1", "ikev2"])
        /// The CIDR block of the inside IP addresses for the VPN tunnel. Valid value is a size /30 CIDR block from the 169.254.0.0/16 range. One will be generated by AWS if not specified
        ///
        /// @since 1.0.0
        inside_ipv4_cidr                         = optional(string, null)
        /// List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 1 IKE negotiations.
        ///
        /// @enum 2|5|14|15|16|17|18|19|20|21|22|23|24
        /// @since 1.0.0
        phase1_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        /// List of permitted encryption algorithms for the VPN tunnel for phase 1 IKE negotiations.
        ///
        /// @enum AES128|AES256|AES128-GCM-16|AES256-GCM-16
        /// @since 1.0.0
        phase1_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        /// List of permitted integrity algorithms for the VPN tunnel for phase 1 IKE negotiations.
        ///
        /// @enum SHA1|SHA2-256|SHA2-384|SHA2-512
        /// @since 1.0.0
        phase1_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        /// The lifetime for phase 1 of the IKE negotiation. Valid values: `"15 minutes" - "8 hours"`
        ///
        /// @since 1.0.0
        phase1_lifetime                          = optional(string, "8 hours")
        /// List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 2 IKE negotiations.
        ///
        /// @enum 2|5|14|15|16|17|18|19|20|21|22|23|24
        /// @since 1.0.0
        phase2_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        /// List of permitted encryption algorithms for the VPN tunnel for phase 2 IKE negotiations.
        ///
        /// @enum AES128|AES256|AES128-GCM-16|AES256-GCM-16
        /// @since 1.0.0
        phase2_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        /// List of permitted integrity algorithms for the VPN tunnel for phase 2 IKE negotiations.
        ///
        /// @enum SHA1|SHA2-256|SHA2-384|SHA2-512
        /// @since 1.0.0
        phase2_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        /// The lifetime for phase 2 of the IKE negotiation. Valid values: `"15 minutes"` - `"1 hour"` and must be less than `phase1_lifetime`
        ///
        /// @since 1.0.0
        phase2_lifetime                          = optional(string, "1 hour")
        /// The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. One will be generated by AWS if unspecified
        ///
        /// @since 1.0.0
        preshared_key                            = optional(string, null)
        /// The percentage of the rekey window during which the rekey time is randomly selected. Valid values: `0 - 100`
        ///
        /// @since 1.0.0
        rekey_fuzz_percentage                    = optional(number, 100)
        /// The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. `"60 seconds" - phase2_lifetime/2`
        ///
        /// @since 1.0.0
        rekey_margin_time                        = optional(string, "270 seconds")
        /// The number of packets in an IKE replay window. Valid values: `64 - 2048`
        ///
        /// @since 1.0.0
        replay_window_size                       = optional(number, 1024)
        /// The action to take when establishing the VPN tunnel for a new or modified VPN connection. `start` is only supported for customer gateways with IP addresses.
        ///
        /// - `add`: your customer gateway device must initiate the IKE negotiation and bring up the tunnel
        /// - `start`: AWS initiates the IKE negotiation
        ///
        /// @enum add|start
        /// @since 1.0.0
        startup_action                           = optional(string, "add")

        /// Tunnel activity log captures log messages for IPsec activity and DPD protocol messages.
        ///
        /// @since 1.0.0
        enable_tunnel_activity_log = optional(object({
          /// The ARN of the Cloudwatch log group to publish the logs to
          ///
          /// @since 1.0.0
          cloudwatch_log_group_arn = string
          /// The output log's format.
          ///
          /// @enum json|text
          /// @since 1.0.0
          output_format            = optional(string, "json")
        }), null)
      }), null)

      /// Configures advanced options for the second VPN tunnel
      ///
      /// @since 1.0.0
      tunnel2_options = optional(object({
        /// The time after which a DPD timeout occurs. Must be `"30 seconds"` or higher
        ///
        /// @since 1.0.0
        dpd_timeout                              = optional(string, "30 seconds")
        /// The action to take after dead peer detection (DPD) timeout occurs.
        ///
        /// - `clear`: the IKE session is stopped, the tunnel goes down, and the routes are removed
        /// - `restart`: restart the IKE initiation
        ///
        /// @enum clear|restart|none
        /// @since 1.0.0
        dpd_timeout_action                       = optional(string, "clear")
        /// Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business.
        ///
        /// @since 1.0.0
        enable_tunnel_endpoint_lifecycle_control = optional(bool, false)
        /// List of internet key exchange (IKE) versions permitted for the VPN tunnel.
        ///
        /// @enum ikev1|ikev2
        /// @since 1.0.0
        ike_version                              = optional(list(string), ["ikev1", "ikev2"])
        /// The CIDR block of the inside IP addresses for the VPN tunnel. Valid value is a size /30 CIDR block from the 169.254.0.0/16 range. One will be generated by AWS if not specified
        ///
        /// @since 1.0.0
        inside_ipv4_cidr                         = optional(string, null)
        /// List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 1 IKE negotiations.
        ///
        /// @enum 2|5|14|15|16|17|18|19|20|21|22|23|24
        /// @since 1.0.0
        phase1_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        /// List of permitted encryption algorithms for the VPN tunnel for phase 1 IKE negotiations.
        ///
        /// @enum AES128|AES256|AES128-GCM-16|AES256-GCM-16
        /// @since 1.0.0
        phase1_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        /// List of permitted integrity algorithms for the VPN tunnel for phase 1 IKE negotiations.
        ///
        /// @enum SHA1|SHA2-256|SHA2-384|SHA2-512
        /// @since 1.0.0
        phase1_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        /// The lifetime for phase 1 of the IKE negotiation. Valid values: `"15 minutes" - "8 hours"`
        ///
        /// @since 1.0.0
        phase1_lifetime                          = optional(string, "8 hours")
        /// List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 2 IKE negotiations.
        ///
        /// @enum 2|5|14|15|16|17|18|19|20|21|22|23|24
        /// @since 1.0.0
        phase2_dh_group_numbers                  = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        /// List of permitted encryption algorithms for the VPN tunnel for phase 2 IKE negotiations.
        ///
        /// @enum AES128|AES256|AES128-GCM-16|AES256-GCM-16
        /// @since 1.0.0
        phase2_encryption_algorithms             = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
        /// List of permitted integrity algorithms for the VPN tunnel for phase 2 IKE negotiations.
        ///
        /// @enum SHA1|SHA2-256|SHA2-384|SHA2-512
        /// @since 1.0.0
        phase2_integrity_algorithms              = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
        /// The lifetime for phase 2 of the IKE negotiation. Valid values: `"15 minutes"` - `"1 hour"` and must be less than `phase1_lifetime`
        ///
        /// @since 1.0.0
        phase2_lifetime                          = optional(string, "1 hour")
        /// The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. One will be generated by AWS if unspecified
        ///
        /// @since 1.0.0
        preshared_key                            = optional(string, null)
        /// The percentage of the rekey window during which the rekey time is randomly selected. Valid values: `0 - 100`
        ///
        /// @since 1.0.0
        rekey_fuzz_percentage                    = optional(number, 100)
        /// The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. `"60 seconds" - phase2_lifetime/2`
        ///
        /// @since 1.0.0
        rekey_margin_time                        = optional(string, "270 seconds")
        /// The number of packets in an IKE replay window. Valid values: `64` - `2048`
        ///
        /// @since 1.0.0
        replay_window_size                       = optional(number, 1024)
        /// The action to take when establishing the VPN tunnel for a new or modified VPN connection. `"start"` is only supported for customer gateways with IP addresses.
        ///
        /// - `add`: your customer gateway device must initiate the IKE negotiation and bring up the tunnel
        /// - `start`: AWS initiates the IKE negotiation
        ///
        /// @enum add|start
        /// @since 1.0.0
        startup_action                           = optional(string, "add")

        /// Tunnel activity log captures log messages for IPsec activity and DPD protocol messages.
        ///
        /// @since 1.0.0
        enable_tunnel_activity_log = optional(object({
          /// The ARN of the Cloudwatch log group to publish the logs to
          ///
          /// @since 1.0.0
          cloudwatch_log_group_arn = string
          /// The output log's format.
          ///
          /// @enum json|text
          /// @since 1.0.0
          output_format            = optional(string, "json")
        }), null)
      }), null)
    }), null)
  }))
  description = <<EOT
    Manages multiple attachments. For each attachment, must specify one and only one of: `vpc`, `peering_connection`, `vpn`.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = {}
}

variable "description" {
  type        = string
  description = <<EOT
    The description of the transit gateway

    @since 1.0.0
  EOT
  default     = null
}

variable "enable_dns_support" {
  type        = bool
  description = <<EOT
    Enable Domain Name System resolution for VPCs attached to this transit gateway.

    @since 1.0.0
  EOT
  default     = true
}

variable "enable_security_group_referencing_support" {
  type        = bool
  description = <<EOT
    Enable Security Group referencing for VPCs attached to this transit gateway.

    @since 1.0.0
  EOT
  default     = false
}

variable "enable_vpn_ecmp_support" {
  type        = bool
  description = <<EOT
    Enable equal cost multipath (ECMP) routing for VPN Connections that are attached to this transit gateway.

    @since 1.0.0
  EOT
  default     = true
}

variable "enable_default_route_table_association" {
  type        = bool
  description = <<EOT
    Automatically associate transit gateway attachments with this transit gateway's default route table.

    @since 1.0.0
  EOT
  default     = true
}

variable "enable_default_route_table_propagation" {
  type        = bool
  description = <<EOT
    Automatically propagate transit gateway attachments with this transit gateway's default route table.

    @since 1.0.0
  EOT
  default     = true
}

variable "enable_multicast_support" {
  type        = bool
  description = <<EOT
    Enables the ability to create multicast domains in this transit gateway.

    @since 1.0.0
  EOT
  default     = false
}

variable "auto_accept_shared_attachments" {
  type        = bool
  description = <<EOT
    Automatically accept cross-account attachments that are attached to this transit gateway.

    @since 1.0.0
  EOT
  default     = false
}

variable "cidr_blocks" {
  type        = list(string)
  description = <<EOT
    You can associate any public or private IP address range, except for addresses in the 169.254.0.0/16 range, and ranges that overlap with the addresses for your VPC attachments and on-premises networks.

    @since 1.0.0
  EOT
  default     = null
}

variable "flow_logs" {
  type = map(object({
    /// Where the flow log will be sent to. Must specify only one of the following: `cloudwatch_logs`, `s3`
    ///
    /// @since 1.0.0
    destination = object({
      /// Configures CloudWatch Logs as destination
      ///
      /// @since 1.0.0
      cloudwatch_logs = optional(object({
        /// The ARN of the CloudWatch log group to send logs to
        ///
        /// @since 1.0.0
        log_group_arn    = string
        /// Arn of an IAM role that [gives permission to flow logs to send logs to CloudWatch][vpc-flow-logs-cloudwatch-service-role]. A default service role will be created if not specified
        ///
        /// @link {vpc-flow-logs-cloudwatch-service-role} https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-iam-role.html
        /// @since 1.0.0
        service_role_arn = optional(string, null)
      }), null)

      /// Configures S3 as destination
      ///
      /// @since 1.0.0
      s3 = optional(object({
        /// The ARN of the S3 bucket to send logs to
        ///
        /// @since 1.0.0
        bucket_arn                       = string
        /// The format for the flow log.
        ///
        /// @enum plain-text|parquet
        /// @since 1.0.0
        log_file_format                  = optional(string, "plain-text")
        /// Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3
        ///
        /// @since 1.0.0
        enable_hive_compatible_s3_prefix = optional(bool, false)
        /// Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries.
        ///
        /// @since 1.0.0
        partition_logs_every_hour        = optional(bool, false)
      }), null)
    })

    /// Additional tags for the flow log
    ///
    /// @since 1.0.0
    additional_tags          = optional(map(string), {})
    /// The fields to include in the flow log record. Accepted format example: `"$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"`. Please refer to [this documentation][vpc-flow-logs-log-record-available-fields] for a list of available fields
    ///
    /// @link {vpc-flow-logs-log-record-available-fields} https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html#flow-logs-fields
    /// @since 1.0.0
    custom_log_record_format = optional(string, null)
    /// The type of traffic to capture.
    ///
    /// @enum ALL|ACCEPT|REJECT
    /// @since 1.0.0
    filter                   = optional(string, "ALL")
  }))
  description = <<EOT
    Configures multiple Transit gateway level flow logs.

    @since 1.0.0
  EOT
  default     = {}
}

variable "route_tables" {
  type = map(object({
    /// Additional tags for the route table
    ///
    /// @since 1.0.0
    additional_tags         = optional(map(string), {})
    /// Map of routes in the `{ <route_destination> = <attachment_name> }` format
    ///
    /// @since 1.0.0
    routes                  = optional(map(string), {})
    /// List of attachment names this route table is associated to
    ///
    /// @since 1.0.0
    attachment_associations = optional(list(string), [])
    /// List of attachment names to propagate routes to this route table
    ///
    /// @since 1.0.0
    propagations            = optional(list(string), [])
  }))
  description = <<EOT
    Manages multiple route tables.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = {}
}
