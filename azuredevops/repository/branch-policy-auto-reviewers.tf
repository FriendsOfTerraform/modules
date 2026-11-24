locals {
  auto_reviewer_policies = flatten([
    for branch_name, branch in var.branches : [
      for policy_name, policy in branch.automatically_included_reviewers : {
        branch_name = branch_name
        policy_name = policy_name
        policy      = policy
      }
    ]
  ])

  auto_reviewer_users = toset(flatten([
    for entry in local.auto_reviewer_policies : [
      for reviewer in entry.policy.users : reviewer
      if reviewer != null
    ]
  ]))

  auto_reviewer_groups = toset(flatten([
    for entry in local.auto_reviewer_policies : [
      for reviewer in entry.policy.groups : reviewer
      if reviewer != null
    ]
  ]))
}

data "azuredevops_users" "auto_reviewers" {
  for_each = local.auto_reviewer_users

  principal_name = each.value

  lifecycle {
    postcondition {
      condition     = length(self.users) == 1
      error_message = "Each auto-reviewer principal name must match exactly one Azure DevOps user."
    }
  }
}

data "azuredevops_group" "auto_reviewers" {
  for_each = local.auto_reviewer_groups

  project_id = data.azuredevops_project.this.id
  name       = each.value
}

data "azuredevops_storage_key" "auto_reviewer_users" {
  for_each = local.auto_reviewer_users

  descriptor = one(data.azuredevops_users.auto_reviewers[each.key].users).descriptor
}

data "azuredevops_storage_key" "auto_reviewer_groups" {
  for_each = local.auto_reviewer_groups

  descriptor = data.azuredevops_group.auto_reviewers[each.key].descriptor
}

resource "azuredevops_branch_policy_auto_reviewers" "exact_rules" {
  for_each = {
    for entry in local.auto_reviewer_policies : jsonencode([entry.branch_name, entry.policy_name]) => entry
    if !endswith(entry.branch_name, "*")
  }

  project_id = data.azuredevops_project.this.id
  enabled    = each.value.policy.enabled
  blocking   = each.value.policy.policy_requirement == "required"

  settings {
    auto_reviewer_ids = concat(
      [for user in each.value.policy.users : data.azuredevops_storage_key.auto_reviewer_users[user].storage_key],
      [for group in each.value.policy.groups : data.azuredevops_storage_key.auto_reviewer_groups[group].storage_key]
    )
    path_filters       = each.value.policy.path_filters
    submitter_can_vote = each.value.policy.allow_requestors_to_approve_their_own_changes
    message            = each.value.policy.activity_feed_message

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(each.value.branch_name, "refs/heads/")}"
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_auto_reviewers" "prefix_rules" {
  for_each = {
    for entry in local.auto_reviewer_policies : jsonencode([entry.branch_name, entry.policy_name]) => entry
    if endswith(entry.branch_name, "*")
  }

  project_id = data.azuredevops_project.this.id
  enabled    = each.value.policy.enabled
  blocking   = each.value.policy.policy_requirement == "required"

  settings {
    auto_reviewer_ids = concat(
      [for user in each.value.policy.users : data.azuredevops_storage_key.auto_reviewer_users[user].storage_key],
      [for group in each.value.policy.groups : data.azuredevops_storage_key.auto_reviewer_groups[group].storage_key]
    )
    path_filters       = each.value.policy.path_filters
    submitter_can_vote = each.value.policy.allow_requestors_to_approve_their_own_changes
    message            = each.value.policy.activity_feed_message

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(trimsuffix(each.value.branch_name, "*"), "refs/heads/")}"
      match_type     = "Prefix"
    }
  }
}