# Elastic File System Module

This module will build and configure an [EFS](https://aws.amazon.com/efs/) file system

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
  - [Access Points](#access-points)
  - [Replications](#replications)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
  - [Objects](#objects)
- [Outputs](#outputs)
- [Known Limitations](#known-limitations)
  - [Lifecycle Policy Transition To Archive](#lifecycle-policy-transition-to-archive)

## Example Usage

### Basic Usage

```terraform
module "demo_efs" {
  source = "github.com/FriendsOfTerraform/aws-efs.git?ref=v1.0.0"

  name = "demo-efs"

  # Configures multiple mount targets
  mount_targets = {
    # The key of the map is the subnet ID to create the mount target on
    "subnet-02cd47a492abcdef0" = { security_group_ids = ["sg-00ce17020babcdef0"] } # us-east-1a
    "subnet-0f44f4247babcdef0" = { security_group_ids = ["sg-00ce17020babcdef0"] } # us-east-1b
  }
}
```

### Access Points

```terraform
module "demo_efs" {
  source = "github.com/FriendsOfTerraform/aws-efs.git?ref=v1.0.0"

  name = "demo-efs"

  # You must have at least 1 mount target to create access points
  # Configures multiple mount targets
  mount_targets = {
    # The key of the map is the subnet ID to create the mount target on
    "subnet-02cd47a492abcdef0" = { security_group_ids = ["sg-00ce17020babcdef0"] } # us-east-1a
    "subnet-0f44f4247babcdef0" = { security_group_ids = ["sg-00ce17020babcdef0"] } # us-east-1b
  }

  # Configures multiple access points
  access_points = {
    # The key of the map will be the name of the access point
    "web-frontend" = {
      posix_user = {
        group_id = 10001
        user_id  = 10001
      }

      root_directory_creation_permissions = {
        owner_group_id           = 10001
        owner_user_id            = 10001
        access_point_permissions = "0774"
      }

      root_directory_path = "/web"
    }

    "database" = {
      posix_user = {
        group_id = 10002
        user_id  = 10002
      }

      root_directory_creation_permissions = {
        owner_group_id           = 10002
        owner_user_id            = 10002
        access_point_permissions = "0770"
      }

      root_directory_path = "/sql"
    }

    "scratch" = {
      root_directory_path = "/scratch"
    }
  }
}
```

### Replications

```terraform
module "demo_efs" {
  source = "github.com/FriendsOfTerraform/aws-efs.git?ref=v1.0.0"

  name = "demo-efs"

  # Configures multiple mount targets
  mount_targets = {
    # The key of the map is the subnet ID to create the mount target on
    "subnet-02cd47a492abcdef0" = { security_group_ids = ["sg-00ce17020babcdef0"] } # us-east-1a
    "subnet-0f44f4247babcdef0" = { security_group_ids = ["sg-00ce17020babcdef0"] } # us-east-1b
  }

  # Configures multiple replications
  replications = {
    # The key of the map is the destination region
    "us-east-2" = {}                                   # replicates to us-east-2
    "us-west-2" = { availability_zone = "us-west-2a" } # replicates to us-west-2 in one zone storage
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the EFS file system. All associated resources will also have their names prefixed by this value

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>


### Optional



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#accesspoints">AccessPoints</a>))</code></td>
    <td width="100%">access_points</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures [access points][efs-access-point].

    

    

    
**Examples:**
- [Access Points](#access-points)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the EFS file system

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">availability_zone</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The AWS Availability Zone in which to create the file system. Specifying this value will result in an EFS using [One Zone storage class][efs-one-zone-storage-class].

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_automatic_backup</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enables [EFS automatic backup][efs-automatic-backup].

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#encryption">Encryption</a>)</code></td>
    <td width="100%">encryption</td>
    <td><code>{
  "enabled": true
}</code></td>
</tr>
<tr><td colspan="3">

Configures [encryption at rest][efs-encryption-at-rest].

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">file_system_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the JSON formatted [file system policy][efs-policy] for the EFS file system.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#lifecyclepolicy">LifecyclePolicy</a>)</code></td>
    <td width="100%">lifecycle_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures lifecycle policy.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#mounttargets">MountTargets</a>))</code></td>
    <td width="100%">mount_targets</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures [mount targets][efs-mount-target].

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">performance_mode</td>
    <td><code>"generalPurpose"</code></td>
</tr>
<tr><td colspan="3">

Specify the [performance mode][efs-performance-mode] for the file system. `maxIO` is only applicable to `throughput_mode` with `"provisioned"` or `"bursting"`.

    
**Allowed Values:**
- `generalPurpose`
- `maxIO`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">provisioned_throughput</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with `throughput_mode = "provisioned"`.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#replications">Replications</a>))</code></td>
    <td width="100%">replications</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures [replications][efs-replication].

    

    

    
**Examples:**
- [Replications](#replications)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">throughput_mode</td>
    <td><code>"elastic"</code></td>
</tr>
<tr><td colspan="3">

Specify the [throughput mode][efs-throughput-mode] for the file system.

    
**Allowed Values:**
- `bursting`
- `provisioned`
- `elastic`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

### Objects



#### AccessPoints



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the access point

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#posixuser">PosixUser</a>)</code></td>
    <td width="100%">posix_user</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the full POSIX identity on the access point that is used for all file operations by NFS clients

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#rootdirectorycreationpermissions">RootDirectoryCreationPermissions</a>)</code></td>
    <td width="100%">root_directory_creation_permissions</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the permissions EFS use to create the specified root directory if the directory does not already exist

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">root_directory_path</td>
    <td><code>"/"</code></td>
</tr>
<tr><td colspan="3">

Path on the EFS file system to expose as the root directory to NFS clients using the access point. A path can have up to four subdirectories.
`root_directory_creation_permissions` must be specified if the root path does not exist.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Encryption



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Whether encryption at rest is enabled

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Key ID or ARN of the KMS key that should be used to encrypt the file system. If omitted, the default KMS key for EFS `/aws/elasticfilesystem` will be used

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### LifecyclePolicy



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">transition_to_infrequent_access</td>
    <td></td>
</tr>
<tr><td colspan="3">

Indicates how long it takes to transition files to the IA storage class.

    
**Allowed Values:**
- `AFTER_1_DAY`
- `AFTER_7_DAYS`
- `AFTER_14_DAYS`
- `AFTER_30_DAYS`
- `AFTER_60_DAYS`
- `AFTER_90_DAYS`
- `AFTER_180_DAYS`
- `AFTER_270_DAYS`
- `AFTER_365_DAYS`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">transition_to_primary_storage_class</td>
    <td></td>
</tr>
<tr><td colspan="3">

Transitions a file from infrequent access storage back to primary storage.

    
**Allowed Values:**
- `AFTER_1_ACCESS`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### MountTargets



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of up to 5 VPC security group IDs in effect for the mount target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ip_address</td>
    <td></td>
</tr>
<tr><td colspan="3">

The address (within the address range of the specified subnet) at which the file system may be mounted via the mount target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### PosixUser

Configures the full POSIX identity on the access point that is used for all file operations by NFS clients

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">group_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

POSIX group ID used for all file system operations using this access point. Valid value: `0 - 4294967295`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">user_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

POSIX user ID used for all file system operations using this access point. Valid value: `0 - 4294967295`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(number)</code></td>
    <td width="100%">secondary_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Secondary POSIX group IDs used for all file system operations using this access point

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Replications



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">availability_zone</td>
    <td></td>
</tr>
<tr><td colspan="3">

The availability zone in which the replica should be created. If specified, the replica will be created with One Zone storage. If omitted, regional storage will be used.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Key ID or ARN of the KMS key that should be used to encrypt the replica file system. If omitted, the default KMS key for EFS `/aws/elasticfilesystem` will be used

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### RootDirectoryCreationPermissions

Configures the permissions EFS use to create the specified root directory if the directory does not already exist

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_point_permissions</td>
    <td></td>
</tr>
<tr><td colspan="3">

POSIX permissions to apply to the root directory path

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">owner_group_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Owner group ID for the access point's root directory, if the directory does not already exist. Valid value: `0 - 4294967295`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">owner_user_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Owner user ID for the access point's root directory, if the directory does not already exist. Valid value: `0 - 4294967295`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[efs-access-point]: https://docs.aws.amazon.com/efs/latest/ug/efs-access-points.html

[efs-automatic-backup]: https://docs.aws.amazon.com/efs/latest/ug/awsbackup.html#automatic-backups

[efs-encryption-at-rest]: https://docs.aws.amazon.com/efs/latest/ug/encryption-at-rest.html

[efs-lifecycle-policy]: https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html

[efs-mount-target]: https://docs.aws.amazon.com/efs/latest/ug/manage-fs-access.html

[efs-one-zone-storage-class]: https://docs.aws.amazon.com/efs/latest/ug/availability-durability.html

[efs-performance-mode]: https://docs.aws.amazon.com/efs/latest/ug/performance.html#performancemodes

[efs-policy]: https://docs.aws.amazon.com/efs/latest/ug/security_iam_resource-based-policy-examples.html

[efs-replication]: https://docs.aws.amazon.com/efs/latest/ug/efs-replication.html

[efs-throughput-mode]: https://docs.aws.amazon.com/efs/latest/ug/performance.html#throughput-modes


<!-- TFDOCS_EXTRAS_END -->

## Outputs

- (string) **`efs_arn`** _[since v1.0.0]_

    The ARN of the EFS file system

- (string) **`efs_availability_zone_id`** _[since v1.0.0]_

    The identifier of the Availability Zone in which the file system's One Zone storage classes exist

- (string) **`efs_id`** _[since v1.0.0]_

    The ID that identifies the file system

- (string) **`efs_dns_name`** _[since v1.0.0]_

    The DNS name for the filesystem

- (number) **`efs_size_in_bytes`** _[since v1.0.0]_

    The latest known metered size (in bytes) of data stored in the file system, the value is not the exact size that the file system was at any point in time

- (object) **`efs_mount_targets`** _[since v1.0.0]_

    Attributes of all mount targets for the file system

    - (string) **`availability_zone_id`** _[since v1.0.0]_

        The unique and consistent identifier of the Availability Zone (AZ) that the mount target resides in

    - (string) **`availability_zone_name`** _[since v1.0.0]_

        The name of the Availability Zone (AZ) that the mount target resides in

    - (string) **`id`** _[since v1.0.0]_

        The ID of the mount target

    - (string) **`mount_target_dns_name`** _[since v1.0.0]_

        The DNS name for the given subnet/AZ

    - (string) **`network_interface_id`** _[since v1.0.0]_

        The ID of the network interface that Amazon EFS created when it created the mount target

- (object) **`efs_replications`** _[since v1.0.0]_

    Attributes of all replications for the file system

    - (string) **`destination_file_system_id`** _[since v1.0.0]_

        The file system ID of the replica

    - (string) **`replication_status`** _[since v1.0.0]_

        The status of the replication

## Known Limitations

### Lifecycle Policy Transition To Archive

Transition to archive is not available as of provider Version 5.29.0.

[efs-access-point]:https://docs.aws.amazon.com/efs/latest/ug/efs-access-points.html
[efs-automatic-backup]:https://docs.aws.amazon.com/efs/latest/ug/awsbackup.html#automatic-backups
[efs-encryption-at-rest]:https://docs.aws.amazon.com/efs/latest/ug/encryption-at-rest.html
[efs-lifecycle-policy]:https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html
[efs-mount-target]:https://docs.aws.amazon.com/efs/latest/ug/manage-fs-access.html
[efs-one-zone-storage-class]:https://docs.aws.amazon.com/efs/latest/ug/availability-durability.html
[efs-performance-mode]:https://docs.aws.amazon.com/efs/latest/ug/performance.html#performancemodes
[efs-policy]:https://docs.aws.amazon.com/efs/latest/ug/security_iam_resource-based-policy-examples.html
[efs-replication]:https://docs.aws.amazon.com/efs/latest/ug/efs-replication.html
[efs-throughput-mode]:https://docs.aws.amazon.com/efs/latest/ug/performance.html#throughput-modes
