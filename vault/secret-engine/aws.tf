locals {
  is_aws = lower(var.secret_engine) == "aws"
}

resource "vault_aws_secret_backend" "aws_secret_backend" {
  count = local.is_aws ? 1 : 0

  path                      = var.mount_path
  description               = var.description
  default_lease_ttl_seconds = var.aws_config.default_ttl_seconds
  max_lease_ttl_seconds     = var.aws_config.max_ttl_seconds

  access_key = var.aws_config.access_key_id
  secret_key = var.aws_config.secret_access_key
  region     = var.aws_config.region
}