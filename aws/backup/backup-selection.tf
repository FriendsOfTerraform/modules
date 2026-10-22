locals {
  resource_assignments = flatten([
    for plan_name, plan in var.backup_plans : [
      for assignment_name, assignment in plan.resource_assignments : merge(
        {
          assignment_name = assignment_name
          plan_name       = plan_name
        },
        assignment
      )
    ]
  ])
}

resource "aws_backup_selection" "this" {
  for_each = { for assignment in local.resource_assignments : "${assignment.plan_name}/${assignment.assignment_name}" => assignment }

  iam_role_arn = each.value.iam_role_arn
  name         = each.value.assignment_name
  plan_id      = aws_backup_plan.this[each.value.plan_name].id

  not_resources = each.value.not_resources
  resources     = each.value.resources

  dynamic "condition" {
    for_each = length(each.value.conditions) > 0 ? [each.value.conditions] : []

    content {
      dynamic "string_equals" {
        for_each = [for condition in each.value.conditions : condition if split(" ", condition)[1] == "=="]

        content {
          key   = split(" ", string_equals.value)[0]
          value = split(" ", string_equals.value)[2]
        }
      }

      dynamic "string_like" {
        for_each = [for condition in each.value.conditions : condition if lower(split(" ", condition)[1]) == "like"]

        content {
          key   = split(" ", string_like.value)[0]
          value = split(" ", string_like.value)[2]
        }
      }

      dynamic "string_not_equals" {
        for_each = [for condition in each.value.conditions : condition if split(" ", condition)[1] == "!="]

        content {
          key   = split(" ", string_not_equals.value)[0]
          value = split(" ", string_not_equals.value)[2]
        }
      }

      dynamic "string_not_like" {
        for_each = [for condition in each.value.conditions : condition if lower(split(" ", condition)[1]) == "notlike"]

        content {
          key   = split(" ", string_not_like.value)[0]
          value = split(" ", string_not_like.value)[2]
        }
      }
    }
  }
}
