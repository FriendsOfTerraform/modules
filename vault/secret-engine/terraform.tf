locals {
  is_terraform = lower(var.secret_engine) == "terraform"
}

resource "vault_terraform_cloud_secret_backend" "terraform_cloud_secret_backend" {
  count = local.is_terraform ? 1 : 0

  backend                   = var.mount_path
  description               = var.description
  default_lease_ttl_seconds = var.default_ttl_seconds
  max_lease_ttl_seconds     = var.max_ttl_seconds
  token                     = var.terraform_config.token
}