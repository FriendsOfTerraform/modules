data "azuredevops_project" "this" {
  name = var.project_name
}

locals {
  common_tags = {
    managed-by = "Terraform"
  }
}
