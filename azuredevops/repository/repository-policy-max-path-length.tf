resource "azuredevops_repository_policy_max_path_length" "this" {
  count = var.policy.maximum_path_length != null ? 1 : 0

  project_id      = data.azuredevops_project.this.id
  repository_ids  = [azuredevops_git_repository.this.id]
  enabled         = true
  blocking        = true
  max_path_length = var.policy.maximum_path_length
}
