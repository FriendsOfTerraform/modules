locals {
  rds_proxy_iam_roles_to_create = {
    for k, v in var.proxies : k => v if v.iam_role_arn == null
  }

  rds_proxy_iam_policies_to_create = {
    for k, v in local.rds_proxy_iam_roles_to_create : k => keys(v.authentications)
  }
}

resource "aws_iam_policy" "rds_connection_policies" {
  for_each = var.authentication_config.iam_database_authentication != null ? (
    toset(var.authentication_config.iam_database_authentication.create_iam_policies_for_db_users)
  ) : toset([])

  description = "Allow connection to ${var.name} with DB user ${each.key}"
  name        = "${var.name}-${each.key}-dbconnection-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["rds-db:connect"]
        Resource = ["arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.name}/${each.key}"]
      }
    ]
  })

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_policy" "rds_proxy_secrets_reader_policies" {
  for_each = local.rds_proxy_iam_policies_to_create

  description = "Allow RDS proxy ${each.key} to read secrets"
  name        = "${var.name}-${each.key}-secrets-reader"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = each.value
      }
    ]
  })

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

