# Backup Module

This module creates and manages a single [AWS Backup](https://aws.amazon.com/backup/) vault, along with its backup plans, resource assignments, vault lock, notifications, and restore testing plans

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
  - [Copy To Another Vault](#copy-to-another-vault)
  - [Logically Air-Gapped Vault](#logically-air-gapped-vault)
  - [Vault Lock](#vault-lock)
  - [Vault Access Policy And Notifications](#vault-access-policy-and-notifications)
  - [Restore Testing](#restore-testing)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-backup.git?ref=v1.0.0"

  name = "demo-vault"

  backup_plans = {
    # The key of the map is the backup plan name
    "daily-backups" = {
      rules = {
        # The key of the map is the rule name
        "daily" = {
          backup_frequency_cron_expression = "cron(0 5 ? * * *)"
          time_zone                        = "America/Los_Angeles"

          lifecycle = {
            move_backups_from_warm_to_cold_storage_after = "1 month"
            total_retention_period                       = "1 year"
          }
        }
      }

      # Back up all supported resources tagged with Environment = production
      resource_assignments = {
        "production-resources" = {
          iam_role_arn = "arn:aws:iam::111122223333:role/service-role/AWSBackupDefaultServiceRole"
          conditions   = ["aws:ResourceTag/Environment == production"]
        }
      }
    }
  }
}
```

### Copy To Another Vault

```terraform
module "copy_to_another_vault" {
  source = "github.com/FriendsOfTerraform/aws-backup.git?ref=v1.0.0"

  name = "demo-vault"

  backup_plans = {
    "daily-backups" = {
      rules = {
        "daily" = {
          backup_frequency_cron_expression = "cron(0 5 ? * * *)"

          lifecycle = {
            total_retention_period = "35 days"
          }

          # Copy each recovery point to a vault in another region
          # If lifecycle is omitted, the lifecycle settings of the rule are applied
          copy_to_destinations = [
            {
              destination_vault_arn = "arn:aws:backup:us-west-2:111122223333:backup-vault:demo-vault-dr"

              lifecycle = {
                total_retention_period = "90 days"
              }
            }
          ]
        }
      }

      resource_assignments = {
        "production-resources" = {
          iam_role_arn = "arn:aws:iam::111122223333:role/service-role/AWSBackupDefaultServiceRole"
          conditions   = ["aws:ResourceTag/Environment == production"]
        }
      }
    }
  }
}
```

### Logically Air-Gapped Vault

```terraform
module "logically_air_gapped_vault" {
  source = "github.com/FriendsOfTerraform/aws-backup.git?ref=v1.0.0"

  name       = "demo-air-gapped-vault"
  vault_type = "logically_air_gapped"

  # Backup and copy jobs must specify a retention period within this range
  minimum_retention_period = "7 days"
  maximum_retention_period = "1 year"
}
```

### Vault Lock

```terraform
module "vault_lock" {
  source = "github.com/FriendsOfTerraform/aws-backup.git?ref=v1.0.0"

  name = "demo-vault"

  enable_vault_lock = {
    minimum_retention_period = "7 days"
    maximum_retention_period = "1 year"

    # Remove compliance_mode to use governance mode instead
    # WARNING: once the grace period expires, the vault lock cannot be changed or removed by anyone, including AWS
    compliance_mode = {
      start_after = "3 days"
    }
  }
}
```

### Vault Access Policy And Notifications

```terraform
module "vault_access_policy_and_notifications" {
  source = "github.com/FriendsOfTerraform/aws-backup.git?ref=v1.0.0"

  name = "demo-vault"

  # Prevent recovery points in this vault from being deleted
  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = { AWS = "*" }
        Action    = "backup:DeleteRecoveryPoint"
        Resource  = "*"
      }
    ]
  })

  notifications = {
    backup_vault_events = ["BACKUP_JOB_COMPLETED", "RESTORE_JOB_COMPLETED", "COPY_JOB_FAILED"]
    sns_topic_arn       = "arn:aws:sns:us-east-1:111122223333:backup-notifications"
  }
}
```

### Restore Testing

```terraform
module "restore_testing" {
  source = "github.com/FriendsOfTerraform/aws-backup.git?ref=v1.0.0"

  name = "demo-vault"

  restore_testing_plans = {
    # The key of the map is the restore testing plan name
    "weekly_restore_test" = {
      test_frequency_cron_expression = "cron(0 5 ? * SUN *)"

      # Restore the latest recovery point created within the last week
      eligible_recovery_points_selection = {
        algorithm = "LATEST"
        window    = "1 week"
      }

      protected_resource_selections = {
        # The key of the map is the protected resource selection name
        "production_ebs_volumes" = {
          resource_type        = "EBS"
          restore_iam_role_arn = "arn:aws:iam::111122223333:role/service-role/AWSBackupDefaultServiceRole"
          conditions           = ["aws:ResourceTag/Environment == production"]

          # Restored resources are cleaned up after this validation period
          retention_period_before_cleanup = "4 hours"
        }
      }
    }
  }
}
```

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="3">

Name of the backup vault

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_policy</td><td><code>null</code></td>
</tr>
<tr><td colspan="3">

Resource-based policy JSON document associated with the backup vault

**Examples:**

- [Vault Access Policy And Notifications](#vault-access-policy-and-notifications)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td><td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags associated with the backup vault

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td><td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#backup_plans">backup_plans</a>))</code></td>
    <td width="100%">backup_plans</td><td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manage backup plans in AWS Backup. The key of the map is the backup plan name.

**Examples:**

- [Basic Usage](#basic-usage)
- [Copy To Another Vault](#copy-to-another-vault)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#enable_vault_lock">enable_vault_lock</a>)</code></td>
    <td width="100%">enable_vault_lock</td><td><code>null</code></td>
</tr>
<tr><td colspan="3">

When a vault lock is enabled, the contents of the vault cannot be altered or deleted by a customer, account/data owner, or AWS.
Only applicable to standard vaults.

**Examples:**

- [Vault Lock](#vault-lock)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">encryption_key_arn</td><td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ARN of the customer managed key (CMK) used to encrypt backups in the vault. AWS managed
key will be used if not specified.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">maximum_retention_period</td><td><code>"35 days"</code></td>
</tr>
<tr><td colspan="3">

Maximum retention period allowed for backup and copy jobs targeting the vault.
Jobs with a longer retention period fail. No maximum is enforced when omitted.
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

This setting is only applicable to logically air-gapped vaults.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">minimum_retention_period</td><td><code>"7 days"</code></td>
</tr>
<tr><td colspan="3">

Minimum retention period required for backup and copy jobs targeting the vault.
Jobs with a shorter retention period fail.
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

This setting is only applicable to logically air-gapped vaults.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#notifications">notifications</a>)</code></td>
    <td width="100%">notifications</td><td><code>null</code></td>
</tr>
<tr><td colspan="3">

Notifications configuration for the backup vault. AWS Backup supports one notification configuration per vault.

**Examples:**

- [Vault Access Policy And Notifications](#vault-access-policy-and-notifications)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#restore_testing_plans">restore_testing_plans</a>))</code></td>
    <td width="100%">restore_testing_plans</td><td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manage AWS Backup restore testing plans, including test schedules, recovery point selection,
and protected resource selections. The key of the map is the restore testing plan name.

**Examples:**

- [Restore Testing](#restore-testing)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">vault_type</td><td><code>"standard"</code></td>
</tr>
<tr><td colspan="3">

The type of the backup vault.

**Allowed Values:**

- `standard`
- `logically_air_gapped`

**Examples:**

- [Logically Air-Gapped Vault](#logically-air-gapped-vault)

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#backup_plans">backup_plans</a>))</code></td>
    <td width="100%">backup_plans</td><td></td>
</tr>
<tr><td colspan="3">

Attributes of all backup plans managed by this module. The key of the map is the backup plan name.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">backup_vault_arn</td><td></td>
</tr>
<tr><td colspan="3">

The ARN of the backup vault

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">backup_vault_name</td><td></td>
</tr>
<tr><td colspan="3">

The name of the backup vault

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">backup_vault_recovery_points</td><td></td>
</tr>
<tr><td colspan="3">

The number of recovery points stored in the backup vault. Only applicable to standard vaults; `null` for logically air-gapped vaults.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#restore_testing_plans">restore_testing_plans</a>))</code></td>
    <td width="100%">restore_testing_plans</td><td></td>
</tr>
<tr><td colspan="3">

Attributes of all restore testing plans managed by this module. The key of the map is the restore testing plan name.

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Objects

#### advanced_backup_settings

Advanced backup options for supported resource types

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#application_consistent_backup">application_consistent_backup</a>)</code></td>
    <td width="100%">application_consistent_backup</td><td></td><td><code>{}</code></td>
</tr>
<tr><td colspan="4">

Application-consistent backup options

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### application_consistent_backup

Application-consistent backup options

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">windows_vss</td><td></td><td><code>false</code></td>
</tr>
<tr><td colspan="4">

Enable Windows Volume Shadow Copy Service (VSS) for application-consistent backups

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### backup_plans

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

The ARN of the backup plan

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

The ID of the backup plan

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">version</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### compliance_mode

Enable compliance mode. A vault lock in Compliance mode cannot be altered or deleted by any user or by AWS once the grace
time expires.
When omitted, Vault Lock uses governance mode and can be managed or deleted by users who have the appropriate IAM permissions.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">start_after</td><td></td><td><code>"3 days"</code></td>
</tr>
<tr><td colspan="4">

Grace period after configuring Vault Lock before the lock becomes immutable.
After this period, the lock cannot be changed or removed, even by the root user.
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

Valid value: `"3 days" - "100 years"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### copy_to_destinations

Create a copy of backup in a separate backup vault or logically air-gapped vault.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">destination_vault_arn</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

ARN of the backup vault that receives the copied recovery points

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#lifecycle">lifecycle</a>)</code></td>
    <td width="100%">lifecycle</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Lifecycle settings for recovery points copied to the destination vault. if not specified, the same settings from backup rule are applied.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### eligible_recovery_points_selection

Settings used to select eligible recovery points from the backup vault for restore testing

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">algorithm</td><td></td><td><code>"LATEST"</code></td>
</tr>
<tr><td colspan="4">

Specify which recovery point should be restored from the eligible recovery points.

**Allowed Values:**

- `LATEST`
- `RANDOM`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">include_point_in_time_recovery_points</td><td></td><td><code>false</code></td>
</tr>
<tr><td colspan="4">

Whether recovery points generated by PITR will be included in this restore testing plan.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">window</td><td></td><td><code>"1 week"</code></td>
</tr>
<tr><td colspan="4">

Lookback period used to identify eligible recovery points.
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### enable_malware_scans

Malware scanner settings for the backup plan
No plan-level scan settings are configured when omitted.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">scanner_role_arn</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

ARN of the IAM role used by the malware scanner

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">malware_scanner</td><td></td><td><code>"GUARDDUTY"</code></td>
</tr>
<tr><td colspan="4">

Malware scanner used to scan recovery points. Only supports "GUARDDUTY" at this time.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">scannable_resource_types</td><td></td><td><code>["ALL"]</code></td>
</tr>
<tr><td colspan="4">

Resource types to scan. Use "ALL" to scan all supported resource types.

**Allowed Values:**

- `ALL`
- `EBS`
- `EC2`
- `S3`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### enable_vault_lock

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">maximum_retention_period</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Maximum retention period allowed for backup and copy jobs targeting the vault.
Jobs with a longer retention period fail. No maximum is enforced when omitted.
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">minimum_retention_period</td><td></td><td><code>"1 day"</code></td>
</tr>
<tr><td colspan="4">

Minimum retention period required for backup and copy jobs targeting the vault.
Jobs with a shorter retention period fail.
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#compliance_mode">compliance_mode</a>)</code></td>
    <td width="100%">compliance_mode</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Enable compliance mode. A vault lock in Compliance mode cannot be altered or deleted by any user or by AWS once the grace
time expires.
When omitted, Vault Lock uses governance mode and can be managed or deleted by users who have the appropriate IAM permissions.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### lifecycle

Lifecycle settings for recovery points created by the backup rule

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">move_backups_from_warm_to_cold_storage_after</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Time after creation before a backup transitions from warm to cold storage
Available for Amazon EBS, Amazon EFS, Amazon DynamoDB (with advanced features), Amazon Timestream, SAP HANA on EC2,
and VMware backups
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">total_retention_period</td><td></td><td><code>"35 days"</code></td>
</tr>
<tr><td colspan="4">

Total time a backup is retained before deletion
Total retention must be set between `days in warm storage plus 90 days in cold storage (if enabled)` and 100 years.
Use "<number> <unit>", with day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### notifications

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">backup_vault_events</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

The events that trigger notifications

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">sns_topic_arn</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

The ARN of the SNS topic to send notifications to

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### protected_resource_selections

Protected resources to include in restore testing.
The key of the map is the protected resource selection name.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_type</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

AWS Backup resource type to restore for this selection

**Allowed Values:**

- `Aurora`
- `DocumentDB`
- `DynamoDB`
- `EBS`
- `EC2`
- `EFS`
- `FSx`
- `Neptune`
- `RDS`
- `S3`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">restore_iam_role_arn</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

Specify the IAM role that AWS Backup will assume when running the restore test.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">conditions</td><td></td><td><code>[]</code></td>
</tr>
<tr><td colspan="4">

Tag conditions used to filter protected resources.
Use "<key> <operator> <value>", with operators "==" or "!=".
Tag keys use the "aws:ResourceTag/<tag-key>" format.
Example: "aws:ResourceTag/Environment == production"

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">resource_arns</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

ARNs of protected resources to include in restore testing

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">restore_parameters_override</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Restore metadata key-value pairs to override during restore testing.
AWS Backup recommends to keep the default parameters, which were set to ensure the best restore test experience;
some parameters may be altered if necessary. Valid values are resource type dependent.

**Links:**

- [Restore testing inferred metadata](https://docs.aws.amazon.com/aws-backup/latest/devguide/restore-testing-inferred-metadata.html)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">retention_period_before_cleanup</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Validation period after a successful restore before AWS Backup cleans up the restored resources.
Use "<number> <unit>", with hour(s), day(s), or week(s).

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### resource_assignments

When you assign a resource to a backup plan, AWS Backup automatically backs up your assigned
resource according to your backup plan.
The key of the map is the resource assignment name.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

ARN of the IAM role that AWS Backup assumes to back up the selected resources
The role that you pass to AWS Backup must have an IAM policy with the appropriate permissions to enable AWS Backup to perform the
actions necessary for backup operations, such as creating, restoring, or expiring backups.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">conditions</td><td></td><td><code>[]</code></td>
</tr>
<tr><td colspan="4">

Tag conditions used to filter the selected resources. All conditions must match.
Use "<key> <operator> <value>", with operators "==", "!=", "like", or "notlike".
Tag keys use the "aws:ResourceTag/<tag-key>" format.
The "like" and "notlike" operators support "*" wildcards.
Example: "aws:ResourceTag/Environment == production"

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">not_resources</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Resource ARNs or ARN patterns to exclude from the assignment
The maximum number of ARNs is 500 without wildcards, or 30 ARNs with wildcards.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">resources</td><td></td><td><code>["*"]</code></td>
</tr>
<tr><td colspan="4">

Resource ARNs or ARN patterns to include in the assignment.
Defaults to all supported resources, subject to the assignment conditions and exclusions.
The maximum number of ARNs is 500 without wildcards, or 30 ARNs with wildcards.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### restore_testing_plans

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

The ARN of the restore testing plan

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### rules

Rules that specify the backup schedule, backup window, and lifecycle of backups for the plan.
The key of the map is the rule name.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Required</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">backup_frequency_cron_expression</td><td>Yes</td><td><em>n/a</em></td>
</tr>
<tr><td colspan="4">

Cron expression that specifies when the backup rule runs

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">complete_within</td><td></td><td><code>"7 days"</code></td>
</tr>
<tr><td colspan="4">

Defines the period of time during which your backup must complete.
If the data transfer for backing up your resource does not complete during this period of time,
AWS Backup will display the status `Expired`
Use "<number> <unit>", with minute(s), hour(s), day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_continuous_backups_for_point_in_time_recovery</td><td></td><td><code>false</code></td>
</tr>
<tr><td colspan="4">

Enable continuous backups for point-in-time recovery on supported resources
With continuous backups, you can restore your AWS Backup-supported resource by rewinding it back to a specific time
that you choose, within 1 second of precision (going back a maximum of 35 days).
Available for Aurora, RDS, S3, and SAP HANA on Amazon EC2 resources.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">recovery_point_tags</td><td></td><td><code>{}</code></td>
</tr>
<tr><td colspan="4">

AWS Backup copies tags from the protected resource to the recovery point upon creation. You can specify additional
tags to add to the recovery point.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">scan_mode</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Malware scan mode for recovery points created by the backup rule
No scan action is configured when omitted.

**Allowed Values:**

- `FULL_SCAN`
- `INCREMENTAL_SCAN`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">start_within</td><td></td><td><code>"8 hours"</code></td>
</tr>
<tr><td colspan="4">

Specify period of time in which the backup plan starts if it doesn’t start at the specified time.
Use "<number> <unit>", with minute(s), hour(s), day(s), week(s), month(s), or year(s).
Months are 30 days and years are 365 days.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">time_zone</td><td></td><td><code>"Etc/UTC"</code></td>
</tr>
<tr><td colspan="4">

IANA time zone used to evaluate the backup schedule

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(object(<a href="#copy_to_destinations">copy_to_destinations</a>))</code></td>
    <td width="100%">copy_to_destinations</td><td></td><td><code>[]</code></td>
</tr>
<tr><td colspan="4">

Create a copy of backup in a separate backup vault or logically air-gapped vault.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#lifecycle">lifecycle</a>)</code></td>
    <td width="100%">lifecycle</td><td></td><td><code>null</code></td>
</tr>
<tr><td colspan="4">

Lifecycle settings for recovery points created by the backup rule

**Since:** 1.0.0

</td></tr>
</tbody></table>

<!-- TFDOCS_EXTRAS_END -->
