locals {
  build_validations = flatten([
    for branch_name, branch in var.branches : [
      for build_validation_name, build_validation_config in branch.build_validations : {
        name                    = build_validation_name
        branch_name             = branch_name
        build_validation_config = build_validation_config
        build_pipeline_name     = build_validation_config.build_pipeline_name == null ? build_validation_name : build_validation_config.build_pipeline_name
        valid_duration = build_validation_config.build_expires_after == null ? 0 : (
          build_validation_config.build_expires_after == "immediately" ? 0 :
          tonumber(regex("^([0-9]+)", trimspace(build_validation_config.build_expires_after))[0]) *
          local.time_table_in_minutes[coalesce(regex("^([0-9]+)(?:[[:space:]]+(second|minute|hour|day|week|month|year)s?)?$", trimspace(build_validation_config.build_expires_after))[1], "minute")]
        )
      }
    ]
  ])
}

data "azuredevops_build_definition" "validation" {
  for_each = toset([
    for validation in local.build_validations : validation.build_pipeline_name
  ])

  project_id = data.azuredevops_project.this.id
  name       = each.value
}

resource "azuredevops_branch_policy_build_validation" "exact_rules" {
  for_each = {
    for validation in local.build_validations : "${validation.branch_name}_${validation.name}" => {
      name                    = validation.name
      branch_name             = validation.branch_name
      build_validation_config = validation.build_validation_config
      build_pipeline_name     = validation.build_pipeline_name
      valid_duration          = validation.valid_duration
    }
    if !endswith(validation.branch_name, "*")
  }

  project_id = data.azuredevops_project.this.id
  enabled    = each.value.build_validation_config.enabled
  blocking   = each.value.build_validation_config.policy_requirement == "required"

  lifecycle {
    precondition {
      condition     = each.value.build_validation_config.trigger != "manual" || each.value.valid_duration <= 527040
      error_message = "Manual build validations must have an expiration duration of at most 527040 minutes (366 days)."
    }
  }

  settings {
    build_definition_id         = data.azuredevops_build_definition.validation[each.value.build_pipeline_name].id
    queue_on_source_update_only = each.value.build_validation_config.build_expires_after != "immediately"
    manual_queue_only           = each.value.build_validation_config.trigger == "manual"
    display_name                = each.value.name
    valid_duration              = each.value.valid_duration
    filename_patterns           = each.value.build_validation_config.path_filters

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(each.value.branch_name, "refs/heads/")}"
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_build_validation" "prefix_rules" {
  for_each = {
    for validation in local.build_validations : "${validation.branch_name}_${validation.name}" => {
      name                    = validation.name
      branch_name             = validation.branch_name
      build_validation_config = validation.build_validation_config
      build_pipeline_name     = validation.build_pipeline_name
      valid_duration          = validation.valid_duration
    }
    if endswith(validation.branch_name, "*")
  }
  project_id = data.azuredevops_project.this.id
  enabled    = each.value.build_validation_config.enabled
  blocking   = each.value.build_validation_config.policy_requirement == "required"

  lifecycle {
    precondition {
      condition     = each.value.build_validation_config.trigger != "manual" || each.value.valid_duration <= 527040
      error_message = "Manual build validations must have an expiration duration of at most 527040 minutes (366 days)."
    }
  }

  settings {
    build_definition_id         = data.azuredevops_build_definition.validation[each.value.build_pipeline_name].id
    queue_on_source_update_only = each.value.build_validation_config.build_expires_after != "immediately"
    manual_queue_only           = each.value.build_validation_config.trigger == "manual"
    display_name                = each.value.name
    valid_duration              = each.value.valid_duration
    filename_patterns           = each.value.build_validation_config.path_filters

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(trimsuffix(each.value.branch_name, "*"), "refs/heads/")}"
      match_type     = "Prefix"
    }
  }
}
