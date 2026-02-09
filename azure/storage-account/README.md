# Storage Account Module

This module will create and configure an [Azure Storage Account][azure-storage-account] and manages additional storage such as blob and file shares.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Blob Storage](#blob-storage)
  - [File Share](#file-share)
  - [Firewall](#firewall)
  - [Lifecycle Policy](#lifecycle-policy)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)
- [Known Issues](#known-issues)
  - [Naming On Lifecycle Policy Rules](#spaces-in-lifecycle-policy-rule-name-throws-invalid-value-error)

## Example Usage

### Blob Storage

This example creates a storage account name `petersinblobdemo` and then a blob container named `test` for storage

```terraform
module "blob" {
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v1.0.0"

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
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v1.0.0"

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
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v1.0.0"

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
  source = "github.com/FriendsOfTerraform/azure-storage-account.git?ref=v1.0.0"

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

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#azure">Azure</a>)</code></td>
    <td width="100%">azure</td>
    <td></td>
</tr>
<tr><td colspan="3">

The resource group name and the location where the resources will be deployed to

```terraform
azure = {
resource_group_name = "sandbox"
location = "westus"
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the storage account, must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.

**Since:** 0.0.1

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the storage account

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#blobserviceconfig">BlobServiceConfig</a>)</code></td>
    <td width="100%">blob_service_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

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

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#containers">Containers</a>))</code></td>
    <td width="100%">containers</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Creates and manages multiple containers for blob storage. In `container_name = {configuration}` format. This option is only available if `storage_account_type = "Storagev2" or "BlockBlobStorage"`

```terraform
containers = {
test = { public_access_level = "private" }
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#fileserviceconfig">FileServiceConfig</a>)</code></td>
    <td width="100%">file_service_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures file storage settings for this storage account. This option is only available if `storage_account_type = "Storagev2" or "FileStorage"`

```terraform
file_service_config = {
soft_delete = {
enabled          = true
retention_period = 30
}
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#fileshares">FileShares</a>))</code></td>
    <td width="100%">file_shares</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

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

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#firewall">Firewall</a>)</code></td>
    <td width="100%">firewall</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

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

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#lifecyclepolicies">LifecyclePolicies</a>))</code></td>
    <td width="100%">lifecycle_policies</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

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

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">redundancy</td>
    <td><code>"LRS"</code></td>
</tr>
<tr><td colspan="3">

Defines the type of replication to use for this storage account. Valid values are:

- "LRS" (Locally-redundant storage)
- "GRS" (Geo-redundant storage)
- "RAGRS" (Read-access Geo-redundant storage)
- "ZRS" (Zone-redundant storage)
- "GZRS" (Geo Zone-redundant storage)
- "RAGZRS" (Read-access Geo Zone-redundant storage)

**Allowed Values:**

- `LRS`
- `GRS`
- `RAGRS`
- `ZRS`
- `GZRS`
- `RAGZRS`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#securityconfig">SecurityConfig</a>)</code></td>
    <td width="100%">security_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures security related settings for this storage account

```terraform
security_config = {
enable_storage_account_key_access = true
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">storage_account_type</td>
    <td><code>"StorageV2"</code></td>
</tr>
<tr><td colspan="3">

Defines the type of storage account offering to use.

**Allowed Values:**

- `StorageV2`
- `BlockBlobStorage`
- `FileStorage`

**Since:** 0.0.1

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">container_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

A map of IDs of the container

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">file_share_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

A map of IDS of the file share

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">storage_account_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the storage account

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Objects

#### Azure

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure resource group where the cluster will be deployed

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure location where the cluster will be deployed. If unspecified, the resource group's location will be used.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### BaseBlob

Set lifecycle rules for base blob objects

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">delete_after_days_since_last_access</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after last access time to delete the blob. Mutually exclusive to `delete_after_days_since_last_modification`.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_archive_storage_after_days_since_last_access</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after last access time to move the blob to archive storage. Mutually exclusive to `move_to_archive_storage_after_days_since_last_modification`.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_cool_storage_after_days_since_last_access</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after last access time to move the blob to cool storage. Mutually exclusive to `move_to_cool_storage_after_days_since_last_modification`.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">delete_after_days_since_last_modification</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after last modification to delete the blob. Mutually exclusive to `delete_after_days_since_last_access`.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_archive_storage_after_days_since_last_modification</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after last modification to move the blob to archive storage. Mutually exclusive to `move_to_archive_storage_after_days_since_last_access`.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_cool_storage_after_days_since_last_modification</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after last modification to move the blob to cool storage. Mutually exclusive to `move_to_cool_storage_after_days_since_last_access`.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### BlobServiceConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_tier</td>
    <td><code>"Hot"</code></td>
</tr>
<tr><td colspan="3">

Defines the access tier for Blob storage.

**Allowed Values:**

- `Hot`
- `Cold`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">allow_cross_tenant_replication</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

When object replication is enabled, blobs are copied asynchronously from a source storage account to a destination account

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_change_feed</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

When enabled, keep track of create, modification, and delete changes to blobs in your account. Please refer to [this document][blob-change-feed] for more information.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_hierarchical_namespace</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables hierarchical namespace support for the blob storage. Please refer to [this document][hierarchical-namespace] for more information.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_network_file_system_v3</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables the NFSv3 protocol. This options can only be enabled if `enable_hierarchical_namespace = true`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_versioning</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables versioning to automatically maintain previous versions of your blobs for recovery and restoration

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#softdeleteforblobs">SoftDeleteForBlobs</a>)</code></td>
    <td width="100%">soft_delete_for_blobs</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables you to recover blobs that were previously marked for deletion, including blobs that were overwritten

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#softdeleteforcontainers">SoftDeleteForContainers</a>)</code></td>
    <td width="100%">soft_delete_for_containers</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables you to recover containers that were previously marked for deletion

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### Containers

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">public_access_level</td>
    <td><code>"private"</code></td>
</tr>
<tr><td colspan="3">

The access level granted to anonymous principals for this container.

**Allowed Values:**

- `blob`
- `container`
- `private`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">metadata</td>
    <td></td>
</tr>
<tr><td colspan="3">

A mapping of metadata for this container

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### FileServiceConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_large_file_share</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Provides file share support up to a maximum of 100 TiB. Large file share storage accounts do not have the ability to convert to geo-redundant storage offerings and upgrade is permanent.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#softdelete">SoftDelete</a>)</code></td>
    <td width="100%">soft_delete</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables you to recover a freshly deleted share

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### FileShares

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">quota</td>
    <td></td>
</tr>
<tr><td colspan="3">

The maximum size of the share, in gigabytes. Must be between `1` and `5120` if `storage_account_type = "StorageV2"`. And between `100` and `102400` if `storage_account_type = "FileStorage"`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">access_tier</td>
    <td><code>"Hot"</code></td>
</tr>
<tr><td colspan="3">

Defines the access tier of the file share.

**Allowed Values:**

- `Hot`
- `Cold`
- `TransactionOptimized`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">metadata</td>
    <td></td>
</tr>
<tr><td colspan="3">

A mapping of metadata for this file share

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">protocol</td>
    <td><code>"SMB"</code></td>
</tr>
<tr><td colspan="3">

The protocol for this file share. `"NFS"` is only available if `storage_account_type = "FileStorage"`

**Allowed Values:**

- `SMB`
- `NFS`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### Firewall

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">allow_public_ips</td>
    <td></td>
</tr>
<tr><td colspan="3">

Allows list of `public IPs` or `CIDRs` to connect to the storage account

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">allow_vnet_subnets</td>
    <td></td>
</tr>
<tr><td colspan="3">

Allows list of virtual network subnets `IDs` to connect to the storage account

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">exceptions</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines exceptions to traffic for Logging/Metrics/AzureServices. Valid options are any combination of the enum values.

**Allowed Values:**

- `Logging`
- `Metrics`
- `AzureServices`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### LifecyclePolicies

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">blob_types</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of blob types this rule applies to. Defaults to `["blockBlob"]`

**Allowed Values:**

- `blockBlob`
- `appendBlob`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">prefix_match</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of prefixes to be matched for this rule to take effect. Must be in the `"container_name/blob_name"` format.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">blob_index_tags_match</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

A map of index tags on the blobs to be matched for this rule to take effect

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#baseblob">BaseBlob</a>)</code></td>
    <td width="100%">base_blob</td>
    <td></td>
</tr>
<tr><td colspan="3">

Set lifecycle rules for base blob objects

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#snapshot">Snapshot</a>)</code></td>
    <td width="100%">snapshot</td>
    <td></td>
</tr>
<tr><td colspan="3">

Set lifecycle rules for snapshot blob objects

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#version">Version</a>)</code></td>
    <td width="100%">version</td>
    <td></td>
</tr>
<tr><td colspan="3">

Set lifecycle rules for versioned blob objects

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### SecurityConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_storage_account_key_access</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether storage account key is used in this storage account

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### Snapshot

Set lifecycle rules for snapshot blob objects

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">delete_after_days</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after creation to delete the snapshot.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_archive_storage_after_days</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after creation to move the snapshot to archive storage.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_cool_storage_after_days</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after creation to move the snapshot to cool storage.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### SoftDelete

Enables you to recover a freshly deleted share

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables soft delete

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">retention_period</td>
    <td><code>7</code></td>
</tr>
<tr><td colspan="3">

Defines the number of days that soft deleted data is available for recovery. You can retain soft deleted data for between `1 and 365 days`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### SoftDeleteForBlobs

Enables you to recover blobs that were previously marked for deletion, including blobs that were overwritten

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables soft delete for blobs

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">retention_period</td>
    <td><code>7</code></td>
</tr>
<tr><td colspan="3">

Set the number of days that a blob marked for deletion persists until it's permanently deleted

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### SoftDeleteForContainers

Enables you to recover containers that were previously marked for deletion

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables soft delete for containers

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">retention_period</td>
    <td><code>7</code></td>
</tr>
<tr><td colspan="3">

Set the number of days that a container marked for deletion persists until it's permanently deleted

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### Version

Set lifecycle rules for versioned blob objects

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">delete_after_days</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after creation to delete the versioned object.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_archive_storage_after_days</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after creation to move the versioned object to archive storage.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">move_to_cool_storage_after_days</td>
    <td></td>
</tr>
<tr><td colspan="3">

The age in days after creation to move the versioned object to cool storage.

**Since:** 0.0.1

</td></tr>
</tbody></table>

[blob-change-feed]: https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-change-feed?tabs=azure-portal
[hierarchical-namespace]: https://docs.microsoft.com/en-us/azure/storage/blobs/upgrade-to-data-lake-storage-gen2-how-to?tabs=azure-portal

<!-- TFDOCS_EXTRAS_END -->

## Known Issues

### Spaces in Lifecycle Policy Rule name throws "invalid value" error

```
"invalid value for rule.1.name (A rule name can contain any combination of alpha numeric characters.)"
```

For modules using any version <3.19.0 of `terraform-provider-azurerm`, a bug exists where spaces cannot be used in rule names even though Azure itself allows it. This is a bug in the provider ([hashicorp/terraform-provider-azurerm#17969][issue-17969]) and has been fixed in version 3.19.0+ of the provider.

[azure-storage-account]: https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
[issue-17969]: https://github.com/hashicorp/terraform-provider-azurerm/issues/17969
