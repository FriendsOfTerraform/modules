resource "vault_kubernetes_auth_backend_role" "kubernetes_auth_roles" {
  for_each = local.is_kubernetes ? var.kubernetes_auth_roles : {}

  backend                          = vault_auth_backend.kubernetes_auth_backend[0].path
  role_name                        = each.key
  bound_service_account_names      = each.value.bound_service_account_names
  bound_service_account_namespaces = each.value.bound_service_account_namespaces
  token_ttl                        = each.value.token_ttl_seconds
  token_max_ttl                    = each.value.token_max_ttl_seconds
  token_policies                   = each.value.token_policies
}