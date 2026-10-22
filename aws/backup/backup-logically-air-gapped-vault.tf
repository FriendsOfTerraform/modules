resource "aws_backup_logically_air_gapped_vault" "this" {
  count = var.vault_type == "logically_air_gapped" ? 1 : 0

  max_retention_days = split(" ", var.maximum_retention_period)[0] * local.time_table_in_days[trimsuffix(split(" ", var.maximum_retention_period)[1], "s")]
  min_retention_days = split(" ", var.minimum_retention_period)[0] * local.time_table_in_days[trimsuffix(split(" ", var.minimum_retention_period)[1], "s")]
  name               = var.name

  encryption_key_arn = var.encryption_key_arn
  tags               = merge(local.common_tags, var.additional_tags_all, var.additional_tags)

  lifecycle {
    precondition {
      condition     = var.enable_vault_lock == null
      error_message = "enable_vault_lock is only supported for standard vaults. Logically air-gapped vaults are locked using minimum_retention_period and maximum_retention_period."
    }
  }
}
