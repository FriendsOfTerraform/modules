locals {
  is_pki = lower(var.secret_engine) == "pki"
}

//
// Root CA
//

# configure pki secret as root CA
resource "vault_pki_secret_backend_root_cert" "root_ca" {
  count = local.is_pki ? (lower(var.pki_config.cert_type) == "root" ? 1 : 0) : 0

  backend     = vault_mount.secret_mount[0].path
  type        = "internal"
  common_name = var.pki_root_cert.common_name
  alt_names   = var.pki_root_cert.alternative_names
  ttl         = var.pki_root_cert.ttl_seconds
  key_bits    = 2048
  key_type    = "rsa"
  format      = "pem"
}

# configure root CA config_urls (refer to README for more details)
resource "vault_pki_secret_backend_config_urls" "config_urls" {
  count = local.is_pki ? (lower(var.pki_config.cert_type) == "root" ? 1 : 0) : 0

  backend                 = vault_mount.secret_mount[0].path
  issuing_certificates    = ["${var.pki_root_cert.vault_address}/v1/${vault_mount.secret_mount[0].path}/ca"]
  crl_distribution_points = ["${var.pki_root_cert.vault_address}/v1/${vault_mount.secret_mount[0].path}/crl"]
}

## Intermediate CA
##
# CSR
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediat_ca_csr" {
  count = local.is_pki ? (lower(var.pki_config.cert_type) == "intermediate" ? 1 : 0) : 0

  backend     = vault_mount.secret_mount[0].path
  type        = "internal"
  common_name = var.pki_intermediate_ca.common_name
  alt_names   = var.pki_intermediate_ca.alternative_names
  key_bits    = 2048
  key_type    = "rsa"
  format      = "pem"
}

# Signs certificate with root CA
resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate_ca" {
  count = local.is_pki ? (lower(var.pki_config.cert_type) == "intermediate" ? 1 : 0) : 0

  backend     = var.pki_intermediate_ca.signing_ca_mount_path
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediat_ca_csr[0].csr
  common_name = var.pki_intermediate_ca.common_name
  ttl         = var.pki_intermediate_ca.ttl_seconds
}

# Set the generated intermediate CA as the signing CA
resource "vault_pki_secret_backend_intermediate_set_signed" "set_intermediate_ca" {
  count = local.is_pki ? (lower(var.pki_config.cert_type) == "intermediate" ? 1 : 0) : 0

  backend     = vault_mount.secret_mount[0].path
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.intermediate_ca[0].certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate_ca[0].issuing_ca}"
}