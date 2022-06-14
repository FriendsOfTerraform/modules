locals {
  is_generic = var.secret_engine == "pki" || var.secret_engine == "kv" || var.secret_engine == "database"
}

resource "vault_mount" "secret_mount" {
  count = local.is_generic ? 1 : 0

  path                      = var.mount_path
  type                      = var.secret_engine == "kv" ? "kv-v2" : var.secret_engine
  description               = var.description
  default_lease_ttl_seconds = var.default_ttl_seconds
  max_lease_ttl_seconds     = var.max_ttl_seconds
}