resource "vault_aws_secret_backend_role" "aws_secret_backend_roles" {
  for_each = local.is_aws ? var.aws_secret_backend_roles : {}

  backend = vault_aws_secret_backend.aws_secret_backend[0].path
  name    = each.key

  credential_type = length(each.value.role_arns) < 1 ? "iam_user" : "assumed_role"
  iam_groups      = length(each.value.role_arns) < 1 ? each.value.iam_group_names : null
  role_arns       = each.value.role_arns
  policy_arns     = each.value.aws_managed_policy_arns
  policy_document = each.value.inline_policy_document
}
