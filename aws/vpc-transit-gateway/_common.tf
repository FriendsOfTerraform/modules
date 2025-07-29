data "aws_region" "current" {}

locals {
  common_tags = {
    managed-by = "Terraform"
  }
}
