locals {
  is_generic = var.authentication_method == "approle" || var.authentication_method == "aws"
}

resource "vault_auth_backend" "auth_backend" {
  count = local.is_generic ? 1 : 0

  type        = var.authentication_method
  path        = var.mount_path
  description = var.description

  dynamic "tune" {
    for_each = var.method_options != null ? [1] : []

    content {
      default_lease_ttl  = var.method_options.default_lease_ttl
      max_lease_ttl      = var.method_options.max_lease_ttl
      listing_visibility = var.method_options.listing_visibility
    }
  }
}