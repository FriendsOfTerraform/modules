resource "azuredevops_repository_policy_author_email_pattern" "this" {
  count = var.policy.commit_author_email_validation != null ? 1 : 0

  project_id            = data.azuredevops_project.this.id
  repository_ids        = [azuredevops_git_repository.this.id]
  enabled               = true
  blocking              = true
  author_email_patterns = var.policy.commit_author_email_validation
}
