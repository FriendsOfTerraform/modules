resource "azuredevops_branch_policy_work_item_linking" "exact_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if !endswith(name, "*") && branch.policy.check_for_lined_work_items != null
  }

  project_id = data.azuredevops_project.this.id
  blocking   = each.value.policy.check_for_lined_work_items == "required"

  settings {
    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(each.key, "refs/heads/")}"
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_work_item_linking" "prefix_rules" {
  for_each = {
    for name, branch in var.branches : name => branch
    if endswith(name, "*") && branch.policy.check_for_lined_work_items != null
  }

  project_id = data.azuredevops_project.this.id
  blocking   = each.value.policy.check_for_lined_work_items == "required"

  settings {
    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = "refs/heads/${trimprefix(trimsuffix(each.key, "*"), "refs/heads/")}"
      match_type     = "Prefix"
    }
  }
}