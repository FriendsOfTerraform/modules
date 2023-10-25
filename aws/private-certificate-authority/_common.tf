data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    managed-by = "Terraform"
  }
}
