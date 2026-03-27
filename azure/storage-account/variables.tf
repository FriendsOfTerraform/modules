variable "azure" {
  type = object({
    /// The name of an Azure resource group where the cluster will be deployed
    ///
    /// @since 0.0.1
    resource_group_name = string
    /// The name of an Azure location where the cluster will be deployed. If unspecified, the resource group's location will be used.
    ///
    /// @since 0.0.1
    location = optional(string)
  })

  description = <<EOT
    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    @since 0.0.1
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the storage account, must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.

    @since 0.0.1
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the storage account

    @since 0.0.1
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 0.0.1
  EOT
  default     = {}
}

variable "blob_service_config" {
  type = object({
    /// Defines the access tier for Blob storage.
    ///
    /// @enum Hot|Cold
    /// @since 0.0.1
    access_tier = optional(string, "Hot")
    /// When object replication is enabled, blobs are copied asynchronously from a source storage account to a destination account
    ///
    /// @since 0.0.1
    allow_cross_tenant_replication = optional(bool, true)
    /// When enabled, keep track of create, modification, and delete changes to blobs in your account. Please refer to [this document][blob-change-feed] for more information.
    ///
    /// @link {blob-change-feed} https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-change-feed?tabs=azure-portal
    /// @since 0.0.1
    enable_change_feed = optional(bool, false)
    /// Enables hierarchical namespace support for the blob storage. Please refer to [this document][hierarchical-namespace] for more information.
    ///
    /// @link {hierarchical-namespace} https://docs.microsoft.com/en-us/azure/storage/blobs/upgrade-to-data-lake-storage-gen2-how-to?tabs=azure-portal
    /// @since 0.0.1
    enable_hierarchical_namespace = optional(bool, false)
    /// Enables the NFSv3 protocol. This options can only be enabled if `enable_hierarchical_namespace = true`
    ///
    /// @since 0.0.1
    enable_network_file_system_v3 = optional(bool, false)
    /// Enables versioning to automatically maintain previous versions of your blobs for recovery and restoration
    ///
    /// @since 0.0.1
    enable_versioning = optional(bool, false)

    /// Enables you to recover blobs that were previously marked for deletion, including blobs that were overwritten
    ///
    /// @since 0.0.1
    soft_delete_for_blobs = optional(object({
      /// Enables soft delete for blobs
      ///
      /// @since 0.0.1
      enabled = bool
      /// Set the number of days that a blob marked for deletion persists until it's permanently deleted
      ///
      /// @since 0.0.1
      retention_period = optional(number, 7)
    }))

    /// Enables you to recover containers that were previously marked for deletion
    ///
    /// @since 0.0.1
    soft_delete_for_containers = optional(object({
      /// Enables soft delete for containers
      ///
      /// @since 0.0.1
      enabled = bool
      /// Set the number of days that a container marked for deletion persists until it's permanently deleted
      ///
      /// @since 0.0.1
      retention_period = optional(number, 7)
    }))
  })

  description = <<EOT
    Configures blob storage settings for this storage account. This option is only available if `storage_account_type = "Storagev2" or "BlockBlobStorage"`

    ```terraform
    blob_service_config = {
      access_tier       = "Hot"
      enable_versioning = true

      soft_delete_for_blobs = {
        enabled          = true
        retention_period = 6
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "containers" {
  type = map(object({
    /// The access level granted to anonymous principals for this container.
    ///
    /// @enum blob|container|private
    /// @since 0.0.1
    public_access_level = optional(string, "private")
    /// A mapping of metadata for this container
    ///
    /// @since 0.0.1
    metadata = optional(map(string))
  }))

  description = <<EOT
    Creates and manages multiple containers for blob storage. In `container_name = {configuration}` format. This option is only available if `storage_account_type = "Storagev2" or "BlockBlobStorage"`

    ```terraform
    containers = {
      test = { public_access_level = "private" }
    }
    ```

    @since 0.0.1
  EOT
  default     = {}
}

variable "file_shares" {
  type = map(object({
    /// The maximum size of the share, in gigabytes. Must be between `1` and `5120` if `storage_account_type = "StorageV2"`. And between `100` and `102400` if `storage_account_type = "FileStorage"`
    ///
    /// @since 0.0.1
    quota = number
    /// Defines the access tier of the file share.
    ///
    /// @enum Hot|Cold|TransactionOptimized
    /// @since 0.0.1
    access_tier = optional(string, "Hot")
    /// A mapping of metadata for this file share
    ///
    /// @since 0.0.1
    metadata = optional(map(string))
    /// The protocol for this file share. `"NFS"` is only available if `storage_account_type = "FileStorage"`
    ///
    /// @enum SMB|NFS
    /// @since 0.0.1
    protocol = optional(string, "SMB")
  }))

  description = <<EOT
    Creates and manages multiple file shares. In `share_name = {configuration}` format. This option is only available if `storage_account_type = "Storagev2" or "FileStorage"`

    ```terraform
    file_shares = {
      test = {
        quota       = 5120 # 5TB
        access_tier = "Hot"
        protocol    = "SMB"
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = {}
}

variable "file_service_config" {
  type = object({
    /// Provides file share support up to a maximum of 100 TiB. Large file share storage accounts do not have the ability to convert to geo-redundant storage offerings and upgrade is permanent.
    ///
    /// @since 0.0.1
    enable_large_file_share = optional(bool, false)

    /// Enables you to recover a freshly deleted share
    ///
    /// @since 0.0.1
    soft_delete = optional(object({
      /// Enables soft delete
      ///
      /// @since 0.0.1
      enabled = bool
      /// Defines the number of days that soft deleted data is available for recovery. You can retain soft deleted data for between `1 and 365 days`
      ///
      /// @since 0.0.1
      retention_period = optional(number, 7)
    }))
  })

  description = <<EOT
    Configures file storage settings for this storage account. This option is only available if `storage_account_type = "Storagev2" or "FileStorage"`

    ```terraform
    file_service_config = {
      soft_delete = {
        enabled          = true
        retention_period = 30
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "firewall" {
  type = object({
    /// Allows list of `public IPs` or `CIDRs` to connect to the storage account
    ///
    /// @since 0.0.1
    allow_public_ips = optional(list(string), [])
    /// Allows list of virtual network subnets `IDs` to connect to the storage account
    ///
    /// @since 0.0.1
    allow_vnet_subnets = optional(list(string), [])
    /// Defines exceptions to traffic for Logging/Metrics/AzureServices. Valid options are any combination of the enum values.
    ///
    /// @enum Logging|Metrics|AzureServices
    /// @since 0.0.1
    exceptions = optional(list(string), [])
  })

  description = <<EOT
    Manages network rules to allow access into the storage account

    ```terraform
    firewall = {
      allow_public_ips = [
        "20.10.0.0/16",
        "99.12.123.123"
      ]

      exceptions = ["AzureServices"]
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "lifecycle_policies" {
  type = map(object({
    /// A list of blob types this rule applies to. Defaults to `["blockBlob"]`
    ///
    /// @enum blockBlob|appendBlob
    /// @since 0.0.1
    blob_types = optional(list(string), ["blockBlob"])
    /// A list of prefixes to be matched for this rule to take effect. Must be in the `"container_name/blob_name"` format.
    ///
    /// @since 0.0.1
    prefix_match = optional(list(string))
    /// A map of index tags on the blobs to be matched for this rule to take effect
    ///
    /// @since 0.0.1
    blob_index_tags_match = optional(map(string), {})

    /// Set lifecycle rules for base blob objects
    ///
    /// @since 0.0.1
    base_blob = optional(object({
      /// The age in days after last access time to delete the blob. Mutually exclusive to `delete_after_days_since_last_modification`.
      ///
      /// @since 0.0.1
      delete_after_days_since_last_access = optional(number)
      /// The age in days after last access time to move the blob to archive storage. Mutually exclusive to `move_to_archive_storage_after_days_since_last_modification`.
      ///
      /// @since 0.0.1
      move_to_archive_storage_after_days_since_last_access = optional(number)
      /// The age in days after last access time to move the blob to cool storage. Mutually exclusive to `move_to_cool_storage_after_days_since_last_modification`.
      ///
      /// @since 0.0.1
      move_to_cool_storage_after_days_since_last_access = optional(number)
      /// The age in days after last modification to delete the blob. Mutually exclusive to `delete_after_days_since_last_access`.
      ///
      /// @since 0.0.1
      delete_after_days_since_last_modification = optional(number)
      /// The age in days after last modification to move the blob to archive storage. Mutually exclusive to `move_to_archive_storage_after_days_since_last_access`.
      ///
      /// @since 0.0.1
      move_to_archive_storage_after_days_since_last_modification = optional(number)
      /// The age in days after last modification to move the blob to cool storage. Mutually exclusive to `move_to_cool_storage_after_days_since_last_access`.
      ///
      /// @since 0.0.1
      move_to_cool_storage_after_days_since_last_modification = optional(number)
    }))

    /// Set lifecycle rules for snapshot blob objects
    ///
    /// @since 0.0.1
    snapshot = optional(object({
      /// The age in days after creation to delete the snapshot.
      ///
      /// @since 0.0.1
      delete_after_days = optional(number)
      /// The age in days after creation to move the snapshot to archive storage.
      ///
      /// @since 0.0.1
      move_to_archive_storage_after_days = optional(number)
      /// The age in days after creation to move the snapshot to cool storage.
      ///
      /// @since 0.0.1
      move_to_cool_storage_after_days = optional(number)
    }))

    /// Set lifecycle rules for versioned blob objects
    ///
    /// @since 0.0.1
    version = optional(object({
      /// The age in days after creation to delete the versioned object.
      ///
      /// @since 0.0.1
      delete_after_days = optional(number)
      /// The age in days after creation to move the versioned object to archive storage.
      ///
      /// @since 0.0.1
      move_to_archive_storage_after_days = optional(number)
      /// The age in days after creation to move the versioned object to cool storage.
      ///
      /// @since 0.0.1
      move_to_cool_storage_after_days = optional(number)
    }))
  }))

  description = <<EOT
    Defines and manages multiple lifecycle policies

    ```terraform
    lifecycle_policies = {
      test = {
        prefix_match = ["test"]

        blob_index_tags_match = {
          hello = "world"
          foo = "bar"
        }

        base_blob = {
          move_to_archive_storage_after_days_since_last_modification = 45
          delete_after_days_since_last_modification                  = 90
        }
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = {}
}

variable "redundancy" {
  type        = string
  description = <<EOT
    Defines the type of replication to use for this storage account. Valid values are:

    - "LRS" (Locally-redundant storage)
    - "GRS" (Geo-redundant storage)
    - "RAGRS" (Read-access Geo-redundant storage)
    - "ZRS" (Zone-redundant storage)
    - "GZRS" (Geo Zone-redundant storage)
    - "RAGZRS" (Read-access Geo Zone-redundant storage)

    @enum LRS|GRS|RAGRS|ZRS|GZRS|RAGZRS
    @since 0.0.1
  EOT
  default     = "LRS"
}

variable "security_config" {
  type = object({
    /// Whether storage account key is used in this storage account
    ///
    /// @since 0.0.1
    enable_storage_account_key_access = optional(bool, false)
  })

  description = <<EOT
    Configures security related settings for this storage account

    ```terraform
    security_config = {
      enable_storage_account_key_access = true
    }
    ```

    @since 0.0.1
  EOT

  default = null
}

variable "storage_account_type" {
  type        = string
  description = <<EOT
    Defines the type of storage account offering to use.

    @enum StorageV2|BlockBlobStorage|FileStorage
    @since 0.0.1
  EOT
  default     = "StorageV2"
}
