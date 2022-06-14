locals {
  is_github = lower(var.authentication_method) == "github"
}

resource "vault_github_auth_backend" "github_auth_backend" {
  count = local.is_github ? 1 : 0

  path         = var.mount_path
  organization = var.github_config.organization
  description  = var.description

  dynamic "tune" {
    for_each = var.method_options != null ? [1] : []

    content {
      default_lease_ttl  = var.method_options.default_lease_ttl
      max_lease_ttl      = var.method_options.max_lease_ttl
      listing_visibility = var.method_options.listing_visibility
    }
  }
}