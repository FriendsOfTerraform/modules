mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }
  mock_data "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
  }
  mock_data "azuredevops_variable_group" {
    defaults = { id = "12" }
  }
}

variables {
  name         = "Example Pipeline"
  project_name = "Example Project"
  yaml_source = {
    azure_repo_git = {
      repository = "Example Repository"
      branch     = "main"
      path       = "pipelines/ci.yml"
    }
  }
}

run "omitted_variables" {
  command = apply
  assert {
    condition = (
      length(azuredevops_build_definition.this.variable) == 0 &&
      azuredevops_build_definition.this.variable_groups == null &&
      length(data.azuredevops_variable_group.pipeline) == 0
    )
    error_message = "Omitted variables must not configure variables or variable groups."
  }
}

run "empty_variables" {
  command = apply
  variables { variables = {} }
  assert {
    condition = (
      length(azuredevops_build_definition.this.variable) == 0 &&
      azuredevops_build_definition.this.variable_groups == null
    )
    error_message = "Empty variables must not configure variables or groups."
  }
}

run "configured_variables" {
  command = apply
  override_data {
    target = data.azuredevops_variable_group.pipeline["Team B"]
    values = { id = "34" }
  }
  variables {
    variables = {
      pipeline_variables = {
        environment = { value = "production" }
        empty       = { value = "", allow_override = false }
      }
      variable_groups = ["Team A", "Team B", "Team A"]
    }
  }
  assert {
    condition = (
      length(azuredevops_build_definition.this.variable) == 2 &&
      { for v in azuredevops_build_definition.this.variable : v.name => v.value } == { environment = "production", empty = "" } &&
      { for v in azuredevops_build_definition.this.variable : v.name => v.allow_override } == { environment = true, empty = false } &&
      alltrue([for v in azuredevops_build_definition.this.variable : !v.is_secret]) &&
      length(data.azuredevops_variable_group.pipeline) == 2 &&
      data.azuredevops_variable_group.pipeline["Team A"].project_id == data.azuredevops_project.this.id &&
      data.azuredevops_variable_group.pipeline["Team A"].name == "Team A" &&
      data.azuredevops_variable_group.pipeline["Team B"].name == "Team B" &&
      azuredevops_build_definition.this.variable_groups == toset([12, 34])
    )
    error_message = "Pipeline variables and distinct resolved group IDs must be forwarded, including default and explicit override settings."
  }
}

run "remove_variables" {
  command = apply
  variables { variables = null }
  assert {
    condition = (
      length(azuredevops_build_definition.this.variable) == 0 &&
      azuredevops_build_definition.this.variable_groups == null &&
      length(data.azuredevops_variable_group.pipeline) == 0
    )
    error_message = "Removing variable inputs must remove configured blocks and lookups."
  }
}

run "reject_null_variable" {
  command = plan
  variables { variables = { pipeline_variables = { example = null } } }
  expect_failures = [var.variables]
}

run "reject_null_value" {
  command = plan
  variables { variables = { pipeline_variables = { example = { value = null } } } }
  expect_failures = [var.variables]
}

run "reject_blank_variable_name" {
  command = plan
  variables { variables = { pipeline_variables = { " " = { value = "ok" } } } }
  expect_failures = [var.variables]
}

run "reject_whitespace_variable_name" {
  command = plan
  variables { variables = { pipeline_variables = { " example" = { value = "ok" } } } }
  expect_failures = [var.variables]
}

run "reject_null_group_name" {
  command = plan
  variables { variables = { variable_groups = [null] } }
  expect_failures = [var.variables]
}

run "reject_blank_group_name" {
  command = plan
  variables { variables = { variable_groups = [" "] } }
  expect_failures = [var.variables]
}

run "reject_whitespace_group_name" {
  command = plan
  variables { variables = { variable_groups = [" Team A"] } }
  expect_failures = [var.variables]
}
