resource "azuredevops_repository_policy_reserved_names" "this" {
  count = var.policy.reserved_names != null ? 1 : 0

  project_id     = data.azuredevops_project.this.id
  repository_ids = [azuredevops_git_repository.this.id]
  enabled        = var.policy.reserved_names
  blocking       = true
}
