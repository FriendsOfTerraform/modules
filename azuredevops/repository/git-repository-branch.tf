resource "azuredevops_git_repository_branch" "this" {
  for_each = {
    for name, branch in var.branches : name => branch
    if trimprefix(name, "refs/heads/") != trimprefix(var.default_branch, "refs/heads/") && !endswith(name, "*")
  }
  repository_id = azuredevops_git_repository.this.id
  name          = trimprefix(each.key, "refs/heads/")

  ref_branch = local.branch_source_types[each.key] == "default" ? azuredevops_git_repository.this.default_branch : (
    local.branch_source_types[each.key] == "branch" ? trimprefix(each.value.based_on, "refs/heads/") : null
  )
  ref_commit_id = local.branch_source_types[each.key] == "commit" ? each.value.based_on : null
  ref_tag       = local.branch_source_types[each.key] == "tag" ? each.value.based_on : null
}
