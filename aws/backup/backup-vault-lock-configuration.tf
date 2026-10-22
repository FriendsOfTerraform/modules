resource "aws_backup_vault_lock_configuration" "this" {
  count = var.enable_vault_lock != null && var.vault_type == "standard" ? 1 : 0

  backup_vault_name = aws_backup_vault.this[0].name

  changeable_for_days = var.enable_vault_lock.compliance_mode != null ? split(" ", var.enable_vault_lock.compliance_mode.start_after)[0] * local.time_table_in_days[trimsuffix(split(" ", var.enable_vault_lock.compliance_mode.start_after)[1], "s")] : null
  max_retention_days  = var.enable_vault_lock.maximum_retention_period != null ? split(" ", var.enable_vault_lock.maximum_retention_period)[0] * local.time_table_in_days[trimsuffix(split(" ", var.enable_vault_lock.maximum_retention_period)[1], "s")] : null
  min_retention_days  = split(" ", var.enable_vault_lock.minimum_retention_period)[0] * local.time_table_in_days[trimsuffix(split(" ", var.enable_vault_lock.minimum_retention_period)[1], "s")]
}
