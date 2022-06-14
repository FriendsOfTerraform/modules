resource "vault_pki_secret_backend_role" "pki_secret_backend_roles" {
  for_each = local.is_pki ? var.pki_secret_backend_roles : {}

  backend          = vault_mount.secret_mount[0].path
  name             = each.key
  ttl              = each.value.ttl_seconds
  max_ttl          = each.value.max_ttl_seconds
  allowed_domains  = each.value.allowed_domains
  allowed_uri_sans = each.value.allowed_uri_sans


  # defaults
  allow_any_name      = true
  allow_ip_sans       = true
  enforce_hostnames   = false
  require_cn          = false
  use_csr_common_name = true
  use_csr_sans        = true
  key_bits            = 2048
}
