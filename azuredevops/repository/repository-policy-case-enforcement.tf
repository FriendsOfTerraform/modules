resource "azuredevops_repository_policy_case_enforcement" "this" {
  count = var.policy.case_enforcement != null ? 1 : 0

  project_id              = data.azuredevops_project.this.id
  repository_ids          = [azuredevops_git_repository.this.id]
  enabled                 = var.policy.case_enforcement
  blocking                = true
  enforce_consistent_case = var.policy.case_enforcement
}
