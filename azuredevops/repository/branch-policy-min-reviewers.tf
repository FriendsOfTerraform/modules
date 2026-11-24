resource "azuredevops_branch_policy_min_reviewers" "exact_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if !endswith(name, "*") && branch.policy.require_a_minimum_number_of_reviewers != null
  }

  project_id = data.azuredevops_project.this.id

  settings {
    reviewer_count                         = each.value.policy.require_a_minimum_number_of_reviewers.minimum_number_of_reviewers
    submitter_can_vote                     = each.value.policy.require_a_minimum_number_of_reviewers.allow_requestors_to_approve_their_own_changes
    last_pusher_cannot_approve             = each.value.policy.require_a_minimum_number_of_reviewers.prohibit_the_most_recent_pusher_from_approving_their_own_changes
    allow_completion_with_rejects_or_waits = each.value.policy.require_a_minimum_number_of_reviewers.allow_completion_even_if_some_reviewers_vote_to_wait_or_reject
    on_push_reset_approved_votes = (
      each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "reset_all_approval_votes" ||
      each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "reset_all_votes"
    ) ? true : null
    on_push_reset_all_votes        = each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "reset_all_votes" ? true : null
    on_each_iteration_require_vote = each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "require_vote_on_each_iteration" ? true : null
    on_last_iteration_require_vote = each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "require_vote_on_last_iteration" ? true : null

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(each.key, "refs/heads/")}"
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "prefix_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if endswith(name, "*") && branch.policy.require_a_minimum_number_of_reviewers != null
  }

  project_id = data.azuredevops_project.this.id

  settings {
    reviewer_count                         = each.value.policy.require_a_minimum_number_of_reviewers.minimum_number_of_reviewers
    submitter_can_vote                     = each.value.policy.require_a_minimum_number_of_reviewers.allow_requestors_to_approve_their_own_changes
    last_pusher_cannot_approve             = each.value.policy.require_a_minimum_number_of_reviewers.prohibit_the_most_recent_pusher_from_approving_their_own_changes
    allow_completion_with_rejects_or_waits = each.value.policy.require_a_minimum_number_of_reviewers.allow_completion_even_if_some_reviewers_vote_to_wait_or_reject
    on_push_reset_approved_votes = (
      each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "reset_all_approval_votes" ||
      each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "reset_all_votes"
    ) ? true : null
    on_push_reset_all_votes        = each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "reset_all_votes" ? true : null
    on_each_iteration_require_vote = each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "require_vote_on_each_iteration" ? true : null
    on_last_iteration_require_vote = each.value.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == "require_vote_on_last_iteration" ? true : null

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(trimsuffix(each.key, "*"), "refs/heads/")}"
      match_type     = "Prefix"
    }
  }
}
