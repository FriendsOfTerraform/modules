mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }
  mock_data "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
  }
  mock_data "azuredevops_build_definition" {
    defaults = { id = "42" }
  }
}

variables {
  name         = "Downstream"
  project_name = "Example Project"
  yaml_source = {
    azure_repo_git = {
      repository = "Example Repository"
      branch     = "main"
      path       = "pipelines/ci.yml"
    }
  }
}

run "omitted_triggers" {
  command = apply
  assert {
    condition     = length(azuredevops_build_definition.this.build_completion_trigger) == 0 && length(data.azuredevops_build_definition.upstream) == 0
    error_message = "Omitting triggers must not look up or configure upstream pipelines."
  }
}

run "empty_triggers" {
  command = apply
  variables { triggers = { build_completion = {} } }
  assert {
    condition     = length(azuredevops_build_definition.this.build_completion_trigger) == 0 && length(data.azuredevops_build_definition.upstream) == 0
    error_message = "An empty map must not configure build completion triggers."
  }
}

run "multiple_upstream_pipelines" {
  command = apply
  override_data {
    target = data.azuredevops_build_definition.upstream["Build B"]
    values = { id = "84" }
  }
  variables {
    triggers = {
      build_completion = {
        "Build A" = { branch_filters = { include = ["main", "release/*"], exclude = ["release/test"] } }
        "Build B" = { path = "\\Products", branch_filters = {} }
      }
      continuous_integration = { branch_filters = { include = ["main"] } }
      scheduled              = { daily = { days_to_build = ["Mon"], start_time = "0900", branch_filters = {} } }
    }
  }
  assert {
    condition = (
      length(data.azuredevops_build_definition.upstream) == 2 &&
      data.azuredevops_build_definition.upstream["Build A"].project_id == data.azuredevops_project.this.id &&
      data.azuredevops_build_definition.upstream["Build A"].name == "Build A" &&
      data.azuredevops_build_definition.upstream["Build A"].path == "\\" &&
      data.azuredevops_build_definition.upstream["Build B"].name == "Build B" &&
      data.azuredevops_build_definition.upstream["Build B"].path == "\\Products" &&
      length(azuredevops_build_definition.this.build_completion_trigger) == 2 &&
      azuredevops_build_definition.this.build_completion_trigger[0].build_definition_id == 42 &&
      one(azuredevops_build_definition.this.build_completion_trigger[0].branch_filter).include == toset(["main", "release/*"]) &&
      one(azuredevops_build_definition.this.build_completion_trigger[0].branch_filter).exclude == toset(["release/test"]) &&
      azuredevops_build_definition.this.build_completion_trigger[1].build_definition_id == 84 &&
      length(one(azuredevops_build_definition.this.build_completion_trigger[1].branch_filter).include) == 0 &&
      length(one(azuredevops_build_definition.this.build_completion_trigger[1].branch_filter).exclude) == 0 &&
      length(azuredevops_build_definition.this.ci_trigger) == 1 &&
      length(azuredevops_build_definition.this.schedules) == 1
    )
    error_message = "Lookups and branch filters must be forwarded for each upstream pipeline alongside other trigger types."
  }
}

run "remove_upstream_pipelines" {
  command = apply
  variables { triggers = { build_completion = null } }
  assert {
    condition     = length(azuredevops_build_definition.this.build_completion_trigger) == 0 && length(data.azuredevops_build_definition.upstream) == 0
    error_message = "Removing the map must remove all build completion triggers and lookups."
  }
}

run "reject_null_entry" {
  command = plan
  variables { triggers = { build_completion = { "Build" = null } } }
  expect_failures = [var.triggers]
}

run "reject_blank_name" {
  command = plan
  variables { triggers = { build_completion = { " " = { branch_filters = {} } } } }
  expect_failures = [var.triggers]
}

run "reject_null_branch_filters" {
  command = plan
  variables { triggers = { build_completion = { "Build" = { branch_filters = null } } } }
  expect_failures = [var.triggers]
}

run "reject_invalid_filter" {
  command = plan
  variables { triggers = { build_completion = { "Build" = { branch_filters = { exclude = [" main "] } } } } }
  expect_failures = [var.triggers]
}

run "reject_null_filter" {
  command = plan
  variables { triggers = { build_completion = { "Build" = { branch_filters = { include = [null] } } } } }
  expect_failures = [var.triggers]
}
