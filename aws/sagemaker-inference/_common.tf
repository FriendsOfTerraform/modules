locals {
  common_tags = {
    managed-by = "Terraform"
  }

  time_table = {
    second = 1
    minute = 60
    hour   = 3600
    day    = 86400
  }
}
