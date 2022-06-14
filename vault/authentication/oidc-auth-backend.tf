locals {
  is_oidc = lower(var.authentication_method) == "oidc"
}

resource "vault_jwt_auth_backend" "oidc_auth_backend" {
  count = local.is_oidc ? 1 : 0

  type        = var.authentication_method
  path        = var.mount_path
  description = var.description

  default_role       = var.oidc_config.default_role
  oidc_discovery_url = var.oidc_config.discovery_url
  oidc_client_id     = var.oidc_config.client_id
  oidc_client_secret = var.oidc_config.client_secret

  dynamic "tune" {
    for_each = var.method_options != null ? [1] : []

    content {
      default_lease_ttl  = var.method_options.default_lease_ttl
      max_lease_ttl      = var.method_options.max_lease_ttl
      listing_visibility = var.method_options.listing_visibility
    }
  }
}
