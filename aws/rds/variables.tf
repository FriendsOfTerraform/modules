############
## Mandatory
############

variable "authentication_config" {
  type = object({
    db_master_account = object({
      username                           = string
      customer_kms_key_id                = optional(string)
      manage_password_in_secrets_manager = optional(bool)
      password                           = optional(string)
    })

    iam_database_authentication_enabled = optional(bool)
  })
  description = "Configures RDS authentication options"
}

variable "engine" {
  type = object({
    type    = string
    version = string
  })
  description = "Specify database engine options."
}

variable "instance_class" {
  type        = string
  description = "The instance type of the RDS instance."
}

variable "name" {
  type        = string
  description = "Specify the name of the RDS instance or RDS Cluster"
}

variable "networking_config" {
  type = object({
    db_subnet_group_name = string
    security_group_ids   = list(string)
    availability_zone    = optional(string)
    ca_cert_identifier   = optional(string)
    enable_ipv6          = optional(bool, false)
    enable_public_access = optional(bool, false)
    port                 = optional(number)
  })
  description = "Configures RDS networking"
}

############
## Optional
############

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the kubernetes cluster"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "aurora_global_cluster" {
  type = object({
    join_existing_global_cluster = optional(string)
    name                         = optional(string)
  })
  description = "value"
  default     = null
}

variable "aurora_mysql_config" {
  type = object({
    enable_backtrack = optional(object({
      target_backtrack_window = number
    }))
    enable_write_forwarding = optional(bool)
  })
  description = "Setting specific to aurora mysql compatible cluster"
  default     = null
}

variable "cloudwatch_log_exports" {
  type        = list(string)
  description = "Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported"
  default     = null
}

variable "cluster_instances" {
  type = map(object({
    additional_tags    = optional(map(string), {})
    db_parameter_group = optional(string)
    failover_priority  = optional(number)
    instance_class     = optional(string)

    networking_config = optional(object({
      availability_zone    = optional(string)
      enable_public_access = optional(bool)
    }))
  }))
  description = "Manages multiple cluster instances for aurora cluster"
  default     = {}
}

variable "db_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created in the DB instance."
  default     = null
}

variable "db_cluster_parameter_group" {
  type        = string
  description = "Specify the name of the DB parameter group to be attached to the instance"
  default     = null
}

variable "db_parameter_group" {
  type        = string
  description = "Specify the name of the DB parameter group to be attached to the instance"
  default     = null
}

variable "delete_protection_enabled" {
  type        = bool
  description = "If the DB instance should have deletion protection enabled."
  default     = false
}

variable "deployment_option" {
  type        = string
  description = "Specify the deployment option for non aurora deployment"
  default     = "SingleInstance"
}

variable "enable_automated_backup" {
  type = object({
    retention_period      = number
    copy_tags_to_snapshot = optional(bool, true)
    window                = optional(string)
  })
  description = "Configures RDS backup options"
  default     = null
}

variable "enable_encryption" {
  type = object({
    kms_key_id = string
  })
  description = "Enable RDS encryption"
  default     = null
}

variable "maintenance_config" {
  type = object({
    window                            = string
    enable_auto_minor_version_upgrade = optional(bool, true)
  })
  description = "Configures RDS monitoring options"
  default     = null
}

variable "monitoring_config" {
  type = object({
    enable_enhanced_monitoring = optional(object({
      iam_role_arn = string
      interval     = number
    }))

    enable_performance_insight = optional(object({
      retention_period = number
      kms_key_id       = optional(string)
    }))
  })
  description = "Configures RDS monitoring options"
  default     = null
}

variable "option_group" {
  type        = string
  description = "Specify the name of the option group to be attached to the instance"
  default     = null
}

variable "serverless_capacity" {
  type = object({
    min_acus = number
    max_acus = optional(number)
  })
  description = "Specify the capacity range of the serverless instance"
  default     = null
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  default     = false
}

variable "storage_config" {
  type = object({
    allocated_storage     = optional(number)
    max_allocated_storage = optional(number)
    provisioned_iops      = optional(number)
    storage_throughput    = optional(number)
    type                  = optional(string)
  })
  description = "Configures RDS storage"
  default     = null
}
