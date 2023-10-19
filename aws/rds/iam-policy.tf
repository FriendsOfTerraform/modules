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
}
