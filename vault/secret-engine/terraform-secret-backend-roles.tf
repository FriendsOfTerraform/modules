resource "vault_terraform_cloud_secret_role" "terraform_cloud_secret_backend_roles" {
  for_each = local.is_terraform ? var.terraform_secret_backend_roles : {}

  backend = vault_terraform_cloud_secret_backend.terraform_cloud_secret_backend[0].backend
  name    = each.key
  ttl     = each.value.ttl_seconds
  max_ttl = each.value.max_ttl_seconds

  organization = split("-", each.value.token_identity)[0] != "team" ? (split("-", each.value.token_identity)[0] != "user" ? each.value.token_identity : "") : ""
  team_id      = split("-", each.value.token_identity)[0] == "team" ? each.value.token_identity : ""
  user_id      = split("-", each.value.token_identity)[0] == "user" ? each.value.token_identity : ""
}
