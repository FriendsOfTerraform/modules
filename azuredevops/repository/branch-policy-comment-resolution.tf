resource "azuredevops_branch_policy_comment_resolution" "exact_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if !endswith(name, "*") && branch.policy.check_for_comment_resolution != null
  }

  project_id = data.azuredevops_project.this.id
  blocking   = each.value.policy.check_for_comment_resolution == "required"

  settings {
    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(each.key, "refs/heads/")}"
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_comment_resolution" "prefix_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if endswith(name, "*") && branch.policy.check_for_comment_resolution != null
  }

  project_id = data.azuredevops_project.this.id
  blocking   = each.value.policy.check_for_comment_resolution == "required"

  settings {
    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(trimsuffix(each.key, "*"), "refs/heads/")}"
      match_type     = "Prefix"
    }
  }
}