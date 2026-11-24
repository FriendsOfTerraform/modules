resource "azuredevops_branch_policy_merge_types" "exact_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if !endswith(name, "*") && branch.policy.allowed_merge_types != null
  }

  project_id = data.azuredevops_project.this.id

  settings {
    allow_basic_no_fast_forward   = each.value.policy.allowed_merge_types.basic_no_fast_forward
    allow_rebase_and_fast_forward = each.value.policy.allowed_merge_types.rebase_and_fast_forward
    allow_rebase_with_merge       = each.value.policy.allowed_merge_types.rebase_and_merge_commit
    allow_squash                  = each.value.policy.allowed_merge_types.squash

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(each.key, "refs/heads/")}"
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "prefix_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if endswith(name, "*") && branch.policy.allowed_merge_types != null
  }

  project_id = data.azuredevops_project.this.id

  settings {
    allow_basic_no_fast_forward   = each.value.policy.allowed_merge_types.basic_no_fast_forward
    allow_rebase_and_fast_forward = each.value.policy.allowed_merge_types.rebase_and_fast_forward
    allow_rebase_with_merge       = each.value.policy.allowed_merge_types.rebase_and_merge_commit
    allow_squash                  = each.value.policy.allowed_merge_types.squash

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(trimsuffix(each.key, "*"), "refs/heads/")}"
      match_type     = "Prefix"
    }
  }
}
