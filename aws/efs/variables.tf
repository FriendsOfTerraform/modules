variable "name" {
  type        = string
  description = "The name of the EFS file system. All associated resources' names will also be prefixed by this value"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the EFS instance"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "availability_zone" {
  type        = string
  description = "the AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes."
  default     = null
}

variable "enable_automatic_backup" {
  type        = bool
  description = "Automatically backup your file system data with AWS Backup using recommended settings."
  default     = true
}

variable "encryption" {
  type = object({
    enabled    = bool
    kms_key_id = optional(string)
  })
  description = "Configures encryption at rest."
  default = {
    enabled = true
  }
}

variable "file_system_policy" {
  type        = string
  description = "The JSON formatted file system policy for the EFS file system"
  default     = null
}

variable "lifecycle_policy" {
  type = object({
    transition_to_infrequent_access     = optional(string)
    transition_to_primary_storage_class = optional(string)
  })
  description = "Configures lifecycle policy."
  default     = null
}

variable "mount_targets" {
  type = map(object({
    security_group_ids = list(string)
    ip_address         = optional(string)
  }))
  description = "Configures mount targets"
  default     = {}
}

variable "performance_mode" {
  type        = string
  description = "Performance mode for the file system. Valid values: generalPurpose, maxIO. maxIO only applicable to provisioned, and bursting"
  default     = "generalPurpose"
}

variable "provisioned_throughput" {
  type        = number
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with throughput_mode set to provisioned"
  default     = null
}

variable "replications" {
  type = map(object({
    availability_zone = optional(string)
    kms_key_id        = optional(string)
  }))
  description = "Configures replications"
  default     = {}
}

variable "throughput_mode" {
  type        = string
  description = "Throughput mode for the file system. Valid values: bursting, provisioned, or elastic"
  default     = "elastic"
}
