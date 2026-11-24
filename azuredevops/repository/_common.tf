data "azuredevops_project" "this" {
  name = var.project_name
}

locals {
  branch_names = toset([for name in keys(var.branches) : trimprefix(name, "refs/heads/")])

  branch_source_types = {
    for name, branch in var.branches : name => (
      branch.based_on == null ? "default" :
      startswith(branch.based_on, "refs/heads/") ||
      trimprefix(branch.based_on, "refs/heads/") == trimprefix(var.default_branch, "refs/heads/") ||
      contains(local.branch_names, trimprefix(branch.based_on, "refs/heads/")) ? "branch" :
      can(regex("^[0-9a-fA-F]{40}$", branch.based_on)) ? "commit" :
      "tag"
    )
  }

  common_tags = {
    managed-by = "Terraform"
  }

  time_table_in_minutes = {
    second = 1 / 60
    minute = 1
    hour   = 60
    day    = 1440
    week   = 10080
    month  = 43200
    year   = 525600
  }
}
