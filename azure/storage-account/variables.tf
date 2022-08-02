variable "azure" {
  type = object({
    resource_group_name = string
    location            = optional(string)
  })

  description = "Where the resources will be deployed on"
}

variable "name" {
  type        = string
  description = "The name of the storage account name. Must be globally unique"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the storage account"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "blob_service_config" {
  type = object({
    access_tier                    = optional(string)
    allow_cross_tenant_replication = optional(bool)
    enable_change_feed             = optional(bool)
    enable_hierarchical_namespace  = optional(bool)
    enable_network_file_system_v3  = optional(bool)
    enable_versioning              = optional(bool)

    soft_delete_for_blobs = optional(object({
      enabled          = bool
      retention_period = optional(number)
    }))

    soft_delete_for_containers = optional(object({
      enabled          = bool
      retention_period = optional(number)
    }))
  })

  description = "Configures blob storage settings for this storage account"

  default = {
    access_tier                    = "Hot"
    allow_cross_tenant_replication = true
    enable_change_feed             = false
    enable_hierarchical_namespace  = false
    enable_network_file_system_v3  = false
    enable_versioning              = false
  }
}

variable "containers" {
  type = map(object({
    public_access_level = optional(string)
    metadata            = optional(map(string))
  }))

  description = "Create and manage multiple containers"
  default     = {}
}

variable "file_shares" {
  type = map(object({
    quota       = number
    access_tier = optional(string)
    metadata    = optional(map(string))
    protocol    = optional(string)
  }))

  description = "Create and manage multiple file shares"
  default     = {}
}

variable "file_service_config" {
  type = object({
    enable_large_file_share = optional(bool)

    soft_delete = optional(object({
      enabled          = bool
      retention_period = optional(number)
    }))
  })

  description = "Configures file storage settings for this storage account"

  default = {
    enable_large_file_share = false
  }
}

variable "firewall" {
  type = object({
    allow_public_ips   = optional(list(string))
    allow_vnet_subnets = optional(list(string))
    exceptions         = optional(list(string))
  })

  description = "Rules to restrict access to the storage account"
  default     = null
}

variable "lifecycle_policies" {
  type = map(object({
    blob_types            = optional(list(string))
    prefix_match          = optional(list(string))
    blob_index_tags_match = optional(map(string))

    base_blob = optional(object({
      delete_after_days_since_last_access                        = optional(number)
      move_to_archive_storage_after_days_since_last_access       = optional(number)
      move_to_cool_storage_after_days_since_last_access          = optional(number)
      delete_after_days_since_last_modification                  = optional(number)
      move_to_archive_storage_after_days_since_last_modification = optional(number)
      move_to_cool_storage_after_days_since_last_modification    = optional(number)
    }))

    snapshot = optional(object({
      delete_after_days                  = optional(number)
      move_to_archive_storage_after_days = optional(number)
      move_to_cool_storage_after_days    = optional(number)
    }))

    version = optional(object({
      delete_after_days                  = optional(number)
      move_to_archive_storage_after_days = optional(number)
      move_to_cool_storage_after_days    = optional(number)
    }))
  }))

  description = "Defines and manages multiple lifecycle policies"
  default     = {}
}

variable "redundancy" {
  type        = string
  description = "Defines the type of replication to use for this storage account"
  default     = "LRS"
}

variable "security_config" {
  type = object({
    enable_storage_account_key_access = optional(bool)
  })

  description = "Configures security settings that impact this storage account"

  default = {
    enable_storage_account_key_access = false
  }
}

variable "storage_account_type" {
  type        = string
  description = "Defines the type of the storage account offering to use"
  default     = "StorageV2"
}
