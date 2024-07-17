data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  common_tags = {
    managed-by = "Terraform"
  }
}
