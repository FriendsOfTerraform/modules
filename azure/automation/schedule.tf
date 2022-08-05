locals {
  runbooks_with_set_schedule = {
    for name, runbook in var.runbooks : name => runbook if runbook.schedule != null
  }

  week_to_number = {
    "First"  = "1",
    "Second" = "2",
    "Third"  = "3",
    "Fourth" = "4",
    "Last"   = "-1"
  }
}

resource "azurerm_automation_schedule" "schedule" {
  for_each = local.runbooks_with_set_schedule

  name                    = "Schedule for ${each.key}"
  resource_group_name     = data.azurerm_resource_group.current.name
  automation_account_name = azurerm_automation_account.automation_account.name

  frequency = each.value.schedule.hourly != null ? "Hour" : (
    each.value.schedule.daily != null ? "Day" : (
      each.value.schedule.weekly != null ? "Week" : (
        each.value.schedule.monthly != null ? "Month" : "OneTime"
      )
    )
  )

  description = each.value.schedule.description

  interval = each.value.schedule.hourly != null ? each.value.schedule.hourly.interval : (
    each.value.schedule.daily != null ? each.value.schedule.daily.interval : (
      each.value.schedule.weekly != null ? each.value.schedule.weekly.interval : (
        each.value.schedule.monthly != null ? each.value.schedule.monthly.interval : null
      )
    )
  )

  timezone    = each.value.schedule.timezone
  start_time  = each.value.schedule.start_time
  expiry_time = each.value.schedule.expiry_time
  week_days   = each.value.schedule.weekly != null ? each.value.schedule.weekly.every : null

  month_days = each.value.schedule.monthly != null ? (
    length(each.value.schedule.monthly.every[0]) < 2 ? each.value.schedule.monthly.every : null
  ) : null

  dynamic "monthly_occurrence" {
    for_each = each.value.schedule.monthly != null ? (
      length(each.value.schedule.monthly.every[0]) > 2 ? [1] : []
    ) : []

    content {
      day        = each.value.schedule.monthly.every[1]
      occurrence = local.week_to_number[each.value.schedule.monthly.every[0]]
    }
  }
}

resource "azurerm_automation_job_schedule" "schedule_links" {
  for_each = local.runbooks_with_set_schedule

  resource_group_name     = data.azurerm_resource_group.current.name
  automation_account_name = azurerm_automation_account.automation_account.name
  runbook_name            = azurerm_automation_runbook.runbooks[each.key].name
  schedule_name           = azurerm_automation_schedule.schedule[each.key].name
  parameters              = each.value.schedule.parameters
}