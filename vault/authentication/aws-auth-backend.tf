locals {
  is_aws = lower(var.authentication_method) == "aws"
}

resource "vault_aws_auth_backend_client" "aws_auth_backend_client" {
  count = local.is_aws ? (var.aws_backend_credential != null ? 1 : 0) : 0

  backend    = vault_auth_backend.auth_backend[0].path
  access_key = var.aws_backend_credential.access_key_id
  secret_key = var.aws_backend_credential.secret_access_key
}