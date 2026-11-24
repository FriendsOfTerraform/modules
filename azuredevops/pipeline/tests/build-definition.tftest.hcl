mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }

  mock_data "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
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

run "azure_repos_source" {
  command = apply

  assert {
    condition     = length(azuredevops_build_definition.this.ci_trigger) == 0
    error_message = "An omitted CI configuration must leave ci_trigger unconfigured."
  }

  assert {
    condition     = azuredevops_build_definition.this.queue_status == "enabled"
    error_message = "The pipeline must be enabled by default."
  }

  assert {
    condition = (
      data.azuredevops_project.this.name == var.project_name &&
      data.azuredevops_git_repository.source[0].project_id == data.azuredevops_project.this.id &&
      data.azuredevops_git_repository.source[0].name == "Example Repository" &&
      azuredevops_build_definition.this.project_id == data.azuredevops_project.this.id &&
      azuredevops_build_definition.this.name == var.name &&
      azuredevops_build_definition.this.repository[0].repo_type == "TfsGit" &&
      azuredevops_build_definition.this.repository[0].repo_id == data.azuredevops_git_repository.source[0].id &&
      azuredevops_build_definition.this.repository[0].branch_name == "main" &&
      azuredevops_build_definition.this.repository[0].yml_path == "pipelines/ci.yml"
    )
    error_message = "The pipeline must resolve its project and Azure Repos repository by name and forward the source settings."
  }
}

run "disabled_status" {
  command = apply
  variables { status = "disabled" }
  assert {
    condition     = azuredevops_build_definition.this.queue_status == "disabled"
    error_message = "Disabled status must be forwarded to the pipeline queue status."
  }
}

run "paused_status" {
  command = apply
  variables { status = "paused" }
  assert {
    condition     = azuredevops_build_definition.this.queue_status == "paused"
    error_message = "Paused status must be forwarded to the pipeline queue status."
  }
}

run "enabled_status" {
  command = apply
  variables { status = "enabled" }
  assert {
    condition     = azuredevops_build_definition.this.queue_status == "enabled"
    error_message = "Enabled status must be forwarded to the pipeline queue status."
  }
}

run "reject_invalid_status" {
  command = plan
  variables { status = "invalid" }
  expect_failures = [var.status]
}

run "reject_null_status" {
  command = plan
  variables { status = null }
  expect_failures = [var.status]
}

run "ci_filter_override" {
  command = apply
  variables {
    triggers = {
      continuous_integration = {
        branch_filters = {
          include = ["main", "release/*"]
          exclude = ["release/experimental/*"]
        }
        path_filters = {
          include = ["src/*"]
          exclude = ["src/docs/*"]
        }
        batch_changes_while_a_build_is_in_progress = true
      }
    }
  }
  assert {
    condition = (
      length(azuredevops_build_definition.this.ci_trigger) == 1 &&
      azuredevops_build_definition.this.ci_trigger[0].use_yaml == null &&
      length(azuredevops_build_definition.this.ci_trigger[0].override) == 1 &&
      azuredevops_build_definition.this.ci_trigger[0].override[0].batch &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).include == toset(["main", "release/*"]) &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).exclude == toset(["release/experimental/*"]) &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].path_filter).include == toset(["src/*"]) &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].path_filter).exclude == toset(["src/docs/*"])
    )
    error_message = "Enabled CI must forward batching and all branch/path filters through the Terraform override."
  }
}

run "ci_default_options" {
  command = apply
  variables {
    triggers = { continuous_integration = { branch_filters = { include = ["main"] } } }
  }
  assert {
    condition = (
      !azuredevops_build_definition.this.ci_trigger[0].override[0].batch &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).include == toset(["main"]) &&
      length(one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).exclude) == 0 &&
      length(azuredevops_build_definition.this.ci_trigger[0].override[0].path_filter) == 0
    )
    error_message = "CI defaults must disable batching and omit an empty path filter."
  }
}

run "disabled_ci_excludes_every_branch" {
  command = apply
  variables {
    triggers = {
      continuous_integration = {
        enable_continuous_integration = false
        branch_filters                = { include = ["main"], exclude = ["dev"] }
        path_filters                  = { include = ["src/*"] }
      }
    }
  }
  assert {
    condition = (
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).include == toset(["*"]) &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).exclude == toset(["*"]) &&
      length(azuredevops_build_definition.this.ci_trigger[0].override[0].path_filter) == 0
    )
    error_message = "Disabled CI must replace configured branch filters with include/exclude all and omit path filters."
  }
}

run "ci_reenabled_after_disable" {
  command = apply
  variables {
    triggers = {
      continuous_integration = {
        branch_filters = { include = ["main"] }
        path_filters   = { exclude = ["docs/*"] }
      }
    }
  }
  assert {
    condition = (
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).include == toset(["main"]) &&
      length(one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).exclude) == 0 &&
      one(azuredevops_build_definition.this.ci_trigger[0].override[0].path_filter).exclude == toset(["docs/*"])
    )
    error_message = "Re-enabling CI must remove the exclude-all filter and restore configured filters."
  }
}

run "ci_empty_branch_filters" {
  command = apply
  variables { triggers = { continuous_integration = { branch_filters = {} } } }
  assert {
    condition = (
      length(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter) == 1 &&
      length(one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).include) == 0 &&
      length(one(azuredevops_build_definition.this.ci_trigger[0].override[0].branch_filter).exclude) == 0
    )
    error_message = "Empty configured branch filter lists must be forwarded without inventing a wildcard."
  }
}

run "null_ci_ignores_other_triggers" {
  command = apply
  variables { triggers = {} }
  assert {
    condition     = length(azuredevops_build_definition.this.ci_trigger) == 0
    error_message = "An empty triggers object must leave CI unconfigured."
  }
}

run "reject_null_ci_branch_filters" {
  command = plan
  variables { triggers = { continuous_integration = { branch_filters = null } } }
  expect_failures = [var.triggers]
}

run "reject_invalid_ci_filter" {
  command = plan
  variables { triggers = { continuous_integration = { branch_filters = { include = [" "] } } } }
  expect_failures = [var.triggers]
}

run "reject_null_ci_path_filter_entry" {
  command = plan
  variables { triggers = { continuous_integration = { branch_filters = {}, path_filters = { exclude = [null] } } } }
  expect_failures = [var.triggers]
}

run "full_branch_ref" {
  command = apply
  variables {
    yaml_source = {
      azure_repo_git = {
        repository = "Example Repository"
        branch     = "refs/heads/release/v1"
        path       = "/azure-pipelines.yml"
      }
    }
  }
  assert {
    condition = (
      azuredevops_build_definition.this.repository[0].branch_name == "refs/heads/release/v1" &&
      azuredevops_build_definition.this.repository[0].yml_path == "/azure-pipelines.yml"
    )
    error_message = "Full branch refs and YAML paths must be passed through unchanged."
  }
}

run "reject_missing_source" {
  command = plan
  variables { yaml_source = {} }
  expect_failures = [var.yaml_source]
}

run "reject_blank_repository" {
  command = plan
  variables { yaml_source = { azure_repo_git = { repository = "", branch = "main", path = "ci.yml" } } }
  expect_failures = [var.yaml_source]
}

run "reject_blank_branch" {
  command = plan
  variables { yaml_source = { azure_repo_git = { repository = "repo", branch = " ", path = "ci.yml" } } }
  expect_failures = [var.yaml_source]
}

run "reject_blank_yaml_path" {
  command = plan
  variables { yaml_source = { azure_repo_git = { repository = "repo", branch = "main", path = "" } } }
  expect_failures = [var.yaml_source]
}

run "reject_null_field" {
  command = plan
  variables { yaml_source = { azure_repo_git = { repository = null, branch = "main", path = "ci.yml" } } }
  expect_failures = [var.yaml_source]
}

run "reject_surrounding_whitespace" {
  command = plan
  variables { yaml_source = { azure_repo_git = { repository = "repo", branch = " main ", path = "ci.yml" } } }
  expect_failures = [var.yaml_source]
}
