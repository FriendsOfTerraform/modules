resource "aws_backup_restore_testing_plan" "this" {
  for_each = var.restore_testing_plans

  name                = each.key
  schedule_expression = each.value.test_frequency_cron_expression

  schedule_expression_timezone = each.value.time_zone
  start_window_hours           = split(" ", each.value.start_within)[0] * local.time_table_in_hours[trimsuffix(split(" ", each.value.start_within)[1], "s")]
  tags                         = merge(local.common_tags, each.value.additional_tags, var.additional_tags_all)

  recovery_point_selection {
    algorithm            = "${each.value.eligible_recovery_points_selection.algorithm}_WITHIN_WINDOW"
    include_vaults       = [local.vault_arn]
    recovery_point_types = each.value.eligible_recovery_points_selection.include_point_in_time_recovery_points ? ["CONTINUOUS"] : ["SNAPSHOT"]

    selection_window_days = split(" ", each.value.eligible_recovery_points_selection.window)[0] * local.time_table_in_days[trimsuffix(split(" ", each.value.eligible_recovery_points_selection.window)[1], "s")]
  }
}
