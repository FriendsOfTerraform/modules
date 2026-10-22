locals {
  vault_arn  = one(concat(aws_backup_vault.this[*].arn, aws_backup_logically_air_gapped_vault.this[*].arn))
  vault_name = one(concat(aws_backup_vault.this[*].name, aws_backup_logically_air_gapped_vault.this[*].name))

  common_tags = {
    managed-by = "Terraform"
  }

  time_table_in_days = {
    day   = 1
    month = 30
    week  = 7
    year  = 365
  }

  time_table_in_hours = {
    day  = 24
    hour = 1
    week = 168
  }

  time_table_in_minutes = {
    day    = 1440
    hour   = 60
    minute = 1
    month  = 43200
    week   = 10080
    year   = 525600
  }
}
