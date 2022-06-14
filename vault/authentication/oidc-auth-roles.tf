resource "vault_jwt_auth_backend_role" "oidc_auth_roles" {
  for_each = local.is_oidc ? var.oidc_auth_roles : {}

  backend               = vault_jwt_auth_backend.oidc_auth_backend[0].path
  role_name             = each.key
  user_claim            = each.value.user_claim
  bound_claims          = each.value.bound_claims
  groups_claim          = each.value.groups_claim
  oidc_scopes           = each.value.oidc_scopes
  allowed_redirect_uris = each.value.allowed_redirect_uris
  token_ttl             = each.value.token_ttl_seconds
  token_max_ttl         = each.value.token_max_ttl_seconds
  token_policies        = each.value.token_policies
}