mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }
  mock_data "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
  }
}

variables {
  name         = "Schedule Tests"
  project_name = "Example Project"
  yaml_source = {
    azure_repo_git = { repository = "Example Repository", branch = "main", path = "ci.yml" }
  }
}

run "no_schedules" {
  command = apply
  assert {
    condition     = length(azuredevops_build_definition.this.schedules) == 0
    error_message = "Null triggers must not configure schedules."
  }
}

run "empty_schedules" {
  command = apply
  variables { triggers = { scheduled = {} } }
  assert {
    condition     = length(azuredevops_build_definition.this.schedules) == 0
    error_message = "An empty schedule map must not configure schedules."
  }
}

run "schedule_with_ci" {
  command = apply
  variables {
    triggers = {
      continuous_integration = { branch_filters = { include = ["main"] } }
      scheduled = {
        daily = { start_time = "0900", days_to_build = ["Mon", "Tue"], branch_filters = { include = ["main"] } }
      }
    }
  }
  assert {
    condition = (
      length(azuredevops_build_definition.this.ci_trigger) == 1 &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).include == toset(["main"]) &&
      length(azuredevops_build_definition.this.schedules) == 1 &&
      azuredevops_build_definition.this.schedules[0].start_hours == 9 &&
      azuredevops_build_definition.this.schedules[0].start_minutes == 0
    )
    error_message = "Schedules and existing CI trigger overrides must coexist independently."
  }
}

run "time_formats_and_settings" {
  command = apply
  variables {
    triggers = {
      scheduled = {
        a = { start_time = "1:00PM", days_to_build = ["Mon", "Wed"], branch_filters = { include = ["main"], exclude = ["dev"] }, time_zone = "(UTC-08:00) Pacific Time (US &Canada)", only_schedule_builds_if_the_source_or_pipeline_has_changed = false }
        b = { start_time = "12:00 AM", days_to_build = ["Tue"], branch_filters = { include = ["release/*"] } }
        c = { start_time = "00:00", days_to_build = ["Wed"], branch_filters = {} }
        d = { start_time = "0000", days_to_build = ["Thu"], branch_filters = {} }
        e = { start_time = "12:00PM", days_to_build = ["Fri"], branch_filters = {} }
        f = { start_time = "11:59 pm", days_to_build = ["Sat"], branch_filters = {} }
        g = { start_time = "23:59", days_to_build = ["Sun"], branch_filters = {} }
        h = { start_time = "2359", days_to_build = ["Mon"], branch_filters = {} }
        i = { start_time = "01:05am", days_to_build = ["Tue"], branch_filters = {} }
        j = { start_time = "07:09", days_to_build = ["Wed"], branch_filters = {} }
      }
    }
  }

  assert {
    condition = (
      length(azuredevops_build_definition.this.schedules) == 10 &&
      alltrue([
        for index, expected in [
          [13, 0], [0, 0], [0, 0], [0, 0], [12, 0],
          [23, 59], [23, 59], [23, 59], [1, 5], [7, 9]
        ] : azuredevops_build_definition.this.schedules[index].start_hours == expected[0] &&
        azuredevops_build_definition.this.schedules[index].start_minutes == expected[1]
      ])
    )
    error_message = "Schedules must convert all supported time formats, midnight, noon, leading zeroes, and boundary minutes."
  }

  assert {
    condition = (
      azuredevops_build_definition.this.schedules[0].days_to_build == tolist(["Mon", "Wed"]) &&
      azuredevops_build_definition.this.schedules[0].time_zone == "(UTC-08:00) Pacific Time (US &Canada)" &&
      !azuredevops_build_definition.this.schedules[0].schedule_only_with_changes &&
      one(azuredevops_build_definition.this.schedules[0].branch_filter).include == toset(["main"]) &&
      one(azuredevops_build_definition.this.schedules[0].branch_filter).exclude == toset(["dev"]) &&
      azuredevops_build_definition.this.schedules[1].time_zone == "(UTC) Coordinated Universal Time" &&
      azuredevops_build_definition.this.schedules[1].schedule_only_with_changes &&
      one(azuredevops_build_definition.this.schedules[1].branch_filter).include == toset(["release/*"])
    )
    error_message = "Schedules must forward days, time zone, changes-only settings, and branch filters, including defaults."
  }
}

run "reject_out_of_range_24h" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "24:00", days_to_build = ["Mon"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_out_of_range_12h" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "13:00PM", days_to_build = ["Mon"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_zero_12h" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "0:00AM", days_to_build = ["Mon"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_invalid_minutes" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "12:60 AM", days_to_build = ["Mon"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_invalid_format" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "1:00", days_to_build = ["Mon"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_null_time" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = null, days_to_build = ["Mon"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_invalid_days" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "0000", days_to_build = ["Monday"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_duplicate_days" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "0000", days_to_build = ["Mon", "Mon"], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_empty_days" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "0000", days_to_build = [], branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_null_schedule" {
  command = plan
  variables { triggers = { scheduled = { bad = null } } }
  expect_failures = [var.triggers]
}

run "reject_null_branch_filters" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "0000", days_to_build = ["Mon"], branch_filters = null } } } }
  expect_failures = [var.triggers]
}

run "reject_blank_filter" {
  command = plan
  variables { triggers = { scheduled = { bad = { start_time = "0000", days_to_build = ["Mon"], branch_filters = { exclude = [" "] } } } } }
  expect_failures = [var.triggers]
}
