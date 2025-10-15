locals {
  provisioned_endpoints = { for k, v in var.endpoints : k => v if v.provisioned != null }
  serverless_endpoints  = { for k, v in var.endpoints : k => v if v.serverless != null }

  common_tags = {
    managed-by = "Terraform"
  }
  comparison_operator_table = {
    ">=" = "GreaterThanOrEqualToThreshold"
    ">"  = "GreaterThanThreshold"
    "<=" = "LessThanOrEqualToThreshold"
    "<"  = "LessThanThreshold"
  }

  time_table = {
    second = 1
    minute = 60
    hour   = 3600
    day    = 86400
  }
}
