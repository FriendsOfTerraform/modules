variable "ami_id" {
  type        = string
  description = <<EOT
    Specify the ID of the AMI used to launch the instance

    @since 1.0.0
  EOT
}

variable "ebs_volume" {
  type = object({
    /// The size of the EBS volume, in GiB
    ///
    /// @since 1.0.0
    size = number

    /// Specify the [volume type][volume-type]
    ///
    /// @enum standard|gp2|gp3|io1|io2|sc1|st1
    /// @link {volume-type} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html
    /// @since 1.0.0
    volume_type = string

    /// Additional tags for the EBS volume
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Whether the volume should be destroyed on instance termination
    ///
    /// @since 1.0.0
    delete_on_termination = optional(bool, true)

    /// ARN of the KMS Key to use to encrypt the volume
    ///
    /// @since 1.0.0
    kms_key_id = optional(string)

    /// Specify the amount of provisioned IOPS. Only valid for volume_type of
    /// `"io1"`, `"io2"` or `"gp3"`.
    ///
    /// @since 1.0.0
    provisioned_iops = optional(number)

    /// Throughput to provision for a volume in mebibytes per second (MiB/s).
    /// This is only valid for volume_type of `"gp3"`
    ///
    /// @since 1.0.0
    throughput = optional(number)
  })
  description = <<EOT
    Configures the root EBS volume

    @since 1.0.0
  EOT
}

variable "key_pair_name" {
  type        = string
  description = <<EOT
    Specify the name of the [Key Pair][ec2-key-pair] to use for the instance

    @link {ec2-key-pair} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
    @since 1.0.0
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the EC2 instance. All associated resources will also have their
    name prefixed with this value

    @since 1.0.0
  EOT
}

variable "network_interface" {
  type = object({
    /// List of security group IDs attached to this ENI
    ///
    /// @since 1.0.0
    security_group_ids = list(string)

    /// Specify the subnet ID this ENI is created on
    ///
    /// @since 1.0.0
    subnet_id = string

    /// Additional tags for the ENI
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Specify the description of the ENI
    ///
    /// @since 1.0.0
    description = optional(string)

    /// Enables [elastic fabric adapter][elastic-fabric-adapter]
    ///
    /// @link {elastic-fabric-adapter} https://aws.amazon.com/hpc/efa/
    /// @since 1.0.0
    enable_elastic_fabric_adapter = optional(bool, false)

    /// Controls if traffic is routed to the instance when the destination
    /// address does not match the instance. Used for NAT or VPNs
    ///
    /// @since 1.0.0
    enable_source_destination_checking = optional(bool, true)

    /// Configures custom private IP addresses for the ENI.
    ///
    /// @since 1.0.0
    private_ip_addresses = optional(object({
      /// List of private IPv4 addresses to assign to the ENI, the first address
      /// will be used as the primary IP address
      ///
      /// @since 1.0.0
      ipv4 = optional(list(string))
    }))

    /// Assigns a private CIDR range, either automatically or manually, to the
    /// ENI. By assigning [prefixes][ec2-prefixes], you scale and simplify the
    /// management of applications, including container and networking
    /// applications that require multiple IP addresses on an instance. Network
    /// interfaces with prefixes are supported with [instances built on the
    /// Nitro System][nitro-system-type].
    ///
    /// @link {ec2-prefixes} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-prefix-eni.html
    /// @link {nitro-system-type} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#ec2-nitro-instances
    /// @since 1.0.0
    prefix_delegation = optional(object({
      /// Configures prefix delegation for IPv4
      ///
      /// @since 1.0.0
      ipv4 = optional(object({
        /// Specify the number of prefixes AWS chooses from your VPC subnet's
        /// IPv4 CIDR block and assigns it to your network interface. Mutually
        /// exclusive to `custom_prefixes`
        ///
        /// @since 1.0.0
        auto_assign_count = optional(number)

        /// Specify the prefixes from your VPC subnet's CIDR block to assign it
        /// to your network interface. Mutually exclusive to `auto_assign_count`
        ///
        /// @since 1.0.0
        custom_prefixes = optional(list(string))
      }))
    }))
  })
  description = <<EOT
    Configures the primary network interface

    @since 1.0.0
  EOT
}

variable "additional_ebs_volumes" {
  type = map(object({
    /// Specify the name of the device this EBS volume is mounted to. Please
    /// refer to the following documentations for valid values.
    /// [Windows][device-name-windows], [Linux][device-name-linux]
    ///
    /// @link {device-name-windows} https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/device_naming.html?icmpid=docs_ec2_console#available-ec2-device-names
    /// @link {device-name-linux} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
    /// @since 1.0.0
    device_name = string

    /// The size of the EBS volume, in GiB
    ///
    /// @since 1.0.0
    size = number

    /// Specify the [volume type][volume-type].
    ///
    /// @enum standard|gp2|gp3|io1|io2|sc1|st1
    /// @link {volume-type} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html
    /// @since 1.0.0
    volume_type = string

    /// Additional tags for the EBS volume
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Whether the volume should be destroyed on instance termination
    ///
    /// @since 1.0.0
    delete_on_termination = optional(bool, true)

    /// Whether a final snapshot should be taken when the volume is being
    /// destroyed
    ///
    /// @since 1.0.0
    final_snapshot = optional(bool)

    /// ARN of the KMS Key to use to encrypt the volume
    ///
    /// @since 1.0.0
    kms_key_id = optional(string)

    /// Specify the amount of provisioned IOPS. Only valid for volume_type of
    /// `"io1"`, `"io2"` or `"gp3"`.
    ///
    /// @since 1.0.0
    provisioned_iops = optional(number)

    /// Specify the snapshot ID this volume is created from
    ///
    /// @since 1.0.0
    snapshot_id = optional(string)

    /// Throughput to provision for a volume in mebibytes per second (MiB/s).
    /// This is only valid for volume_type of `"gp3"`
    ///
    /// @since 1.0.0
    throughput = optional(number)
  }))
  description = <<EOT
    Configures additional EBS volumes attached to this instance.

    @example "Additional Storage And Network Interfaces" #additional-storage-and-network-interfaces
    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_network_interfaces" {
  type = map(object({
    /// Specify the device index this ENI mounted on
    ///
    /// @since 1.0.0
    device_index = number

    /// List of security group IDs attached to this ENI
    ///
    /// @since 1.0.0
    security_group_ids = list(string)

    /// Specify the subnet ID this ENI is created on
    ///
    /// @since 1.0.0
    subnet_id = string

    /// Additional tags for the ENI
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Specify the description of the ENI
    ///
    /// @since 1.0.0
    description = optional(string)

    /// Enables [elastic fabric adapter][elastic-fabric-adapter]
    ///
    /// @link {elastic-fabric-adapter} https://aws.amazon.com/hpc/efa/
    /// @since 1.0.0
    enable_elastic_fabric_adapter = optional(bool, false)

    /// Controls if traffic is routed to the instance when the destination
    /// address does not match the instance. Used for NAT or VPNs
    ///
    /// @since 1.0.0
    enable_source_destination_checking = optional(bool, true)

    /// Configures custom private IP addresses for the ENI.
    ///
    /// @since 1.0.0
    private_ip_addresses = optional(object({
      /// List of private IPv4 addresses to assign to the ENI, the first address
      /// will be used as the primary IP address
      ///
      /// @since 1.0.0
      ipv4 = optional(list(string))
    }))

    /// Assigns a private CIDR range, either automatically or manually, to the
    /// ENI. By assigning [prefixes][ec2-prefixes], you scale and simplify the
    /// management of applications, including container and networking
    /// applications that require multiple IP addresses on an instance. Network
    /// interfaces with prefixes are supported with [instances built on the
    /// Nitro System][nitro-system-type].
    ///
    /// @link {ec2-prefixes} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-prefix-eni.html
    /// @link {nitro-system-type} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#ec2-nitro-instances
    /// @since 1.0.0
    prefix_delegation = optional(object({
      /// Configures prefix delegation for IPv4
      ///
      /// @since 1.0.0
      ipv4 = optional(object({
        /// Specify the number of prefixes AWS chooses from your VPC subnet's
        /// IPv4 CIDR block and assigns it to your network interface. Mutually
        /// exclusive to `custom_prefixes`
        ///
        /// @since 1.0.0
        auto_assign_count = optional(number)

        /// Specify the prefixes from your VPC subnet's CIDR block to assign it
        /// to your network interface. Mutually exclusive to `auto_assign_count`
        ///
        /// @since 1.0.0
        custom_prefixes = optional(list(string))
      }))
    }))
  }))
  description = <<EOT
    Configures additional ENIs attached to this instance.

    @example "Additional Storage And Network Interfaces" #additional-storage-and-network-interfaces
    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the EC2 instance

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

variable "cpu_credit_specification" {
  type        = string
  description = <<EOT
    Credit option for CPU usage. Only applicable to the T family.

    @link "Standard Credit Mode" https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-standard-mode.html
    @link "Unlimited Credit Mode" https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-unlimited-mode.html
    @enum standard|unlimited
    @since 1.0.0
  EOT
  default     = "standard"
}

variable "enable_auto_recovery" {
  type        = bool
  description = <<EOT
    Enables [EC2 auto recovery][ec2-auto-recovery]

    @link {ec2-auto-recovery} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html
    @since 1.0.0
  EOT
  default     = true
}

variable "enable_detailed_monitoring" {
  type        = bool
  description = <<EOT
    Enables [detailed monitoring][ec2-detailed-monitoring]

    @link {ec2-detailed-monitoring} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html
    @since 1.0.0
  EOT
  default     = false
}

variable "enable_instance_hibernation" {
  type        = bool
  description = <<EOT
    Enables [instance hibernation][instance-hibernation]. Changing this option
    after the instance launched will result in replacement.

    @link {instance-hibernation} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enabling-hibernation.html
    @since 1.0.0
  EOT
  default     = false
}

variable "enable_instance_termination_protection" {
  type        = bool
  description = <<EOT
    Enables [instance termination protection][instance-termination-protection]

    @link {instance-termination-protection} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminate-instances-considerations.html#Using_ChangingDisableAPITermination
    @since 1.0.0
  EOT
  default     = false
}

variable "enable_instance_stop_protection" {
  type        = bool
  description = <<EOT
    Enables [instance stop protection][instance-stop-protection]

    @link {instance-stop-protection} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html#Using_StopProtection
    @since 1.0.0
  EOT
  default     = false
}

variable "get_windows_password" {
  type        = bool
  description = <<EOT
    Retrieves the encrypted administrator password for a running Windows
    instance. The values will be exported to the `password_data` output

    @since 1.0.0
  EOT
  default     = false
}

variable "iam_role_name" {
  type        = string
  description = <<EOT
    The name of the IAM role to attach to the instance.

    @link "EC2 IAM Roles" https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
    @since 1.0.0
  EOT
  default     = null
}

variable "instance_metadata_options" {
  type = object({
    /// Whether the instance metadata service is turned on
    ///
    /// @since 1.0.0
    enable_instance_metadata_service = optional(bool, true)

    /// Requires the use of IMDSv2 when requesting instance metadata
    ///
    /// @since 1.0.0
    requires_imdsv2 = optional(bool, true)

    /// Whether instance tags are retrievable from instance metadata
    ///
    /// @since 1.0.0
    allow_tags_in_instance_metadata = optional(bool, false)
  })
  description = <<EOT
    Configures the [metadata options][instance-metadata-service] of the instance.

    @link {instance-metadata-service} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html
    @since 1.0.0
  EOT
  default     = null
}

variable "instance_type" {
  type        = string
  description = <<EOT
    Specify the [instance type][ec2-instance-type] of instance

    @link {ec2-instance-type} https://aws.amazon.com/ec2/instance-types/
    @since 1.0.0
  EOT
  default     = "t2.micro"
}

variable "resource_based_naming_options" {
  type = object({
    /// Whether the `"EC2 instance ID"` is included in the hostname of the
    /// instance. For example: `i-0123456789abcdef.ec2.internal` If false, the
    /// `"private IPv4 address"` of the instance is included in the hostname
    /// instead. For example: `ip-10-24-34-0.ec2.internal`
    ///
    /// @since 1.0.0
    use_resource_based_naming_as_os_hostname = optional(bool, false)

    /// Whether requests to your resource name resolve to the private IPv4
    /// address (A record) of this EC2 instance
    ///
    /// @since 1.0.0
    answer_dns_hostname_ipv4_request = optional(bool, false)
  })
  description = <<EOT
    Configures the [resource based naming options][resource-based-naming-options]
    of the instance.

    @link {resource-based-naming-options} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-naming.html
    @since 1.0.0
  EOT
  default     = null
}

variable "user_data_config" {
  type = object({
    /// User data document in clear text. Mutually exclusive to `user_data_base64`
    ///
    /// @since 1.0.0
    user_data = optional(string)

    /// User data document in base64. Mutually exclusive to `user_data`
    ///
    /// @since 1.0.0
    user_data_base64 = optional(string)
  })
  description = <<EOT
    Configures the [user data][ec2-user-data] of the instance.

    @link {ec2-user-data} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
    @since 1.0.0
  EOT
  default     = null
}
