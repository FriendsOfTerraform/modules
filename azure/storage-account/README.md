# Storage Account Module

This module will create and configure an [Azure Storage Account][azure-storage-account] and manages additional storage such as blob and file shares.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Blob Storage](#blob-storage)
    - [File Share](#file-share)
    - [Firewall](#firewall)
    - [Lifecycle Policy](#lifecycle-policy)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Known Issues](#known-issues)
    - [Naming On Lifecycle Policy Rules](#spaces-in-lifecycle-policy-rule-name-throws-invalid-value-error)
## Example Usage

### Blob Storage

This example creates a storage account name `petersinblobdemo` and then a blob container named `test` for storage

```terraform
module "blob" {
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v0.0.1"

  azure               = { resource_group_name = "sandbox" }
  name                = "petersinblobdemo"

  additional_tags = {
    created-by = "Peter Sin"
  }

  blob_service_config = {
    access_tier       = "Hot"
    enable_versioning = true

    soft_delete_for_blobs = {
      enabled          = true
      retention_period = 6
    }
  }

  security_config = {
    enable_storage_account_key_access = true
  }

  containers = {
    test = {}
  }
}
```

### File Share

This example creates a storage account named `petersinfiledemo` and then a file share named `test` for storage

```terraform
module "file_share" {
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v0.0.1"

  azure               = { resource_group_name = "sandbox" }
  name                = "petersinfiledemo"

  additional_tags = {
    created-by = "Peter Sin"
  }

  security_config = {
    enable_storage_account_key_access = true
  }

  file_service_config = {
    soft_delete = {
      enabled          = true
      retention_period = 30
    }
  }

  file_shares = {
    test = {
      quota       = 5120 # 5TB
      access_tier = "Hot"
      protocol    = "SMB"
    }
  }
}
```

### Firewall

```terraform
module "blob" {
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v0.0.1"

  azure               = { resource_group_name = "sandbox" }
  name                = "petersinblobdemo"

  additional_tags = {
    created-by = "Peter Sin"
  }

  firewall = {
    allow_public_ips = [
      "20.10.0.0/16",
      "99.12.123.123"
    ]

    exceptions = ["AzureServices"]
  }

  security_config = {
    enable_storage_account_key_access = true
  }
}
```

### Lifecycle Policy

This example creates a lifecycle policy name `test` and scope the rule to only the "test" container and blobs with the tags `{hello = "world, foo = "bar"}`

```terraform
module "blob" {
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v0.0.1"

  azure = { resource_group_name = "sandbox" }
  name  = "petersinblobdemo"

  additional_tags = {
    created-by = "Peter Sin"
  }

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

  security_config = {
    enable_storage_account_key_access = true
  }

  containers = {
    test = {}
  }
}
```

## Argument Reference

### Mandatory

- (object) **`azure`** _[since v0.0.1]_

    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    - (string) **`resource_group_name`** _[since v0.0.1]_

        The name of an Azure resource group where the cluster will be deployed

    - (string) **`location = null`** _[since v0.0.1]_

        The name of an Azure location where the cluster will be deployed. If unspecified, the resource group's location will be used.

- (string) **`name`** _[since v0.0.1]_

    The name of the storage account, must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.

### Optional

- (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

    Additional tags for the storage account

- (map(string)) **`additional_tags_all = {}`** _[since v0.0.1]_

    Additional tags for all resources deployed with this module

- (object) **`blob_service_config = null`** _[since v0.0.1]_

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

    - (string) **`access_tier = "Hot"`** _[since v0.0.1]_

        Defines the access tier for Blob storage. Valid values are `"Hot" and "Cold"`.

    - (bool) **`allow_cross_tenant_replication = true`** _[since v0.0.1]_

        When object replication is enabled, blobs are copied asynchronously from a source storage account to a destination account

    - (bool) **`enable_change_feed = false`** _[since v0.0.1]_

        When enabled, keep track of create, modification, and delete changes to blobs in your account. Please refer to [this document][blob-change-feed] for more information.

    - (bool) **`enable_hierarchical_namespace = false`** _[since v0.0.1]_

        Enables hierarchical namespace support for the blob storage. Please refer to [this document][hierarchical-namespace] for more information.

    - (bool) **`enable_network_file_system_v3 = false`** _[since v0.0.1]_

        Enables the NFSv3 protocol. This options can only be enabled if `enable_hierarchical_namespace = true`

    - (bool) **`enable_versioning = false`** _[since v0.0.1]_

        Enables versioning to automatically maintain previous versions of your blobs for recovery and restoration

    - (object) **`soft_delete_for_blobs = null`** _[since v0.0.1]_

        Enables you to recover blobs that were previously marked for deletion, including blobs that were overwritten

        - (bool) **`enabled`** _[since v0.0.1]_

            Enables soft delete for blobs

        - (number) **`retention_period = 7`** _[since v0.0.1]_

            Set the number of days that a blob marked for deletion persists until it's permanently deleted

    - (object) **`soft_delete_for_containers = null`** _[since v0.0.1]_

        Enables you to recover containers that were previously marked for deletion

        - (bool) **`enabled`** _[since v0.0.1]_

            Enables soft delete for containers

        - (number) **`retention_period = 7`** _[since v0.0.1]_

            Set the number of days that a container marked for deletion persists until it's permanently deleted

- (map(object)) **`containers = {}`** _[since v0.0.1]_

    Creates and manages multiple containers for blob storage. In `container_name = {configuration}` format. This option is only available if `storage_account_type = "Storagev2" or "BlockBlobStorage"`

    ```terraform
    containers = {
      test = { public_access_level = "private" }
    }
    ```

    - (string) **`public_access_level = "private"`** _[since v0.0.1]_

        The access level granted to anonymous principals for this container. Valid values are `"blob", "container", or "private"`

    - (map(string)) **`metadata = {}`** _[since v0.0.1]_

        A mapping of metadata for this container

- (map(object)) **`file_shares = {}`** _[since v0.0.1]_

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

    - (number) **`quota"`** _[since v0.0.1]_

        The maximum size of the share, in gigabytes. Must be between `1` and `5120` if `storage_account_type = "StorageV2"`. And between `100` and `102400` if `storage_account_type = "FileStorage"`

    - (string) **`access_tier = "Hot"`** _[since v0.0.1]_

        Defines the access tier of the file share. Valid values are `"Hot", "Cold" and "TransactionOptimized"`

    - (map(string)) **`metadata = {}`** _[since v0.0.1]_

        A mapping of metadata for this file share

    - (string) **`protocol = "SMB"`** _[since v0.0.1]_

        The protocol for this file share. Valid values are `"SMB" and "NFS"`. `"NFS"` is only available if `storage_account_type = "FileStorage"`

- (object) **`file_service_config = null`** _[since v0.0.1]_

    Cofigures file storage settings for this storage account. This option is only available if `storage_account_type = "Storagev2" or "FileStorage"`

    ```terraform
    file_service_config = {
      soft_delete = {
        enabled          = true
        retention_period = 30
      }
    }
    ```

    - (bool) **`enable_large_file_share = false"`** _[since v0.0.1]_

        Provides file share support up to a maximum of 100 TiB. Large file share storage accounts do not have the ability to convert to geo-redundant storage offerings and upgrade is permanent.

    - (object) **`soft_delete = null`** _[since v0.0.1]_

        Enables you to recover a freshly deleted share

        - (bool) **`enabled`** _[since v0.0.1]_

            Enables soft delete

        - (number) **`retention_period = 7`** _[since v0.0.1]_

            Defines the number of days that soft deleted data is available for recovery. You can retain soft deleted data for between `1 and 365 days`

- (object) **`firewall = null`** _[since v0.0.1]_

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

    - (list(string)) **`allow_public_ips = []"`** _[since v0.0.1]_

        Allows list of `public IPs` or `CIDRs` to connect to the storage account

    - (list(string)) **`allow_vnet_subnets = []"`** _[since v0.0.1]_

        Allows list of virtual network subnets `IDs` to connect to the storage account

    - (list(string)) **`exceptions = []"`** _[since v0.0.1]_

        Defines exceptions to traffic for Logging/Metrics/AzureServices. Valid options are any combination of `"Logging", "Metrics", and "AzureServices"`

- (map(object)) **`lifecycle_policies = {}`** _[since v0.0.1]_

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
    - (list(string)) **`blob_types = ["blockBlob"]"`** _[since v0.0.1]_

        A list of blob types this rule applies to, valid values are `"blockBlob" and "appendBlob"`. Defaults to `["blockBlob"]`

    - (map(string)) **`blob_index_tags_match = {}"`** _[since v0.0.1]_

        A map of index tags on the blobs to be matched for this rule to take effect

    - (list(string)) **`prefix_match = []"`** _[since v0.0.1]_

        A list of prefixes to be matched for this rule to take effect. Must be in the `"container_name/blob_name"` format.

    - (object) **`base_blob = null"`** _[since v0.0.1]_

        Set lifecycle rules for base blob objects

        - (number) **`delete_after_days_since_last_access = null"`** _[since v0.0.1]_
  
          The age in days after last access time to delete the blob. Mutally exclusive to `delete_after_days_since_last_modification`.

        - (number) **`delete_after_days_since_last_modification = null"`** _[since v0.0.1]_
  
          The age in days after last modification to delete the blob. Mutally exclusive to `delete_after_days_since_last_access`.

        - (number) **`move_to_archive_storage_after_days_since_last_access = null"`** _[since v0.0.1]_
  
          The age in days after last access time to move the blob to archive storage. Mutally exclusive to `move_to_archive_storage_after_days_since_last_modification`.

        - (number) **`move_to_archive_storage_after_days_since_last_modification = null"`** _[since v0.0.1]_
  
          The age in days after last modification to move the blob to archive storage. Mutally exclusive to `move_to_archive_storage_after_days_since_last_access`.

        - (number) **`move_to_cool_storage_after_days_since_last_access = null"`** _[since v0.0.1]_
  
          The age in days after last access time to move the blob to cool storage. Mutally exclusive to `move_to_cool_storage_after_days_since_last_modification`.

        - (number) **`move_to_cool_storage_after_days_since_last_modification = null"`** _[since v0.0.1]_
  
          The age in days after last modification to move the blob to cool storage. Mutally exclusive to `move_to_cool_storage_after_days_since_last_access`.

    - (object) **`snapshot = null"`** _[since v0.0.1]_

        Set lifecycle rules for snapshot blob objects

        - (number) **`delete_after_days = null"`** _[since v0.0.1]_
  
          The age in days after creation to delete the snapshot.

        - (number) **`move_to_archive_storage_after_days = null"`** _[since v0.0.1]_
  
          The age in days after creation to move the snapshot to archive storage.

        - (number) **`move_to_cool_storage_after_days = null"`** _[since v0.0.1]_
  
          The age in days after creation to move the snapshot to cool storage.

    - (object) **`version = null"`** _[since v0.0.1]_

        Set lifecycle rules for versioned blob objects

        - (number) **`delete_after_days = null"`** _[since v0.0.1]_
  
          The age in days after creation to delete the versioned object.

        - (number) **`move_to_archive_storage_after_days = null"`** _[since v0.0.1]_
  
          The age in days after creation to move the versioned object to archive storage.

        - (number) **`move_to_cool_storage_after_days = null"`** _[since v0.0.1]_
  
          The age in days after creation to move the versioned object to cool storage.  

- (string) **`redundancy = "LRS"`** _[since v0.0.1]_

    Defines the type of replication to use for this storage account. Valid values are:

    - "LRS" (Locally-redundant storage)
    - "GRS" (Geo-redundant storage)
    - "RAGRS" (Read-access Geo-redundant storage)
    - "ZRS" (Zone-redundant storage)
    - "GZRS" (Geo Zone-redundant storage)
    - "RAGZRS" (Read-access Geo Zone-redundant storage)

- (object) **`security_config = null`** _[since v0.0.1]_

    Configures security related settings for this storage account

    ```terraform
    security_config = {
      enable_storage_account_key_access = true
    }
    ```

    - (bool) **`enable_storage_account_key_access = false"`** _[since v0.0.1]_

        Whether storage account key is used in this storage account

- (string) **`storage_account_type = "StorageV2"`** _[since v0.0.1]_

    Defines the type of storage account offering to use. Valid values are `"StorageV2", "BlockBlobStorage", and "FileStorage"`

## Known Issues

### Spaces in Lifecycle Policy Rule name throws "invalid value" error

```
"invalid value for rule.1.name (A rule name can contain any combination of alpha numeric characters.)"
```

For modules using any version <3.19.0 of `terraform-provider-azurerm`, a bug exists where spaces cannot be used in rule names even though Azure itself allows it. This is a bug in the provider ([hashicorp/terraform-provider-azurerm#17969][issue-17969]) and has been fixed in version 3.19.0+ of the provider.

[azure-storage-account]:https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
[blob-change-feed]:https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-change-feed?tabs=azure-portal
[hierarchical-namespace]:https://docs.microsoft.com/en-us/azure/storage/blobs/upgrade-to-data-lake-storage-gen2-how-to?tabs=azure-portal
[issue-17969]:https://github.com/hashicorp/terraform-provider-azurerm/issues/17969
