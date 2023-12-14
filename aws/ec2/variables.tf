variable "ami_id" {
  type        = string
  description = "Specify the ID of the AMI used to launch the instance"
}

variable "ebs_volume" {
  type = object({
    size                  = number
    volume_type           = string
    additional_tags       = optional(map(string), {})
    delete_on_termination = optional(bool, true)
    kms_key_id            = optional(string)
    provisioned_iops      = optional(number)
    throughput            = optional(number)
  })
  description = "Configures the root EBS volume"
}

variable "key_pair_name" {
  type        = string
  description = "Specify the name of the Key Pair to use for the instance"
}

variable "name" {
  type        = string
  description = "The name of the EC2 instance. All associated resources' names will also be prefixed by this value"
}

variable "network_interface" {
  type = object({
    security_group_ids                 = list(string)
    subnet_id                          = string
    additional_tags                    = optional(map(string), {})
    description                        = optional(string)
    enable_elastic_fabric_adapter      = optional(bool, false)
    enable_source_destination_checking = optional(bool, true)

    private_ip_addresses = optional(object({
      ipv4 = optional(list(string))
    }))

    prefix_delegation = optional(object({
      ipv4 = optional(object({
        auto_assign_count = optional(number)
        custom_prefixes   = optional(list(string))
      }))
    }))
  })
  description = "Configures the primary network interface"
}

variable "additional_ebs_volumes" {
  type = map(object({
    device_name           = string
    size                  = number
    volume_type           = string
    additional_tags       = optional(map(string), {})
    delete_on_termination = optional(bool, true)
    final_snapshot        = optional(bool)
    kms_key_id            = optional(string)
    provisioned_iops      = optional(number)
    snapshot_id           = optional(string)
    throughput            = optional(number)
  }))
  description = "Configures additional EBS volumes attached to this instance."
  default     = {}
}

variable "additional_network_interfaces" {
  type = map(object({
    device_index                       = number
    security_group_ids                 = list(string)
    subnet_id                          = string
    additional_tags                    = optional(map(string), {})
    description                        = optional(string)
    enable_elastic_fabric_adapter      = optional(bool, false)
    enable_source_destination_checking = optional(bool, true)

    private_ip_addresses = optional(object({
      ipv4 = optional(list(string))
    }))

    prefix_delegation = optional(object({
      ipv4 = optional(object({
        auto_assign_count = optional(number)
        custom_prefixes   = optional(list(string))
      }))
    }))
  }))
  description = "Configures additional ENIs attached to this instance"
  default     = {}
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the EC2 instance"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "cpu_credit_specification" {
  type        = string
  description = "Credit option for CPU usage. Only applicable to T family. Valid values include standard or unlimited"
  default     = "standard"
}

variable "enable_auto_recovery" {
  type        = bool
  description = "Enables EC2 auto recovery."
  default     = true
}

variable "enable_detailed_monitoring" {
  type        = bool
  description = "Enables detailed monitoring."
  default     = false
}

variable "enable_instance_hibernation" {
  type        = bool
  description = "Enables instance hibernation."
  default     = false
}

variable "enable_instance_termination_protection" {
  type        = bool
  description = "Enables EC2 Instance Termination Protection."
  default     = false
}

variable "enable_instance_stop_protection" {
  type        = bool
  description = "Enables EC2 Instance Stop Protection"
  default     = false
}

variable "get_windows_password" {
  type        = bool
  description = "Retrieves the encrypted administrator password for a running Windows instance."
  default     = false
}

variable "iam_role_name" {
  type        = string
  description = "The name of the IAM role to attach to the instance."
  default     = null
}

variable "instance_metadata_options" {
  type = object({
    enable_instance_metadata_service = optional(bool, true)
    requires_imdsv2                  = optional(bool, true)
    allow_tags_in_instance_metadata  = optional(bool, false)
  })
  description = "Configures the metadata options  of the instance"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "Specify the instance type of instance"
  default     = "t2.micro"
}

variable "resource_based_naming_options" {
  type = object({
    use_resource_based_naming_as_os_hostname = optional(bool, false)
    answer_dns_hostname_ipv4_request         = optional(bool, false)
  })
  description = "Configures the resource based naming options of the instance"
  default     = null
}

variable "user_data_config" {
  type = object({
    user_data        = optional(string)
    user_data_base64 = optional(string)
  })
  description = "Configures the user data of the instance"
  default     = null
}
