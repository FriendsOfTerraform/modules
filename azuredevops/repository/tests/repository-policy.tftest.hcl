mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }
  mock_resource "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
  }
}

variables {
  name           = "repository-policy-tests"
  project_name   = "Example Project"
  default_branch = "main"
}

run "default_policies_unmanaged" {
  command = plan
  assert {
    condition = (
      length(azuredevops_repository_policy_author_email_pattern.this) == 0 &&
      length(azuredevops_repository_policy_file_path_pattern.this) == 0 &&
      length(azuredevops_repository_policy_case_enforcement.this) == 0 &&
      length(azuredevops_repository_policy_reserved_names.this) == 0 &&
      length(azuredevops_repository_policy_max_path_length.this) == 0 &&
      length(azuredevops_repository_policy_max_file_size.this) == 0
    )
    error_message = "Default policy input must create no repository policies."
  }
}

run "all_policies_enabled" {
  command = apply
  variables {
    policy = {
      commit_author_email_validation = ["*@example.com", "!blocked@example.com"]
      file_path_validation           = ["*.exe", "!/allowed/*.exe"]
      case_enforcement               = true
      reserved_names                 = true
      maximum_path_length            = 500
      maximum_file_size              = 10
    }
  }
  assert {
    condition = alltrue([
      for resource in [
        azuredevops_repository_policy_author_email_pattern.this[0],
        azuredevops_repository_policy_file_path_pattern.this[0],
        azuredevops_repository_policy_case_enforcement.this[0],
        azuredevops_repository_policy_reserved_names.this[0],
        azuredevops_repository_policy_max_path_length.this[0],
        azuredevops_repository_policy_max_file_size.this[0],
      ] : resource.project_id == data.azuredevops_project.this.id &&
      toset(resource.repository_ids) == toset([azuredevops_git_repository.this.id]) &&
      resource.enabled && resource.blocking
    ])
    error_message = "All configured policies must be enabled, blocking, and scoped only to the managed repository."
  }
  assert {
    condition = (
      tolist(azuredevops_repository_policy_author_email_pattern.this[0].author_email_patterns) == var.policy.commit_author_email_validation &&
      tolist(azuredevops_repository_policy_file_path_pattern.this[0].filepath_patterns) == var.policy.file_path_validation &&
      azuredevops_repository_policy_case_enforcement.this[0].enforce_consistent_case &&
      azuredevops_repository_policy_max_path_length.this[0].max_path_length == 500 &&
      azuredevops_repository_policy_max_file_size.this[0].max_file_size == 10
    )
    error_message = "Policy settings must preserve pattern order and forward numeric and case-enforcement values."
  }
}

run "false_disables_boolean_policies" {
  command = apply
  variables {
    policy = { case_enforcement = false, reserved_names = false }
  }
  assert {
    condition = (
      length(azuredevops_repository_policy_case_enforcement.this) == 1 &&
      length(azuredevops_repository_policy_reserved_names.this) == 1 &&
      !azuredevops_repository_policy_case_enforcement.this[0].enabled &&
      !azuredevops_repository_policy_case_enforcement.this[0].enforce_consistent_case &&
      !azuredevops_repository_policy_reserved_names.this[0].enabled &&
      azuredevops_repository_policy_case_enforcement.this[0].blocking &&
      azuredevops_repository_policy_reserved_names.this[0].blocking &&
      length(azuredevops_repository_policy_author_email_pattern.this) == 0 &&
      length(azuredevops_repository_policy_file_path_pattern.this) == 0 &&
      length(azuredevops_repository_policy_max_path_length.this) == 0 &&
      length(azuredevops_repository_policy_max_file_size.this) == 0
    )
    error_message = "False must create disabled boolean policies; other null settings must remain unmanaged."
  }
}

run "minimum_limits" {
  command = apply
  variables { policy = { maximum_path_length = 1, maximum_file_size = 1 } }
  assert {
    condition = (
      azuredevops_repository_policy_max_path_length.this[0].max_path_length == 1 &&
      azuredevops_repository_policy_max_file_size.this[0].max_file_size == 1
    )
    error_message = "Minimum supported limits must be accepted unchanged."
  }
}

run "maximum_limits" {
  command = apply
  variables { policy = { maximum_path_length = 10000, maximum_file_size = 200 } }
  assert {
    condition = (
      azuredevops_repository_policy_max_path_length.this[0].max_path_length == 10000 &&
      azuredevops_repository_policy_max_file_size.this[0].max_file_size == 200
    )
    error_message = "Maximum supported limits must be accepted unchanged."
  }
}

run "reject_empty_email_patterns" {
  command = plan
  variables { policy = { commit_author_email_validation = [] } }
  expect_failures = [var.policy]
}

run "reject_empty_path_patterns" {
  command = plan
  variables { policy = { file_path_validation = [] } }
  expect_failures = [var.policy]
}

run "reject_blank_email_pattern" {
  command = plan
  variables { policy = { commit_author_email_validation = [" "] } }
  expect_failures = [var.policy]
}

run "reject_null_path_pattern" {
  command = plan
  variables { policy = { file_path_validation = [null] } }
  expect_failures = [var.policy]
}

run "reject_zero_path_length" {
  command = plan
  variables { policy = { maximum_path_length = 0 } }
  expect_failures = [var.policy]
}

run "reject_excessive_path_length" {
  command = plan
  variables { policy = { maximum_path_length = 10001 } }
  expect_failures = [var.policy]
}

run "reject_fractional_path_length" {
  command = plan
  variables { policy = { maximum_path_length = 1.5 } }
  expect_failures = [var.policy]
}

run "reject_unsupported_file_size" {
  command = plan
  variables { policy = { maximum_file_size = 3 } }
  expect_failures = [var.policy]
}
