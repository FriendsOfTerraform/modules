resource "azuredevops_repository_policy_max_file_size" "this" {
  count = var.policy.maximum_file_size != null ? 1 : 0

  project_id     = data.azuredevops_project.this.id
  repository_ids = [azuredevops_git_repository.this.id]
  enabled        = true
  blocking       = true
  max_file_size  = var.policy.maximum_file_size
}
