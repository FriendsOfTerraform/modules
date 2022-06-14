resource "vault_github_team" "github_teams" {
  for_each = local.is_github ? (
    var.github_config.teams != null ? (
      var.github_config.teams
    ) : {}
  ) : {}

  backend  = vault_github_auth_backend.github_auth_backend[0].id
  team     = each.key
  policies = each.value
}

resource "vault_github_user" "github_users" {
  for_each = local.is_github ? (
    var.github_config.users != null ? (
      var.github_config.users
    ) : {}
  ) : {}

  backend  = vault_github_auth_backend.github_auth_backend[0].id
  user     = each.key
  policies = each.value
}
