variable "name" {
  type = string

  description = <<EOT
    Name of the backup vault

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
}

variable "access_policy" {
  default = null
  type    = string

  description = <<EOT
    Resource-based policy JSON document associated with the backup vault

    @example "Vault Access Policy And Notifications" #vault-access-policy-and-notifications
    @since 1.0.0
  EOT
}

variable "additional_tags" {
  default  = {}
  nullable = false
  type     = map(string)

  description = <<EOT
    Additional tags associated with the backup vault

    @since 1.0.0
  EOT
}

variable "additional_tags_all" {
  default = {}
  type    = map(string)

  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
}

variable "backup_plans" {
  default = {}

  description = <<EOT
    Manage backup plans in AWS Backup. The key of the map is the backup plan name.

    @example "Basic Usage" #basic-usage
    @example "Copy To Another Vault" #copy-to-another-vault
    @since 1.0.0
  EOT

  type = map(object({
    /// Additional tags associated with the backup plan
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Rules that specify the backup schedule, backup window, and lifecycle of backups for the plan.
    /// The key of the map is the rule name.
    ///
    /// @since 1.0.0
    rules = map(object({
      /// Cron expression that specifies when the backup rule runs
      ///
      /// @since 1.0.0
      backup_frequency_cron_expression = string

      /// Defines the period of time during which your backup must complete.
      /// If the data transfer for backing up your resource does not complete during this period of time,
      /// AWS Backup will display the status `Expired`
      /// Use "<number> <unit>", with minute(s), hour(s), day(s), week(s), month(s), or year(s).
      /// Months are 30 days and years are 365 days.
      ///
      /// @since 1.0.0
      complete_within = optional(string, "7 days")

      /// Enable continuous backups for point-in-time recovery on supported resources
      /// With continuous backups, you can restore your AWS Backup-supported resource by rewinding it back to a specific time
      /// that you choose, within 1 second of precision (going back a maximum of 35 days).
      /// Available for Aurora, RDS, S3, and SAP HANA on Amazon EC2 resources.
      ///
      /// @since 1.0.0
      enable_continuous_backups_for_point_in_time_recovery = optional(bool, false)

      /// AWS Backup copies tags from the protected resource to the recovery point upon creation. You can specify additional
      /// tags to add to the recovery point.
      ///
      /// @since 1.0.0
      recovery_point_tags = optional(map(string), {})

      /// Malware scan mode for recovery points created by the backup rule
      /// No scan action is configured when omitted.
      ///
      /// @enum FULL_SCAN|INCREMENTAL_SCAN
      /// @since 1.0.0
      scan_mode = optional(string, null)

      /// Specify period of time in which the backup plan starts if it doesn’t start at the specified time.
      /// Use "<number> <unit>", with minute(s), hour(s), day(s), week(s), month(s), or year(s).
      /// Months are 30 days and years are 365 days.
      ///
      /// @since 1.0.0
      start_within = optional(string, "8 hours")

      /// IANA time zone used to evaluate the backup schedule
      ///
      /// @since 1.0.0
      time_zone = optional(string, "Etc/UTC")

      /// Create a copy of backup in a separate backup vault or logically air-gapped vault.
      ///
      /// @since 1.0.0
      copy_to_destinations = optional(list(object({
        /// ARN of the backup vault that receives the copied recovery points
        ///
        /// @since 1.0.0
        destination_vault_arn = string

        /// Lifecycle settings for recovery points copied to the destination vault. if not specified, the same settings from backup rule are applied.
        ///
        /// @since 1.0.0
        lifecycle = optional(object({
          /// Time after creation before a copied backup transitions from warm to cold storage
          /// Available for Amazon EBS, Amazon EFS, Amazon DynamoDB (with advanced features), Amazon Timestream, SAP HANA on EC2,
          /// and VMware backups
          /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
          /// Months are 30 days and years are 365 days.
          ///
          /// @since 1.0.0
          move_backups_from_warm_to_cold_storage_after = optional(string, null)

          /// Total time a copied backup is retained before deletion
          /// Total retention must be set between `days in warm storage plus 90 days in cold storage (if enabled)` and 100 years.
          /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
          /// Months are 30 days and years are 365 days.
          ///
          /// @since 1.0.0
          total_retention_period = optional(string, "35 days")
        }), null)
      })), [])

      /// Lifecycle settings for recovery points created by the backup rule
      ///
      /// @since 1.0.0
      lifecycle = optional(object({
        /// Time after creation before a backup transitions from warm to cold storage
        /// Available for Amazon EBS, Amazon EFS, Amazon DynamoDB (with advanced features), Amazon Timestream, SAP HANA on EC2,
        /// and VMware backups
        /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
        /// Months are 30 days and years are 365 days.
        ///
        /// @since 1.0.0
        move_backups_from_warm_to_cold_storage_after = optional(string, null)

        /// Total time a backup is retained before deletion
        /// Total retention must be set between `days in warm storage plus 90 days in cold storage (if enabled)` and 100 years.
        /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
        /// Months are 30 days and years are 365 days.
        ///
        /// @since 1.0.0
        total_retention_period = optional(string, "35 days")
      }), null)
    }))

    /// Advanced backup options for supported resource types
    ///
    /// @since 1.0.0
    advanced_backup_settings = optional(object({
      /// Application-consistent backup options
      ///
      /// @since 1.0.0
      application_consistent_backup = optional(object({
        /// Enable Windows Volume Shadow Copy Service (VSS) for application-consistent backups
        ///
        /// @since 1.0.0
        windows_vss = optional(bool, false)
      }), {})
    }), {})

    /// Malware scanner settings for the backup plan
    /// No plan-level scan settings are configured when omitted.
    ///
    /// @since 1.0.0
    enable_malware_scans = optional(object({
      /// ARN of the IAM role used by the malware scanner
      ///
      /// @since 1.0.0
      scanner_role_arn = string

      /// Malware scanner used to scan recovery points. Only supports "GUARDDUTY" at this time.
      ///
      /// @since 1.0.0
      malware_scanner = optional(string, "GUARDDUTY")

      /// Resource types to scan. Use "ALL" to scan all supported resource types.
      ///
      /// @enum ALL|EBS|EC2|S3
      /// @since 1.0.0
      scannable_resource_types = optional(list(string), ["ALL"])
    }), null)

    /// When you assign a resource to a backup plan, AWS Backup automatically backs up your assigned
    /// resource according to your backup plan.
    /// The key of the map is the resource assignment name.
    ///
    /// @since 1.0.0
    resource_assignments = optional(map(object({
      /// ARN of the IAM role that AWS Backup assumes to back up the selected resources
      /// The role that you pass to AWS Backup must have an IAM policy with the appropriate permissions to enable AWS Backup to perform the
      /// actions necessary for backup operations, such as creating, restoring, or expiring backups.
      ///
      /// @since 1.0.0
      iam_role_arn = string

      /// Tag conditions used to filter the selected resources. All conditions must match.
      /// Use "<key> <operator> <value>", with operators "==", "!=", "like", or "notlike".
      /// Tag keys use the "aws:ResourceTag/<tag-key>" format.
      /// The "like" and "notlike" operators support "*" wildcards.
      /// Example: "aws:ResourceTag/Environment == production"
      ///
      /// @since 1.0.0
      conditions = optional(list(string), [])

      /// Resource ARNs or ARN patterns to exclude from the assignment
      /// The maximum number of ARNs is 500 without wildcards, or 30 ARNs with wildcards.
      ///
      /// @since 1.0.0
      not_resources = optional(list(string), null)

      /// Resource ARNs or ARN patterns to include in the assignment.
      /// Defaults to all supported resources, subject to the assignment conditions and exclusions.
      /// The maximum number of ARNs is 500 without wildcards, or 30 ARNs with wildcards.
      ///
      /// @since 1.0.0
      resources = optional(list(string), ["*"])
    })), {})
  }))
}

variable "enable_vault_lock" {
  default = null

  description = <<EOT
    When a vault lock is enabled, the contents of the vault cannot be altered or deleted by a customer, account/data owner, or AWS.
    Only applicable to standard vaults.

    @example "Vault Lock" #vault-lock
    @since 1.0.0
  EOT

  type = object({
    /// Maximum retention period allowed for backup and copy jobs targeting the vault.
    /// Jobs with a longer retention period fail. No maximum is enforced when omitted.
    /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
    /// Months are 30 days and years are 365 days.
    ///
    /// @since 1.0.0
    maximum_retention_period = optional(string, null)

    /// Minimum retention period required for backup and copy jobs targeting the vault.
    /// Jobs with a shorter retention period fail.
    /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
    /// Months are 30 days and years are 365 days.
    ///
    /// @since 1.0.0
    minimum_retention_period = optional(string, "1 day")

    /// Enable compliance mode. A vault lock in Compliance mode cannot be altered or deleted by any user or by AWS once the grace
    /// time expires.
    /// When omitted, Vault Lock uses governance mode and can be managed or deleted by users who have the appropriate IAM permissions.
    ///
    /// @since 1.0.0
    compliance_mode = optional(object({
      /// Grace period after configuring Vault Lock before the lock becomes immutable.
      /// After this period, the lock cannot be changed or removed, even by the root user.
      /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
      /// Months are 30 days and years are 365 days.
      ///
      /// Valid value: `"3 days" - "100 years"`
      ///
      /// @since 1.0.0
      start_after = optional(string, "3 days")
    }), null)
  })
}

variable "encryption_key_arn" {
  default = null
  type    = string

  description = <<EOT
    The ARN of the customer managed key (CMK) used to encrypt backups in the vault. AWS managed
    key will be used if not specified.

    @since 1.0.0
  EOT
}

variable "maximum_retention_period" {
  default  = "35 days"
  nullable = false
  type     = string

  description = <<EOT
    Maximum retention period allowed for backup and copy jobs targeting the vault.
    Jobs with a longer retention period fail. No maximum is enforced when omitted.
    Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
    Months are 30 days and years are 365 days.

    This setting is only applicable to logically air-gapped vaults.
    @since 1.0.0
  EOT
}

variable "minimum_retention_period" {
  default  = "7 days"
  nullable = false
  type     = string

  description = <<EOT
    Minimum retention period required for backup and copy jobs targeting the vault.
    Jobs with a shorter retention period fail.
    Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
    Months are 30 days and years are 365 days.

    This setting is only applicable to logically air-gapped vaults.
    @since 1.0.0
  EOT
}

variable "notifications" {
  default = null

  description = <<EOT
    Notifications configuration for the backup vault. AWS Backup supports one notification configuration per vault.

    @example "Vault Access Policy And Notifications" #vault-access-policy-and-notifications
    @since 1.0.0
  EOT

  type = object({
    /// The events that trigger notifications
    ///
    /// @since 1.0.0
    backup_vault_events = list(string)

    /// The ARN of the SNS topic to send notifications to
    ///
    /// @since 1.0.0
    sns_topic_arn = string
  })
}

variable "restore_testing_plans" {
  default = {}

  description = <<EOT
    Manage AWS Backup restore testing plans, including test schedules, recovery point selection,
    and protected resource selections. The key of the map is the restore testing plan name.

    @example "Restore Testing" #restore-testing
    @since 1.0.0
  EOT

  type = map(object({
    /// Cron expression that specifies when the restore testing plan runs
    ///
    /// @since 1.0.0
    test_frequency_cron_expression = string

    /// Additional tags associated with the restore testing plan
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Restore jobs will start within the time window specified. For example, if you choose 8 hours,
    /// restore jobs will start randomly within 8 hours after the plan's scheduled start time.
    /// Use "<number> <unit>", with hour(s), day(s), or week(s).
    ///
    /// @since 1.0.0
    start_within = optional(string, "8 hours")

    /// IANA time zone used to evaluate the restore testing schedule
    ///
    /// @since 1.0.0
    time_zone = optional(string, "Etc/UTC")

    /// Settings used to select eligible recovery points from the backup vault for restore testing
    ///
    /// @since 1.0.0
    eligible_recovery_points_selection = object({
      /// Specify which recovery point should be restored from the eligible recovery points.
      ///
      /// @enum LATEST|RANDOM
      /// @since 1.0.0
      algorithm = optional(string, "LATEST")

      /// Whether recovery points generated by PITR will be included in this restore testing plan.
      ///
      /// @since 1.0.0
      include_point_in_time_recovery_points = optional(bool, false)

      /// Lookback period used to identify eligible recovery points.
      /// Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
      /// Months are 30 days and years are 365 days.
      ///
      /// @since 1.0.0
      window = optional(string, "1 week")
    })

    /// Protected resources to include in restore testing.
    /// The key of the map is the protected resource selection name.
    ///
    /// @since 1.0.0
    protected_resource_selections = optional(map(object({
      /// AWS Backup resource type to restore for this selection
      ///
      /// @enum Aurora|DocumentDB|DynamoDB|EBS|EC2|EFS|FSx|Neptune|RDS|S3
      /// @since 1.0.0
      resource_type = string

      /// Specify the IAM role that AWS Backup will assume when running the restore test.
      ///
      /// @since 1.0.0
      restore_iam_role_arn = string

      /// Tag conditions used to filter protected resources.
      /// Use "<key> <operator> <value>", with operators "==" or "!=".
      /// Tag keys use the "aws:ResourceTag/<tag-key>" format.
      /// Example: "aws:ResourceTag/Environment == production"
      ///
      /// @since 1.0.0
      conditions = optional(list(string), [])

      /// ARNs of protected resources to include in restore testing
      ///
      /// @since 1.0.0
      resource_arns = optional(list(string), null)

      /// Restore metadata key-value pairs to override during restore testing.
      /// AWS Backup recommends to keep the default parameters, which were set to ensure the best restore test experience;
      /// some parameters may be altered if necessary. Valid values are resource type dependent.
      ///
      /// @link "Restore testing inferred metadata" https://docs.aws.amazon.com/aws-backup/latest/devguide/restore-testing-inferred-metadata.html
      /// @since 1.0.0
      restore_parameters_override = optional(map(string), null)

      /// Validation period after a successful restore before AWS Backup cleans up the restored resources.
      /// Use "<number> <unit>", with hour(s), day(s), or week(s).
      ///
      /// @since 1.0.0
      retention_period_before_cleanup = optional(string, null)
    })), {})
  }))
}

variable "vault_type" {
  default  = "standard"
  nullable = false
  type     = string

  description = <<EOT
    The type of the backup vault.

    @enum standard|logically_air_gapped
    @example "Logically Air-Gapped Vault" #logically-air-gapped-vault
    @since 1.0.0
  EOT
}
