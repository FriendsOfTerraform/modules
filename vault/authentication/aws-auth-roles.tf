resource "vault_aws_auth_backend_role" "aws_auth_roles" {
  for_each = local.is_aws ? var.aws_auth_roles : {}
  depends_on = [
    vault_aws_auth_backend_sts_role.sts_roles,
    vault_aws_auth_backend_client.aws_auth_backend_client
  ]

  backend                  = vault_auth_backend.auth_backend[0].path
  role                     = each.key
  bound_iam_principal_arns = each.value.bound_iam_principal_arns
  token_ttl                = each.value.token_ttl_seconds
  token_max_ttl            = each.value.token_max_ttl_seconds
  token_policies           = each.value.token_policies
}

resource "vault_aws_auth_backend_sts_role" "sts_roles" {
  for_each = local.is_aws ? var.aws_auth_roles : {}
  depends_on = [
    vault_aws_auth_backend_client.aws_auth_backend_client
  ]

  backend    = vault_auth_backend.auth_backend[0].path
  account_id = regex("\\d{12}", each.value.sts_role_arn)
  sts_role   = each.value.sts_role_arn
}