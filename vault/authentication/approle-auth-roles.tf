resource "vault_approle_auth_backend_role" "approle_auth_roles" {
  for_each = lower(var.authentication_method) == "approle" ? var.approle_auth_roles : {}

  backend               = vault_auth_backend.auth_backend[0].path
  role_name             = each.key
  secret_id_bound_cidrs = each.value.secret_id_bound_cidrs
  secret_id_num_uses    = each.value.secret_id_num_uses
  token_ttl             = each.value.token_ttl_seconds
  token_max_ttl         = each.value.token_max_ttl_seconds
  token_policies        = each.value.token_policies
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  for_each   = lower(var.authentication_method) == "approle" ? var.approle_auth_roles : {}
  depends_on = [vault_approle_auth_backend_role.approle_auth_roles]

  backend   = vault_auth_backend.auth_backend[0].path
  role_name = each.key
  cidr_list = each.value.secret_id_bound_cidrs
}