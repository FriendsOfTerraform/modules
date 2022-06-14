locals {
  is_kubernetes = lower(var.authentication_method) == "kubernetes"
}

resource "vault_auth_backend" "kubernetes_auth_backend" {
  count = local.is_kubernetes ? 1 : 0

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

resource "vault_kubernetes_auth_backend_config" "kubernetes_auth_backend_config" {
  count = local.is_kubernetes ? 1 : 0

  backend            = vault_auth_backend.kubernetes_auth_backend[0].path
  kubernetes_host    = var.kubernetes_config.host
  kubernetes_ca_cert = var.kubernetes_config.ca_certificate
  token_reviewer_jwt = var.kubernetes_config.token_reviewer_jwt
  issuer             = var.kubernetes_config.issuer != null ? var.kubernetes_config.issuer : "kubernetes.io/serviceaccount"
}