mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }
  mock_resource "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
  }
  mock_data "azuredevops_build_definition" {
    defaults = { id = "42" }
  }
  mock_data "azuredevops_users" {
    defaults = {
      users = [{ descriptor = "aad.reviewer", principal_name = "reviewer@example.com" }]
    }
  }
  mock_data "azuredevops_group" {
    defaults = { descriptor = "vssgp.reviewers" }
  }
  mock_data "azuredevops_storage_key" {
    defaults = { storage_key = "00000000-0000-0000-0000-000000000003" }
  }
}

variables {
  name           = "policy-tests"
  project_name   = "Example Project"
  default_branch = "main"
}

run "exact_and_prefix_policies" {
  command = apply
  variables {
    branches = {
      "refs/heads/main" = {
        policy = {
          check_for_comment_resolution = "required"
          check_for_lined_work_items   = "optional"
          allowed_merge_types = {
            basic_no_fast_forward   = false
            rebase_and_fast_forward = false
            rebase_and_merge_commit = false
            squash                  = true
          }
          require_a_minimum_number_of_reviewers = {
            minimum_number_of_reviewers                                      = 2
            allow_requestors_to_approve_their_own_changes                    = true
            prohibit_the_most_recent_pusher_from_approving_their_own_changes = true
            allow_completion_even_if_some_reviewers_vote_to_wait_or_reject   = true
            when_new_changes_are_pushed                                      = "reset_all_votes"
          }
        }
        build_validations = {
          required_build = {
            build_pipeline_name = "CI"
            build_expires_after = "immediately"
            path_filters        = ["src/*"]
          }
        }
        automatically_included_reviewers = {
          required_review = {
            users                 = ["reviewer@example.com"]
            groups                = ["Reviewers"]
            path_filters          = ["src/*"]
            activity_feed_message = "Please review"
          }
          same_reviewers = {
            users              = ["reviewer@example.com"]
            groups             = ["Reviewers"]
            policy_requirement = "optional"
          }
        }
      }
      "refs/heads/release/*" = {
        policy = {
          check_for_comment_resolution = "optional"
          check_for_lined_work_items   = "required"
          require_a_minimum_number_of_reviewers = {
            minimum_number_of_reviewers = 1
            when_new_changes_are_pushed = "reset_all_approval_votes"
          }
        }
        build_validations = {
          optional_build = {
            build_expires_after = "2 hours"
            trigger             = "manual"
            policy_requirement  = "optional"
            enabled             = false
            path_filters        = ["release/*"]
          }
        }
        automatically_included_reviewers = {
          optional_review = {
            groups                                        = ["Reviewers"]
            enabled                                       = false
            policy_requirement                            = "optional"
            allow_requestors_to_approve_their_own_changes = false
            path_filters                                  = ["release/*"]
            activity_feed_message                         = "Release review"
          }
        }
      }
      no_policy = {}
    }
  }

  override_data {
    target = data.azuredevops_storage_key.auto_reviewer_users["reviewer@example.com"]
    values = { storage_key = "00000000-0000-0000-0000-000000000004" }
  }

  assert {
    condition = alltrue(concat(
      [for policy in values(azuredevops_branch_policy_min_reviewers.exact_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_min_reviewers.prefix_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_merge_types.exact_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_merge_types.prefix_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_comment_resolution.exact_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_comment_resolution.prefix_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_work_item_linking.exact_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_work_item_linking.prefix_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_build_validation.exact_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_build_validation.prefix_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_auto_reviewers.exact_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for policy in values(azuredevops_branch_policy_auto_reviewers.prefix_rules) : policy.project_id == data.azuredevops_project.this.id],
      [for pipeline in values(data.azuredevops_build_definition.validation) : pipeline.project_id == data.azuredevops_project.this.id]
    ))
    error_message = "Every policy and pipeline lookup must use the resolved repository project."
  }

  assert {
    condition = (
      length(azuredevops_branch_policy_min_reviewers.exact_rules) == 1 &&
      length(azuredevops_branch_policy_min_reviewers.prefix_rules) == 1 &&
      length(azuredevops_branch_policy_merge_types.exact_rules) == 2 &&
      length(azuredevops_branch_policy_merge_types.prefix_rules) == 1 &&
      length(azuredevops_branch_policy_comment_resolution.exact_rules) == 1 &&
      length(azuredevops_branch_policy_comment_resolution.prefix_rules) == 1 &&
      length(azuredevops_branch_policy_work_item_linking.exact_rules) == 1 &&
      length(azuredevops_branch_policy_work_item_linking.prefix_rules) == 1 &&
      length(azuredevops_branch_policy_build_validation.exact_rules) == 1 &&
      length(azuredevops_branch_policy_build_validation.prefix_rules) == 1 &&
      length(azuredevops_branch_policy_auto_reviewers.exact_rules) == 2 &&
      length(azuredevops_branch_policy_auto_reviewers.prefix_rules) == 1
    )
    error_message = "Policies must split exact/prefix entries, omit absent optional policies, and allow identical reviewer lists under different names."
  }

  assert {
    condition = alltrue([
      for scope in concat(
        [for policy in values(azuredevops_branch_policy_min_reviewers.exact_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_merge_types.exact_rules) : policy.settings[0].scope[0] if policy.settings[0].scope[0].repository_ref != "refs/heads/no_policy"],
        [for policy in values(azuredevops_branch_policy_comment_resolution.exact_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_work_item_linking.exact_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_build_validation.exact_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_auto_reviewers.exact_rules) : policy.settings[0].scope[0]]
      ) :
      scope.repository_id == azuredevops_git_repository.this.id &&
      scope.repository_ref == "refs/heads/main" && scope.match_type == "Exact"
    ])
    error_message = "Every exact policy must scope to the managed repository and normalized full branch ref."
  }

  assert {
    condition = alltrue([
      for scope in concat(
        [for policy in values(azuredevops_branch_policy_min_reviewers.prefix_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_merge_types.prefix_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_comment_resolution.prefix_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_work_item_linking.prefix_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_build_validation.prefix_rules) : policy.settings[0].scope[0]],
        [for policy in values(azuredevops_branch_policy_auto_reviewers.prefix_rules) : policy.settings[0].scope[0]]
      ) :
      scope.repository_id == azuredevops_git_repository.this.id &&
      scope.repository_ref == "refs/heads/release/" && scope.match_type == "Prefix"
    ])
    error_message = "Every prefix policy must strip the wildcard, normalize the ref, and use Prefix matching."
  }

  assert {
    condition = (
      azuredevops_branch_policy_comment_resolution.exact_rules["refs/heads/main"].blocking &&
      !azuredevops_branch_policy_comment_resolution.prefix_rules["refs/heads/release/*"].blocking &&
      !azuredevops_branch_policy_work_item_linking.exact_rules["refs/heads/main"].blocking &&
      azuredevops_branch_policy_work_item_linking.prefix_rules["refs/heads/release/*"].blocking
    )
    error_message = "Comment and work-item policies must map required/optional to blocking/non-blocking."
  }

  assert {
    condition = (
      !azuredevops_branch_policy_merge_types.exact_rules["refs/heads/main"].settings[0].allow_basic_no_fast_forward &&
      !azuredevops_branch_policy_merge_types.exact_rules["refs/heads/main"].settings[0].allow_rebase_and_fast_forward &&
      !azuredevops_branch_policy_merge_types.exact_rules["refs/heads/main"].settings[0].allow_rebase_with_merge &&
      azuredevops_branch_policy_merge_types.exact_rules["refs/heads/main"].settings[0].allow_squash &&
      azuredevops_branch_policy_merge_types.prefix_rules["refs/heads/release/*"].settings[0].allow_basic_no_fast_forward &&
      azuredevops_branch_policy_merge_types.prefix_rules["refs/heads/release/*"].settings[0].allow_rebase_and_fast_forward &&
      azuredevops_branch_policy_merge_types.prefix_rules["refs/heads/release/*"].settings[0].allow_rebase_with_merge &&
      azuredevops_branch_policy_merge_types.prefix_rules["refs/heads/release/*"].settings[0].allow_squash
    )
    error_message = "Merge-type flags must be forwarded, and omitted flags must allow all merge types."
  }

  assert {
    condition = (
      azuredevops_branch_policy_min_reviewers.exact_rules["refs/heads/main"].settings[0].reviewer_count == 2 &&
      azuredevops_branch_policy_min_reviewers.exact_rules["refs/heads/main"].settings[0].submitter_can_vote &&
      azuredevops_branch_policy_min_reviewers.exact_rules["refs/heads/main"].settings[0].last_pusher_cannot_approve &&
      azuredevops_branch_policy_min_reviewers.exact_rules["refs/heads/main"].settings[0].allow_completion_with_rejects_or_waits &&
      azuredevops_branch_policy_min_reviewers.exact_rules["refs/heads/main"].settings[0].on_push_reset_approved_votes &&
      azuredevops_branch_policy_min_reviewers.exact_rules["refs/heads/main"].settings[0].on_push_reset_all_votes &&
      azuredevops_branch_policy_min_reviewers.prefix_rules["refs/heads/release/*"].settings[0].reviewer_count == 1 &&
      !azuredevops_branch_policy_min_reviewers.prefix_rules["refs/heads/release/*"].settings[0].submitter_can_vote &&
      !azuredevops_branch_policy_min_reviewers.prefix_rules["refs/heads/release/*"].settings[0].last_pusher_cannot_approve &&
      !azuredevops_branch_policy_min_reviewers.prefix_rules["refs/heads/release/*"].settings[0].allow_completion_with_rejects_or_waits &&
      azuredevops_branch_policy_min_reviewers.prefix_rules["refs/heads/release/*"].settings[0].on_push_reset_approved_votes &&
      azuredevops_branch_policy_min_reviewers.prefix_rules["refs/heads/release/*"].settings[0].on_push_reset_all_votes == null
    )
    error_message = "Minimum-reviewer settings must forward booleans and distinguish approval-only from all-vote resets."
  }

  assert {
    condition = (
      azuredevops_branch_policy_build_validation.exact_rules["refs/heads/main_required_build"].blocking &&
      azuredevops_branch_policy_build_validation.exact_rules["refs/heads/main_required_build"].enabled &&
      !azuredevops_branch_policy_build_validation.exact_rules["refs/heads/main_required_build"].settings[0].manual_queue_only &&
      !azuredevops_branch_policy_build_validation.exact_rules["refs/heads/main_required_build"].settings[0].queue_on_source_update_only &&
      azuredevops_branch_policy_build_validation.exact_rules["refs/heads/main_required_build"].settings[0].valid_duration == 0 &&
      azuredevops_branch_policy_build_validation.exact_rules["refs/heads/main_required_build"].settings[0].build_definition_id == 42 &&
      toset(azuredevops_branch_policy_build_validation.exact_rules["refs/heads/main_required_build"].settings[0].filename_patterns) == toset(["src/*"]) &&
      !azuredevops_branch_policy_build_validation.prefix_rules["refs/heads/release/*_optional_build"].blocking &&
      !azuredevops_branch_policy_build_validation.prefix_rules["refs/heads/release/*_optional_build"].enabled &&
      azuredevops_branch_policy_build_validation.prefix_rules["refs/heads/release/*_optional_build"].settings[0].manual_queue_only &&
      azuredevops_branch_policy_build_validation.prefix_rules["refs/heads/release/*_optional_build"].settings[0].queue_on_source_update_only &&
      azuredevops_branch_policy_build_validation.prefix_rules["refs/heads/release/*_optional_build"].settings[0].valid_duration == 120 &&
      toset(azuredevops_branch_policy_build_validation.prefix_rules["refs/heads/release/*_optional_build"].settings[0].filename_patterns) == toset(["release/*"]) &&
      data.azuredevops_build_definition.validation["CI"].name == "CI" &&
      data.azuredevops_build_definition.validation["optional_build"].name == "optional_build"
    )
    error_message = "Build policies must resolve explicit/fallback pipeline names and forward trigger, expiration, filters, and requirement flags."
  }

  assert {
    condition = (
      azuredevops_branch_policy_auto_reviewers.exact_rules[jsonencode(["refs/heads/main", "required_review"])].blocking &&
      azuredevops_branch_policy_auto_reviewers.exact_rules[jsonencode(["refs/heads/main", "required_review"])].enabled &&
      toset(azuredevops_branch_policy_auto_reviewers.exact_rules[jsonencode(["refs/heads/main", "required_review"])].settings[0].auto_reviewer_ids) == toset([
        "00000000-0000-0000-0000-000000000003",
        "00000000-0000-0000-0000-000000000004",
      ]) &&
      azuredevops_branch_policy_auto_reviewers.exact_rules[jsonencode(["refs/heads/main", "required_review"])].settings[0].submitter_can_vote &&
      azuredevops_branch_policy_auto_reviewers.exact_rules[jsonencode(["refs/heads/main", "required_review"])].settings[0].message == "Please review" &&
      toset(azuredevops_branch_policy_auto_reviewers.exact_rules[jsonencode(["refs/heads/main", "required_review"])].settings[0].path_filters) == toset(["src/*"]) &&
      !azuredevops_branch_policy_auto_reviewers.exact_rules[jsonencode(["refs/heads/main", "same_reviewers"])].blocking &&
      !azuredevops_branch_policy_auto_reviewers.prefix_rules[jsonencode(["refs/heads/release/*", "optional_review"])].blocking &&
      !azuredevops_branch_policy_auto_reviewers.prefix_rules[jsonencode(["refs/heads/release/*", "optional_review"])].enabled &&
      !azuredevops_branch_policy_auto_reviewers.prefix_rules[jsonencode(["refs/heads/release/*", "optional_review"])].settings[0].submitter_can_vote &&
      azuredevops_branch_policy_auto_reviewers.prefix_rules[jsonencode(["refs/heads/release/*", "optional_review"])].settings[0].message == "Release review" &&
      toset(azuredevops_branch_policy_auto_reviewers.prefix_rules[jsonencode(["refs/heads/release/*", "optional_review"])].settings[0].path_filters) == toset(["release/*"])
    )
    error_message = "Auto-reviewers must use storage-key IDs and stable named addresses, forwarding flags, messages, and path filters."
  }

  assert {
    condition = (
      data.azuredevops_users.auto_reviewers["reviewer@example.com"].principal_name == "reviewer@example.com" &&
      data.azuredevops_group.auto_reviewers["Reviewers"].project_id == data.azuredevops_project.this.id &&
      data.azuredevops_group.auto_reviewers["Reviewers"].name == "Reviewers" &&
      data.azuredevops_storage_key.auto_reviewer_users["reviewer@example.com"].descriptor == "aad.reviewer" &&
      data.azuredevops_storage_key.auto_reviewer_groups["Reviewers"].descriptor == "vssgp.reviewers"
    )
    error_message = "Reviewer lookups must distinguish user principal names from project groups and convert their graph descriptors."
  }
}

run "iteration_vote_modes" {
  command = apply
  variables {
    branches = {
      main = {
        policy = {
          require_a_minimum_number_of_reviewers = {
            minimum_number_of_reviewers = 1
            when_new_changes_are_pushed = "require_vote_on_each_iteration"
          }
        }
      }
      "release/*" = {
        policy = {
          require_a_minimum_number_of_reviewers = {
            minimum_number_of_reviewers = 1
            when_new_changes_are_pushed = "require_vote_on_last_iteration"
          }
        }
      }
      no_reset = {
        policy = {
          require_a_minimum_number_of_reviewers = { minimum_number_of_reviewers = 1 }
        }
      }
    }
  }
  assert {
    condition = (
      azuredevops_branch_policy_min_reviewers.exact_rules["main"].settings[0].on_each_iteration_require_vote &&
      azuredevops_branch_policy_min_reviewers.exact_rules["main"].settings[0].on_last_iteration_require_vote == null &&
      azuredevops_branch_policy_min_reviewers.exact_rules["main"].settings[0].on_push_reset_all_votes == null &&
      azuredevops_branch_policy_min_reviewers.exact_rules["main"].settings[0].on_push_reset_approved_votes == null &&
      azuredevops_branch_policy_min_reviewers.prefix_rules["release/*"].settings[0].on_last_iteration_require_vote &&
      azuredevops_branch_policy_min_reviewers.prefix_rules["release/*"].settings[0].on_each_iteration_require_vote == null &&
      azuredevops_branch_policy_min_reviewers.prefix_rules["release/*"].settings[0].on_push_reset_all_votes == null &&
      azuredevops_branch_policy_min_reviewers.prefix_rules["release/*"].settings[0].on_push_reset_approved_votes == null &&
      azuredevops_branch_policy_min_reviewers.exact_rules["no_reset"].settings[0].on_each_iteration_require_vote == null &&
      azuredevops_branch_policy_min_reviewers.exact_rules["no_reset"].settings[0].on_last_iteration_require_vote == null &&
      azuredevops_branch_policy_min_reviewers.exact_rules["no_reset"].settings[0].on_push_reset_all_votes == null &&
      azuredevops_branch_policy_min_reviewers.exact_rules["no_reset"].settings[0].on_push_reset_approved_votes == null
    )
    error_message = "Iteration modes must set only their corresponding flags; a null mode must leave all flags inactive."
  }
}

run "expiration_units_and_never" {
  command = apply
  variables {
    branches = {
      main = {
        build_validations = {
          seconds = { build_expires_after = "120 seconds" }
          bare    = { build_expires_after = "3" }
          minutes = { build_expires_after = "3 minutes" }
          hours   = { build_expires_after = "2 hours" }
          days    = { build_expires_after = "1 day" }
          weeks   = { build_expires_after = "1 week" }
          months  = { build_expires_after = "1 month" }
          years   = { build_expires_after = "1 year" }
          never   = {}
          zero    = { build_expires_after = "0", trigger = "manual" }
          max     = { build_expires_after = "527040", trigger = "manual" }
        }
      }
    }
  }
  assert {
    condition = alltrue([
      for name, expected in {
        seconds = 2, bare = 3, minutes = 3, hours = 120, days = 1440,
        weeks   = 10080, months = 43200, years = 525600, never = 0, zero = 0, max = 527040
      } : azuredevops_branch_policy_build_validation.exact_rules["main_${name}"].settings[0].valid_duration == expected
    ])
    error_message = "Expiration must convert every supported unit to minutes and preserve null/zero as never-expiring."
  }
  assert {
    condition = alltrue([
      for name, policy in azuredevops_branch_policy_build_validation.exact_rules :
      policy.settings[0].queue_on_source_update_only &&
      policy.settings[0].manual_queue_only == contains(["main_zero", "main_max"], name)
    ])
    error_message = "Non-immediate expirations must queue on source updates, independently of automatic/manual trigger mode."
  }
}

run "reject_manual_expiration_over_limit" {
  command = plan
  variables {
    branches = {
      main = { build_validations = { invalid = { build_expires_after = "527041", trigger = "manual" } } }
    }
  }
  expect_failures = [azuredevops_branch_policy_build_validation.exact_rules]
}

run "manual_immediate_and_automatic_prefix" {
  command = apply
  variables {
    branches = {
      main = {
        build_validations = {
          manual = {
            trigger             = "manual"
            build_expires_after = "immediately"
            policy_requirement  = "optional"
          }
        }
        policy = {
          check_for_comment_resolution = "optional"
          check_for_lined_work_items   = "required"
        }
      }
      "release/*" = {
        build_validations = { automatic = {} }
        policy = {
          check_for_comment_resolution = "required"
          check_for_lined_work_items   = "optional"
        }
      }
    }
  }
  assert {
    condition = (
      azuredevops_branch_policy_build_validation.exact_rules["main_manual"].settings[0].manual_queue_only &&
      !azuredevops_branch_policy_build_validation.exact_rules["main_manual"].settings[0].queue_on_source_update_only &&
      azuredevops_branch_policy_build_validation.exact_rules["main_manual"].settings[0].valid_duration == 0 &&
      !azuredevops_branch_policy_build_validation.exact_rules["main_manual"].blocking &&
      !azuredevops_branch_policy_build_validation.prefix_rules["release/*_automatic"].settings[0].manual_queue_only &&
      azuredevops_branch_policy_build_validation.prefix_rules["release/*_automatic"].settings[0].queue_on_source_update_only &&
      azuredevops_branch_policy_build_validation.prefix_rules["release/*_automatic"].settings[0].valid_duration == 0 &&
      azuredevops_branch_policy_build_validation.prefix_rules["release/*_automatic"].blocking &&
      azuredevops_branch_policy_build_validation.prefix_rules["release/*_automatic"].enabled &&
      !azuredevops_branch_policy_comment_resolution.exact_rules["main"].blocking &&
      azuredevops_branch_policy_comment_resolution.prefix_rules["release/*"].blocking &&
      azuredevops_branch_policy_work_item_linking.exact_rules["main"].blocking &&
      !azuredevops_branch_policy_work_item_linking.prefix_rules["release/*"].blocking
    )
    error_message = "Manual/automatic trigger flags must be independent of immediate/never expiration and requirement flags must work in both scopes."
  }
}

run "reject_fractional_minute_seconds" {
  command = plan
  variables {
    branches = { main = { build_validations = { invalid = { build_expires_after = "61 seconds" } } } }
  }
  expect_failures = [var.branches]
}

run "reject_prefix_manual_expiration_over_limit" {
  command = plan
  variables {
    branches = {
      "release/*" = { build_validations = { invalid = { build_expires_after = "527041", trigger = "manual" } } }
    }
  }
  expect_failures = [azuredevops_branch_policy_build_validation.prefix_rules]
}

run "reject_empty_reviewers" {
  command = plan
  variables {
    branches = { main = { automatically_included_reviewers = { invalid = {} } } }
  }
  expect_failures = [var.branches]
}

run "reject_reviewer_requirement" {
  command = plan
  variables {
    branches = {
      main = { automatically_included_reviewers = { invalid = { groups = ["Reviewers"], policy_requirement = "invalid" } } }
    }
  }
  expect_failures = [var.branches]
}

run "reject_build_trigger" {
  command = plan
  variables {
    branches = { main = { build_validations = { invalid = { trigger = "invalid" } } } }
  }
  expect_failures = [var.branches]
}

run "reject_build_requirement" {
  command = plan
  variables {
    branches = { main = { build_validations = { invalid = { policy_requirement = "invalid" } } } }
  }
  expect_failures = [var.branches]
}

run "reject_blank_pipeline_name" {
  command = plan
  variables {
    branches = { main = { build_validations = { invalid = { build_pipeline_name = " " } } } }
  }
  expect_failures = [var.branches]
}

run "reject_comment_requirement" {
  command = plan
  variables {
    branches = { main = { policy = { check_for_comment_resolution = "invalid" } } }
  }
  expect_failures = [var.branches]
}

run "reject_work_item_requirement" {
  command = plan
  variables {
    branches = { main = { policy = { check_for_lined_work_items = "invalid" } } }
  }
  expect_failures = [var.branches]
}

run "reject_vote_mode" {
  command = plan
  variables {
    branches = {
      main = { policy = { require_a_minimum_number_of_reviewers = {
        minimum_number_of_reviewers = 1
        when_new_changes_are_pushed = "invalid"
      } } }
    }
  }
  expect_failures = [var.branches]
}
