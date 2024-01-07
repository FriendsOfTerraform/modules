locals {
  execution_role_provided = var.execution_role_arn != null

  common_tags = {
    managed-by = "Terraform"
  }
}
