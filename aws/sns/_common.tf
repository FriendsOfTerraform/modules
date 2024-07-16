data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  common_tags = {
    managed-by = "Terraform"
  }
}

#TODOs
# active tracing requires resource policy - There is no way to create xray resource policy via Terraform today
