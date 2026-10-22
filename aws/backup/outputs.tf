output "backup_plans" {
  value = { for k, v in aws_backup_plan.this : k => {
    arn     = v.arn
    id      = v.id
    version = v.version
  } }

  description = <<EOT
    Attributes of all backup plans managed by this module. The key of the map is the backup plan name.

    @type map(object({
      /// The ARN of the backup plan
      ///
      /// @since 1.0.0
      arn = string

      /// The ID of the backup plan
      ///
      /// @since 1.0.0
      id = string

      /// Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan
      ///
      /// @since 1.0.0
      version = string
    }))
    @since 1.0.0
  EOT
}

output "backup_vault_arn" {
  value = local.vault_arn

  description = <<EOT
    The ARN of the backup vault

    @type string
    @since 1.0.0
  EOT
}

output "backup_vault_name" {
  value = local.vault_name

  description = <<EOT
    The name of the backup vault

    @type string
    @since 1.0.0
  EOT
}

output "backup_vault_recovery_points" {
  value = one(aws_backup_vault.this[*].recovery_points)

  description = <<EOT
    The number of recovery points stored in the backup vault. Only applicable to standard vaults; `null` for logically air-gapped vaults.

    @type number
    @since 1.0.0
  EOT
}

output "restore_testing_plans" {
  value = { for k, v in aws_backup_restore_testing_plan.this : k => {
    arn = v.arn
  } }

  description = <<EOT
    Attributes of all restore testing plans managed by this module. The key of the map is the restore testing plan name.

    @type map(object({
      /// The ARN of the restore testing plan
      ///
      /// @since 1.0.0
      arn = string
    }))
    @since 1.0.0
  EOT
}
