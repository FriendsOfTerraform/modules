variable "name" {
  type        = string
  description = <<EOT
    The name of the EFS file system. All associated resources will also have their names prefixed by this value

    @since 1.0.0
  EOT
}

variable "access_points" {
  type = map(object({
    /// Additional tags for the access point
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Configures the full POSIX identity on the access point that is used for all file operations by NFS clients
    ///
    /// @since 1.0.0
    posix_user = optional(object({
      /// POSIX group ID used for all file system operations using this access point. Valid value: `0 - 4294967295`
      ///
      /// @since 1.0.0
      group_id = number

      /// POSIX user ID used for all file system operations using this access point. Valid value: `0 - 4294967295`
      ///
      /// @since 1.0.0
      user_id = number

      /// Secondary POSIX group IDs used for all file system operations using this access point
      ///
      /// @since 1.0.0
      secondary_group_ids = optional(list(number))
    }))

    /// Configures the permissions EFS use to create the specified root directory if the directory does not already exist
    ///
    /// @since 1.0.0
    root_directory_creation_permissions = optional(object({
      /// POSIX permissions to apply to the root directory path
      ///
      /// @since 1.0.0
      access_point_permissions = string

      /// Owner group ID for the access point's root directory, if the directory does not already exist. Valid value: `0 - 4294967295`
      ///
      /// @since 1.0.0
      owner_group_id = number

      /// Owner user ID for the access point's root directory, if the directory does not already exist. Valid value: `0 - 4294967295`
      ///
      /// @since 1.0.0
      owner_user_id = number
    }))

    /// Path on the EFS file system to expose as the root directory to NFS clients using the access point. A path can have up to four subdirectories.
    /// `root_directory_creation_permissions` must be specified if the root path does not exist.
    ///
    /// @since 1.0.0
    root_directory_path = optional(string, "/")
  }))
  description = <<EOT
    Configures [access points][efs-access-point].

    @link {efs-access-point} https://docs.aws.amazon.com/efs/latest/ug/efs-access-points.html
    @example "Access Points" #access-points
    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the EFS file system

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

variable "availability_zone" {
  type        = string
  description = <<EOT
    The AWS Availability Zone in which to create the file system. Specifying this value will result in an EFS using [One Zone storage class][efs-one-zone-storage-class].

    @link {efs-one-zone-storage-class} https://docs.aws.amazon.com/efs/latest/ug/availability-durability.html
    @since 1.0.0
  EOT
  default     = null
}

variable "enable_automatic_backup" {
  type        = bool
  description = <<EOT
    Enables [EFS automatic backup][efs-automatic-backup].

    @link {efs-automatic-backup} https://docs.aws.amazon.com/efs/latest/ug/awsbackup.html#automatic-backups
    @since 1.0.0
  EOT
  default     = true
}

variable "encryption" {
  type = object({
    /// Whether encryption at rest is enabled
    ///
    /// @since 1.0.0
    enabled = bool

    /// The Key ID or ARN of the KMS key that should be used to encrypt the file system. If omitted, the default KMS key for EFS `/aws/elasticfilesystem` will be used
    ///
    /// @since 1.0.0
    kms_key_id = optional(string)
  })
  description = <<EOT
    Configures [encryption at rest][efs-encryption-at-rest].

    @link {efs-encryption-at-rest} https://docs.aws.amazon.com/efs/latest/ug/encryption-at-rest.html
    @since 1.0.0
  EOT
  default = {
    enabled = true
  }
}

variable "file_system_policy" {
  type        = string
  description = <<EOT
    Specify the JSON formatted [file system policy][efs-policy] for the EFS file system.

    @link {efs-policy} https://docs.aws.amazon.com/efs/latest/ug/security_iam_resource-based-policy-examples.html
    @since 1.0.0
  EOT
  default     = null
}

variable "lifecycle_policy" {
  type = object({
    /// Indicates how long it takes to transition files to the IA storage class.
    ///
    /// @enum AFTER_1_DAY|AFTER_7_DAYS|AFTER_14_DAYS|AFTER_30_DAYS|AFTER_60_DAYS|AFTER_90_DAYS|AFTER_180_DAYS|AFTER_270_DAYS|AFTER_365_DAYS
    /// @since 1.0.0
    transition_to_infrequent_access = optional(string)

    /// Transitions a file from infrequent access storage back to primary storage.
    ///
    /// @enum AFTER_1_ACCESS
    /// @since 1.0.0
    transition_to_primary_storage_class = optional(string)
  })
  description = <<EOT
    Configures lifecycle policy.

    @link {efs-lifecycle-policy} https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html
    @since 1.0.0
  EOT
  default     = null
}

variable "mount_targets" {
  type = map(object({
    /// A list of up to 5 VPC security group IDs in effect for the mount target
    ///
    /// @since 1.0.0
    security_group_ids = list(string)

    /// The address (within the address range of the specified subnet) at which the file system may be mounted via the mount target
    ///
    /// @since 1.0.0
    ip_address = optional(string)
  }))
  description = <<EOT
    Configures [mount targets][efs-mount-target].

    @link {efs-mount-target} https://docs.aws.amazon.com/efs/latest/ug/manage-fs-access.html
    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = {}
}

variable "performance_mode" {
  type        = string
  description = <<EOT
    Specify the [performance mode][efs-performance-mode] for the file system. `maxIO` is only applicable to `throughput_mode` with `"provisioned"` or `"bursting"`.

    @enum generalPurpose|maxIO
    @link {efs-performance-mode} https://docs.aws.amazon.com/efs/latest/ug/performance.html#performancemodes
    @since 1.0.0
  EOT
  default     = "generalPurpose"
}

variable "provisioned_throughput" {
  type        = number
  description = <<EOT
    Specify the throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with `throughput_mode = "provisioned"`.

    @since 1.0.0
  EOT
  default     = null
}

variable "replications" {
  type = map(object({
    /// The availability zone in which the replica should be created. If specified, the replica will be created with One Zone storage. If omitted, regional storage will be used.
    ///
    /// @since 1.0.0
    availability_zone = optional(string)

    /// The Key ID or ARN of the KMS key that should be used to encrypt the replica file system. If omitted, the default KMS key for EFS `/aws/elasticfilesystem` will be used
    ///
    /// @since 1.0.0
    kms_key_id = optional(string)
  }))
  description = <<EOT
    Configures [replications][efs-replication].

    @link {efs-replication} https://docs.aws.amazon.com/efs/latest/ug/efs-replication.html
    @example "Replications" #replications
    @since 1.0.0
  EOT
  default     = {}
}

variable "throughput_mode" {
  type        = string
  description = <<EOT
    Specify the [throughput mode][efs-throughput-mode] for the file system.

    @enum bursting|provisioned|elastic
    @link {efs-throughput-mode} https://docs.aws.amazon.com/efs/latest/ug/performance.html#throughput-modes
    @since 1.0.0
  EOT
  default     = "elastic"
}
