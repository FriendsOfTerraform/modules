data "azuredevops_git_repository" "source" {
  count = var.yaml_source.azure_repo_git == null ? 0 : 1

  project_id = data.azuredevops_project.this.id
  name       = var.yaml_source.azure_repo_git.repository
}

data "azuredevops_build_definition" "upstream" {
  for_each = var.triggers == null ? {} : (
    var.triggers.build_completion == null ? {} : {
      for name, trigger in var.triggers.build_completion : name => trigger if trigger != null
    }
  )

  project_id = data.azuredevops_project.this.id
  name       = each.key
  path       = each.value.path
}

data "azuredevops_variable_group" "pipeline" {
  for_each = var.variables == null ? toset([]) : toset([
    for name in var.variables.variable_groups : name if name != null
  ])

  project_id = data.azuredevops_project.this.id
  name       = each.key
}

locals {
  scheduled_triggers = var.triggers == null ? {} : (
    var.triggers.scheduled == null ? {} : {
      for name, schedule in var.triggers.scheduled : name => {
        config = schedule
        time_12h = regexall(
          "^(0?[1-9]|1[0-2]):([0-5][0-9])[ ]*([aApP][mM])$",
          schedule.start_time == null ? "" : schedule.start_time
        )
        time_24h = regexall(
          "^([01][0-9]|2[0-3]):?([0-5][0-9])$",
          schedule.start_time == null ? "" : schedule.start_time
        )
      } if schedule != null
    }
  )
}

resource "azuredevops_build_definition" "this" {
  project_id   = data.azuredevops_project.this.id
  name         = var.name
  queue_status = var.status

  variable_groups = length(data.azuredevops_variable_group.pipeline) == 0 ? null : [
    for group in data.azuredevops_variable_group.pipeline : tonumber(group.id)
  ]

  dynamic "variable" {
    for_each = var.variables == null ? {} : {
      for name, config in var.variables.pipeline_variables : name => config if config != null
    }

    content {
      name           = variable.key
      value          = variable.value.value
      allow_override = variable.value.allow_override
      is_secret      = false
    }
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = var.yaml_source.azure_repo_git == null ? null : data.azuredevops_git_repository.source[0].id
    branch_name = var.yaml_source.azure_repo_git == null ? null : var.yaml_source.azure_repo_git.branch
    yml_path    = var.yaml_source.azure_repo_git == null ? null : var.yaml_source.azure_repo_git.path
  }

  dynamic "ci_trigger" {
    for_each = var.triggers == null ? [] : (
      var.triggers.continuous_integration == null ? [] : [var.triggers.continuous_integration]
    )

    content {
      override {
        batch = ci_trigger.value.batch_changes_while_a_build_is_in_progress

        branch_filter {
          include = ci_trigger.value.enable_continuous_integration ? ci_trigger.value.branch_filters.include : ["*"]
          exclude = ci_trigger.value.enable_continuous_integration ? ci_trigger.value.branch_filters.exclude : ["*"]
        }

        dynamic "path_filter" {
          for_each = ci_trigger.value.enable_continuous_integration && (
            length(ci_trigger.value.path_filters.include) + length(ci_trigger.value.path_filters.exclude) > 0
          ) ? [ci_trigger.value.path_filters] : []

          content {
            include = path_filter.value.include
            exclude = path_filter.value.exclude
          }
        }

      }
    }
  }

  dynamic "schedules" {
    for_each = local.scheduled_triggers

    content {
      days_to_build              = schedules.value.config.days_to_build
      schedule_only_with_changes = schedules.value.config.only_schedule_builds_if_the_source_or_pipeline_has_changed
      time_zone                  = schedules.value.config.time_zone

      start_hours = length(schedules.value.time_12h) > 0 ? (
        tonumber(schedules.value.time_12h[0][0]) % 12 +
        (lower(schedules.value.time_12h[0][2]) == "pm" ? 12 : 0)
      ) : length(schedules.value.time_24h) > 0 ? tonumber(schedules.value.time_24h[0][0]) : null
      start_minutes = length(schedules.value.time_12h) > 0 ? (
        tonumber(schedules.value.time_12h[0][1])
      ) : length(schedules.value.time_24h) > 0 ? tonumber(schedules.value.time_24h[0][1]) : null

      branch_filter {
        include = schedules.value.config.branch_filters == null ? null : schedules.value.config.branch_filters.include
        exclude = schedules.value.config.branch_filters == null ? null : schedules.value.config.branch_filters.exclude
      }

    }
  }

  dynamic "build_completion_trigger" {
    for_each = data.azuredevops_build_definition.upstream

    content {
      build_definition_id = build_completion_trigger.value.id

      branch_filter {
        include = var.triggers.build_completion[build_completion_trigger.key].branch_filters == null ? null : var.triggers.build_completion[build_completion_trigger.key].branch_filters.include
        exclude = var.triggers.build_completion[build_completion_trigger.key].branch_filters == null ? null : var.triggers.build_completion[build_completion_trigger.key].branch_filters.exclude
      }
    }
  }
}
