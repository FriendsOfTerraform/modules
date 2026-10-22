locals {
  rules = flatten([
    for plan_name, plan in var.backup_plans : [
      for rule_name, rule in plan.rules : merge({ plan_name = plan_name, rule_name = rule_name }, rule)
  ]])
}

resource "aws_backup_plan" "this" {
  for_each = var.backup_plans

  name = each.key

  tags = merge(local.common_tags, var.additional_tags_all, each.value.additional_tags)

  dynamic "rule" {
    for_each = [for r in local.rules : r if r.plan_name == each.key]

    content {
      rule_name         = rule.value.rule_name
      target_vault_name = var.vault_type == "standard" ? aws_backup_vault.this[0].name : "Default"

      completion_window                            = split(" ", rule.value.complete_within)[0] * local.time_table_in_minutes[trimsuffix(split(" ", rule.value.complete_within)[1], "s")]
      enable_continuous_backup                     = rule.value.enable_continuous_backups_for_point_in_time_recovery
      recovery_point_tags                          = rule.value.recovery_point_tags
      schedule                                     = rule.value.backup_frequency_cron_expression
      schedule_expression_timezone                 = rule.value.time_zone
      start_window                                 = split(" ", rule.value.start_within)[0] * local.time_table_in_minutes[trimsuffix(split(" ", rule.value.start_within)[1], "s")]
      target_logically_air_gapped_backup_vault_arn = var.vault_type == "logically_air_gapped" ? aws_backup_logically_air_gapped_vault.this[0].arn : null

      dynamic "copy_action" {
        for_each = rule.value.copy_to_destinations

        content {
          destination_vault_arn = copy_action.value.destination_vault_arn

          dynamic "lifecycle" {
            for_each = copy_action.value.lifecycle != null ? [copy_action.value.lifecycle] : []

            content {
              cold_storage_after = lifecycle.value.move_backups_from_warm_to_cold_storage_after != null ? split(" ", lifecycle.value.move_backups_from_warm_to_cold_storage_after)[0] * local.time_table_in_days[trimsuffix(split(" ", lifecycle.value.move_backups_from_warm_to_cold_storage_after)[1], "s")] : null
              delete_after       = split(" ", lifecycle.value.total_retention_period)[0] * local.time_table_in_days[trimsuffix(split(" ", lifecycle.value.total_retention_period)[1], "s")]
            }
          }
        }
      }

      dynamic "lifecycle" {
        for_each = rule.value.lifecycle != null ? [rule.value.lifecycle] : []
        content {
          cold_storage_after = lifecycle.value.move_backups_from_warm_to_cold_storage_after != null ? split(" ", lifecycle.value.move_backups_from_warm_to_cold_storage_after)[0] * local.time_table_in_days[trimsuffix(split(" ", lifecycle.value.move_backups_from_warm_to_cold_storage_after)[1], "s")] : null
          delete_after       = split(" ", lifecycle.value.total_retention_period)[0] * local.time_table_in_days[trimsuffix(split(" ", lifecycle.value.total_retention_period)[1], "s")]
        }
      }

      dynamic "scan_action" {
        for_each = rule.value.scan_mode != null ? [rule.value.scan_mode] : []

        content {
          malware_scanner = "GUARDDUTY"
          scan_mode       = scan_action.value
        }
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = each.value.advanced_backup_settings.application_consistent_backup.windows_vss ? [1] : []

    content {
      resource_type = "EC2"

      backup_options = {
        WindowsVSS = "enabled"
      }
    }
  }

  dynamic "scan_setting" {
    for_each = each.value.enable_malware_scans != null ? [each.value.enable_malware_scans] : []
    content {
      malware_scanner  = scan_setting.value.malware_scanner
      resource_types   = scan_setting.value.scannable_resource_types
      scanner_role_arn = scan_setting.value.scanner_role_arn
    }
  }
}
