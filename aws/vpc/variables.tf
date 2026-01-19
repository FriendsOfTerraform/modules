variable "cidr_block" {
  type = object({
    /// Configures the IPv4 CIDR block
    /// 
    /// @since 1.0.0
    ipv4 = object({
      /// Manually input an IPv4 CIDR. The CIDR block size must have a size between /16 and /28. Mutually exclusive to `ipam`
      /// 
      /// @since 1.0.0
      cidr = optional(string, null)
      /// Specify an [Amazon VPC IP Address Manager (IPAM)][vpc-ipam] pool to obtain an IPv4 CIDR automatically. If you select an IPAM pool, the size of the CIDR is limited by the allocation rules on the IPAM pool (allowed minimum, allowed maximum, and default). Mutally exclusive to `cidr`
      /// 
      /// @since 1.0.0
      ipam = optional(object({
        /// The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR
        /// 
        /// @since 1.0.0
        pool_id = string
        /// The netmask length of the IPv4 CIDR you want to allocate to this VPC
        /// 
        /// @since 1.0.0
        netmask = string
      }), null)
    })
  })
  description = <<EOT
    Configures the VPC CIDR block
    
    @since 1.0.0
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the VPC. All associated resources will also have their name prefixed with this value
    
    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the VPC
    
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

variable "create_nat_gateways" {
  type        = bool
  description = <<EOT
    If enabled, one NAT gateway will be created on the first public subnets in each availability zone. You can then refer to them on the route table with `default-nat-gateway/<availability_zone_name>`. Please see [example](#basic-usage)
    
    @since 1.0.0
  EOT
  default     = false
}

variable "dhcp_options" {
  type = object({
    /// If you're using `AmazonProvidedDNS` in `us-east-1`, specify `ec2.internal`. If you're using `AmazonProvidedDNS` in another region, specify `region.compute.internal` (for example, `ap-northeast-1.compute.internal`). Otherwise, specify a domain name (for example, example.com). This value is used to complete unqualified DNS hostnames.
    /// 
    /// @since 1.0.0
    domain_name          = optional(string, null)
    /// The IP addresses of up to four domain name servers, or AmazonProvidedDNS. Although you can specify up to four domain name servers, note that some operating systems may impose lower limits. If you want your instance to receive a custom DNS hostname as specified in domain-name, you must set domain-name-servers to a custom DNS server.
    /// 
    /// @since 1.0.0
    domain_name_servers  = optional(list(string), ["AmazonProvidedDNS"])
    /// The IP addresses of up to four NTP servers
    /// 
    /// @since 1.0.0
    ntp_servers          = optional(list(string), null)
    /// The IP addresses of up to four NetBIOS name servers
    /// 
    /// @since 1.0.0
    netbios_name_servers = optional(list(string), null)
    /// The NetBIOS node type (`1`, `2`, `4`, or `8`). AWS recommends to specify `2` since broadcast and multicast are not supported in their network.
    /// 
    /// @since 1.0.0
    netbios_node_type    = optional(number, null)
    /// Additional tags for the option set
    /// 
    /// @since 1.0.0
    additional_tags      = optional(map(string), {})
  })
  description = <<EOT
    DHCP option
    
    @since 1.0.0
  EOT
  default     = null
}

variable "dns_settings" {
  type = object({
    /// Whether DNS resolution through the Amazon DNS server is supported for the VPC
    /// 
    /// @since 1.0.0
    enable_dns_resolution = optional(bool, true)
    /// Whether instances launched in the VPC receive public DNS hostnames that correspond to their public IP addresses
    /// 
    /// @since 1.0.0
    enable_dns_hostnames  = optional(bool, false)
  })
  description = <<EOT
    Configures DNS settings for the VPC
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "enable_network_address_usage_metrics" {
  type        = bool
  description = <<EOT
    [Network Address Usage (NAU)][vpc-network-address-usage] is a metric applied to resources in your virtual network to help you plan for and monitor the size of your VPC
    
    @since 1.0.0
  EOT
  default     = false
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
        /// The format for the flow log. Valid values: `"plain-text"`, `"parquet"`
        /// 
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
    additional_tags              = optional(map(string), {})
    /// The fields to include in the flow log record. Accepted format example: `"$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"`. Please refer to [this documentation][vpc-flow-logs-log-record-available-fields] for a list of available fields
    /// 
    /// @since 1.0.0
    custom_log_record_format     = optional(string, null)
    /// The type of traffic to capture. Valid values: `"ALL"`, `"ACCEPT"`, `"REJECT"`
    /// 
    /// @since 1.0.0
    filter                       = optional(string, "ALL")
    /// The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60 `seconds (1 minute) or `600` seconds (10 minutes).
    /// 
    /// @since 1.0.0
    maximum_aggregation_interval = optional(number, 600)
  }))
  description = <<EOT
    Configures multiple VPC level flow logs. Please see [example](#flow-logs)
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "peering_connection_requests" {
  type = map(object({
    /// The ID of the target VPC with which you are creating the VPC Peering Connection
    /// 
    /// @since 1.0.0
    peer_vpc_id                     = string
    /// Additional tags for the peering connection request
    /// 
    /// @since 1.0.0
    additional_tags                 = optional(map(string), {})
    /// Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC. To use DNS resolution over peering you must enable DNS Hostname on both the requester's and accepter's VPC
    /// 
    /// @since 1.0.0
    allow_remote_vpc_dns_resolution = optional(bool, false)
    /// The AWS account ID of the target peer VPC. Defaults to the current account if unspecified.
    /// 
    /// @since 1.0.0
    peer_account_id                 = optional(string, null)
    /// The region of the accepter VPC of the VPC Peering Connection. Defaults to the current region if unspecified.
    /// 
    /// @since 1.0.0
    peer_region                     = optional(string, null)
  }))
  description = <<EOT
    Map of peering connection requests. The key of the map is the peering connection request's name
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "route_tables" {
  type = map(object({
    /// Additional tags for the route table
    /// 
    /// @since 1.0.0
    additional_tags     = optional(map(string), {})
    /// Weather this is the main route table. You may only set one route table as the main route table
    /// 
    /// @since 1.1.0
    main_route_table    = optional(bool, false)
    /// Map of routes in the `{ <route_destination> = <route_target> }` format
    /// 
    /// @since 1.0.0
    routes              = optional(map(string), {})
    /// List of subnet names this route table is associated to
    /// 
    /// @since 1.0.0
    subnet_associations = optional(list(string), [])
  }))
  description = <<EOT
    Map of route tables. The key of the map is the route table's name
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "subnets" {
  type = map(object({
    /// Availability zone of the subnet
    /// 
    /// @since 1.0.0
    availability_zone                      = string
    /// The IPv4 CIDR block for the subnet
    /// 
    /// @since 1.0.0
    ipv4_cidr_block                        = string
    /// Additional tags for the subnet
    /// 
    /// @since 1.0.0
    additional_tags                        = optional(map(string), {})
    /// If true, instances launched into the subnet should be assigned a public IP address. The subnet will also be considered a public subnet and an internet gateway will be created for the VPC.
    /// 
    /// @since 1.0.0
    enable_auto_assign_public_ipv4_address = optional(bool, false)

    /// Configures multiple subnet level flow logs. Please see [example](#flow-logs)
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
          /// The format for the flow log. Valid values: `"plain-text"`, `"parquet"`
          /// 
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
      additional_tags              = optional(map(string), {})
      /// The fields to include in the flow log record. Accepted format example: `"$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"`. Please refer to [this documentation][vpc-flow-logs-log-record-available-fields] for a list of available fields
      /// 
      /// @since 1.0.0
      custom_log_record_format     = optional(string, null)
      /// The type of traffic to capture. Valid values: `"ALL"`, `"ACCEPT"`, `"REJECT"`
      /// 
      /// @since 1.0.0
      filter                       = optional(string, "ALL")
      /// The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60 `seconds (1 minute) or `600` seconds (10 minutes).
      /// 
      /// @since 1.0.0
      maximum_aggregation_interval = optional(number, 600)
    })), {})

    /// Specify the hostname type for EC2 instances in this subnet and optional RBN DNS query settings
    /// 
    /// @since 1.0.0
    resource_based_name_settings = optional(object({
      /// Choose if DNS A record queries for the resource-based name should return the IPv4 address or not
      /// 
      /// @since 1.0.0
      enable_resource_name_dns_a_record_on_launch = optional(bool, false)
      /// Determines if the guest OS hostname of EC2 instances in this subnet should be based on the resource name (RBN) or the IP name (IPBN). Valid values: `"ip-name"`, `"resource-name"`. If you choose `"resource-name"`, when you launch an EC2 instance in this subnet, the guest OS hostname of the EC2 instance will be configured to use the EC2 instance ID: `ec2-instance-id.region.compute.internal`. If you choose `"ip-name"`, when you launch an EC2 instance in this subnet, the guest OS hostname of the EC2 instance will be configured to use an IP-based name: `private-ipv4-address.region.compute.internal`
      /// 
      /// @since 1.0.0
      hostname_type                               = optional(string, "ip-name")
    }), {})
  }))
  description = <<EOT
    Map of subnets. The key of the map is the subnet's name
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "tenancy" {
  type        = string
  description = <<EOT
    Specify the VPC's tenancy. Valid values: `"default"`, `"dedicated"`
    
    @since 1.0.0
  EOT
  default     = "default"
}
