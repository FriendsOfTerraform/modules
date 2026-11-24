mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }
  mock_resource "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
  }
}

variables {
  name           = "repository-tests"
  project_name   = "Example Project"
  default_branch = "main"
}

run "clean_repository" {
  command = apply

  assert {
    condition     = length(output.branches) == 0
    error_message = "The branches output must be empty when no branch resources are created."
  }

  assert {
    condition = (
      data.azuredevops_project.this.name == var.project_name &&
      azuredevops_git_repository.this.project_id == data.azuredevops_project.this.id &&
      azuredevops_git_repository.this.name == var.name &&
      !azuredevops_git_repository.this.disabled &&
      azuredevops_git_repository.this.default_branch == "refs/heads/main" &&
      azuredevops_git_repository.this.initialization[0].init_type == "Clean"
    )
    error_message = "Clean repositories must resolve the project, forward the name, remain enabled, and normalize the default branch."
  }

  assert {
    condition = (
      length(azuredevops_git_repository_branch.this) == 0 &&
      length(azuredevops_branch_policy_min_reviewers.exact_rules) == 0 &&
      length(azuredevops_branch_policy_min_reviewers.prefix_rules) == 0 &&
      length(azuredevops_branch_policy_merge_types.exact_rules) == 0 &&
      length(azuredevops_branch_policy_merge_types.prefix_rules) == 0 &&
      length(azuredevops_branch_policy_comment_resolution.exact_rules) == 0 &&
      length(azuredevops_branch_policy_comment_resolution.prefix_rules) == 0 &&
      length(azuredevops_branch_policy_work_item_linking.exact_rules) == 0 &&
      length(azuredevops_branch_policy_work_item_linking.prefix_rules) == 0 &&
      length(azuredevops_branch_policy_build_validation.exact_rules) == 0 &&
      length(azuredevops_branch_policy_build_validation.prefix_rules) == 0 &&
      length(azuredevops_branch_policy_auto_reviewers.exact_rules) == 0 &&
      length(azuredevops_branch_policy_auto_reviewers.prefix_rules) == 0 &&
      length(azuredevops_git_permissions.this) == 0
    )
    error_message = "An empty branches map must not create branches, policies, or permissions."
  }
}

run "import_repository" {
  command = apply
  variables {
    enabled        = false
    default_branch = "refs/heads/develop"
    import = {
      source_repo_url = "https://example.com/source.git"
      username        = "test-user"
      password        = "mock-only-password"
    }
  }
  assert {
    condition = (
      azuredevops_git_repository.this.disabled &&
      azuredevops_git_repository.this.default_branch == "refs/heads/develop" &&
      azuredevops_git_repository.this.initialization[0].init_type == "Import" &&
      azuredevops_git_repository.this.initialization[0].source_type == "Git" &&
      azuredevops_git_repository.this.initialization[0].source_url == var.import.source_repo_url &&
      azuredevops_git_repository.this.initialization[0].username == var.import.username &&
      azuredevops_git_repository.this.initialization[0].password == null
    )
    error_message = "Import must forward source URL and username, normalize the branch ref, and keep the write-only password out of state."
  }
}

run "import_with_service_connection" {
  command = apply
  variables {
    import = {
      source_repo_url       = "https://example.com/source.git"
      service_connection_id = "00000000-0000-0000-0000-000000000003"
    }
  }
  assert {
    condition = (
      azuredevops_git_repository.this.initialization[0].init_type == "Import" &&
      azuredevops_git_repository.this.initialization[0].source_url == var.import.source_repo_url &&
      azuredevops_git_repository.this.initialization[0].service_connection_id == var.import.service_connection_id
    )
    error_message = "Import must support service-connection authentication without credentials."
  }
}

run "fork_repository" {
  command = apply
  variables {
    fork = { parent_repository_id = "00000000-0000-0000-0000-000000000004" }
  }
  assert {
    condition = (
      azuredevops_git_repository.this.initialization[0].init_type == "Fork" &&
      azuredevops_git_repository.this.parent_repository_id == var.fork.parent_repository_id
    )
    error_message = "Fork initialization must use the supplied parent repository."
  }
}

run "branch_source_routing" {
  command = apply

  override_resource {
    target = azuredevops_git_repository_branch.this["refs/heads/develop"]
    values = {
      id             = "00000000-0000-0000-0000-000000000002:develop"
      last_commit_id = "0123456789abcdef0123456789abcdef01234567"
    }
  }

  variables {
    default_branch = "refs/heads/main"
    branches = {
      main                 = {}
      "release/*"          = {}
      default_source       = {}
      "refs/heads/develop" = {}
      named_source         = { based_on = "develop" }
      full_named_source    = { based_on = "refs/heads/develop" }
      default_named_source = { based_on = "main" }
      external_branch      = { based_on = "refs/heads/existing" }
      commit_source        = { based_on = "ABCDEF0123456789ABCDEF0123456789ABCDEF01" }
      tag_source           = { based_on = "v1.0.0" }
      short_sha_is_tag     = { based_on = "abcdef0" }
    }
  }

  assert {
    condition = (
      toset(keys(output.branches)) == toset(keys(azuredevops_git_repository_branch.this)) &&
      alltrue([
        for name, branch in azuredevops_git_repository_branch.this :
        toset(keys(output.branches[name])) == toset(["id", "last_commit_id"]) &&
        output.branches[name].id == branch.id &&
        output.branches[name].last_commit_id == branch.last_commit_id
      ]) &&
      output.branches["refs/heads/develop"].id == "00000000-0000-0000-0000-000000000002:develop" &&
      output.branches["refs/heads/develop"].last_commit_id == "0123456789abcdef0123456789abcdef01234567"
    )
    error_message = "The branches output must preserve input keys and expose exactly the ID and last commit ID of each created branch."
  }

  assert {
    condition = (
      length(azuredevops_git_repository_branch.this) == 9 &&
      !contains(keys(azuredevops_git_repository_branch.this), "main") &&
      !contains(keys(azuredevops_git_repository_branch.this), "release/*") &&
      azuredevops_git_repository_branch.this["refs/heads/develop"].name == "develop"
    )
    error_message = "Branch creation must omit the default and wildcard entries and normalize full-ref names."
  }

  assert {
    condition = (
      azuredevops_git_repository_branch.this["default_source"].ref_branch == "refs/heads/main" &&
      azuredevops_git_repository_branch.this["named_source"].ref_branch == "develop" &&
      azuredevops_git_repository_branch.this["full_named_source"].ref_branch == "develop" &&
      azuredevops_git_repository_branch.this["default_named_source"].ref_branch == "main" &&
      azuredevops_git_repository_branch.this["external_branch"].ref_branch == "existing" &&
      azuredevops_git_repository_branch.this["commit_source"].ref_commit_id == var.branches.commit_source.based_on &&
      azuredevops_git_repository_branch.this["tag_source"].ref_tag == "v1.0.0" &&
      azuredevops_git_repository_branch.this["short_sha_is_tag"].ref_tag == "abcdef0"
    )
    error_message = "Branch sources must select default, named or external branch, full SHA, or tag correctly."
  }

  assert {
    condition = alltrue([
      for branch in values(azuredevops_git_repository_branch.this) :
      branch.repository_id == azuredevops_git_repository.this.id
    ])
    error_message = "All created branches must belong to the managed repository."
  }
}

run "reject_blank_default_branch" {
  command = plan
  variables { default_branch = "refs/heads/" }
  expect_failures = [var.default_branch]
}

run "reject_duplicate_branch_refs" {
  command = plan
  variables { branches = { main = {}, "refs/heads/main" = {} } }
  expect_failures = [var.branches]
}
