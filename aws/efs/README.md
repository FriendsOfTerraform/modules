# Elastic File System Module

This module will build and configure an [EFS](https://aws.amazon.com/efs/) file system

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Access Points](#access-points)
    - [Replications](#replications)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
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

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the EFS file system. All associated resources' names will also be prefixed by this value

### Optional

- (map(object)) **`access_points = {}`** _[since v1.0.0]_

    Configures [access points][efs-access-point]. [See example](#access-points)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the access point

    - (object) **`posix_user = null`** _[since v1.0.0]_

        Configures the full POSIX identity on the access point that is used for all file operations by NFS clients

        - (number) **`group_id`** _[since v1.0.0]_

            POSIX group ID used for all file system operations using this access point. valid value: `0 - 4294967295`

        - (number) **`user_id`** _[since v1.0.0]_

            POSIX user ID used for all file system operations using this access point. valid value: `0 - 4294967295`

        - (list(number)) **`secondary_group_ids = null`** _[since v1.0.0]_

            Secondary POSIX group IDs used for all file system operations using this access point.

    - (object) **`root_directory_creation_permissions = null`** _[since v1.0.0]_

        Configures the permissions EFS use to create the specified root directory if the directory does not already exist.

        - (string) **`access_point_permissions`** _[since v1.0.0]_

            POSIX permissions to apply to the root directory path

        - (number) **`owner_group_id`** _[since v1.0.0]_

            Owner group ID for the access point's root directory, if the directory does not already exist. valid value: `0 - 4294967295`

        - (number) **`owner_user_id`** _[since v1.0.0]_

            Owner user ID for the access point's root directory, if the directory does not already exist. valid value: `0 - 4294967295`

    - (string) **`root_directory_path = "/"`** _[since v1.0.0]_

        Path on the EFS file system to expose as the root directory to NFS clients using the access point to access the EFS file system. A path can have up to four subdirectories. `root_directory_creation_permissions` must be specified if the root path does not exist.

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the EFS file system

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (string) **`availability_zone = null`** _[since v1.0.0]_

    The AWS Availability Zone in which to create the file system. Specifying this value will result in an EFS using [One Zone storage class][efs-one-zone-storage-class].

- (bool) **`enable_automatic_backup = true`** _[since v1.0.0]_

    Enables [EFS automatic backup][efs-automatic-backup]

- (object) **`encryption = { enabled = true }`** _[since v1.0.0]_

    Configures [encryption at rest][efs-encryption-at-rest].

    - (bool) **`enabled = true`** _[since v1.0.0]_

        Whether encryption at rest is enabled

    - (string) **`kms_key_id = null`** _[since v1.0.0]_

        The Key ID or ARN of the KMS key that should be used to encrypt the file system. If omitted, the default KMS key for EFS `/aws/elasticfilesystem` will be used

- (string) **`file_system_policy = null`** _[since v1.0.0]_

    Specify the JSON formatted [file system policy][efs-policy] for the EFS file system

- (object) **`lifecycle_policy = null`** _[since v1.0.0]_

    Configures [lifecycle policy][efs-lifecycle-policy].

    - (string) **`transition_to_infrequent_access = null`** _[since v1.0.0]_

         Indicates how long it takes to transition files to the IA storage class. Valid values: `"AFTER_1_DAY"`, `"AFTER_7_DAYS"`, `"AFTER_14_DAYS"`, `"AFTER_30_DAYS"`, `"AFTER_60_DAYS"`, `"AFTER_90_DAYS"`, `"AFTER_180_DAYS"`, `"AFTER_270_DAYS"`, `"AFTER_365_DAYS"`

    - (string) **`transition_to_primary_storage_class = null`** _[since v1.0.0]_

        Transitions a file from infequent access storage back to primary storage. Valid values: `"AFTER_1_ACCESS"`

- (map(object)) **`mount_targets = {}`** _[since v1.0.0]_

    Configures [mount targets][efs-mount-target]. [See example](#basic-usage)

    - (list(string)) **`security_group_ids`** _[since v1.0.0]_

        A list of up to 5 VPC security group IDs in effect for the mount target

    - (string) **`ip_address = null`** _[since v1.0.0]_

        The address (within the address range of the specified subnet) at which the file system may be mounted via the mount target.

- (string) **`performance_mode = "generalPurpose"`** _[since v1.0.0]_

    Specify the [performance mode][efs-performance-mode] for the file system. Valid values: `"generalPurpose"`, `"maxIO"`. `"maxIO"` is only applicable to `throughput_mode` with `"provisioned"` or `"bursting"`

- (number) **`provisioned_throughput = null`** _[since v1.0.0]_

    Specify the throughput in MiB/s, that you want to provision for the file system. Only applicable with `throughput_mode = "provisioned"`

- (map(object)) **`replications = {}`** _[since v1.0.0]_

    Configures [replications][efs-replication]. [See example](#replications)

    - (string) **`availability_zone = null`** _[since v1.0.0]_

        The availability zone in which the replica should be created. If specified, the replica will be created with One Zone storage. If omitted, regional storage will be used.

    - (string) **`kms_key_id = null`** _[since v1.0.0]_

        The Key ID or ARN of the KMS key that should be used to encrypt the replica file system. If omitted, the default KMS key for EFS `/aws/elasticfilesystem` will be used.

- (string) **`throughput_mode = "elastic"`** _[since v1.0.0]_

    Specify the [Throughput mode][efs-throughput-mode] for the file system. Valid values: `"bursting"`, `"provisioned"`, or `"elastic"`

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
