locals {
  protected_resource_selections = flatten([
    for plan_name, plan_value in var.restore_testing_plans : [
      for selection_name, selection_value in plan_value.protected_resource_selections : merge(
        {
          plan_name      = plan_name
          selection_name = selection_name
        },
        selection_value
      )
    ]
  ])
}

resource "aws_backup_restore_testing_selection" "this" {
  for_each = { for selection in local.protected_resource_selections : "${selection.plan_name}/${selection.selection_name}" => selection }

  iam_role_arn              = each.value.restore_iam_role_arn
  name                      = each.value.selection_name
  protected_resource_type   = each.value.resource_type
  restore_testing_plan_name = aws_backup_restore_testing_plan.this[each.value.plan_name].name

  protected_resource_arns    = each.value.resource_arns != null ? each.value.resource_arns : null
  restore_metadata_overrides = each.value.restore_parameters_override
  validation_window_hours    = each.value.retention_period_before_cleanup != null ? split(" ", each.value.retention_period_before_cleanup)[0] * local.time_table_in_hours[trimsuffix(split(" ", each.value.retention_period_before_cleanup)[1], "s")] : null

  dynamic "protected_resource_conditions" {
    for_each = length(each.value.conditions) > 0 ? [each.value.conditions] : []

    content {
      dynamic "string_equals" {
        for_each = [for condition in each.value.conditions : condition if split(" ", condition)[1] == "=="]

        content {
          key   = split(" ", string_equals.value)[0]
          value = split(" ", string_equals.value)[2]
        }
      }

      dynamic "string_not_equals" {
        for_each = [for condition in each.value.conditions : condition if split(" ", condition)[1] == "!="]

        content {
          key   = split(" ", string_not_equals.value)[0]
          value = split(" ", string_not_equals.value)[2]
        }
      }
    }
  }
}
