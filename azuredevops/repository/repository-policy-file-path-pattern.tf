resource "azuredevops_repository_policy_file_path_pattern" "this" {
  count = var.policy.file_path_validation != null ? 1 : 0

  project_id        = data.azuredevops_project.this.id
  repository_ids    = [azuredevops_git_repository.this.id]
  enabled           = true
  blocking          = true
  filepath_patterns = var.policy.file_path_validation
}
