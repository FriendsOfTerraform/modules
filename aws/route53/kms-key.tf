# This key will be used as the key signing key for DNSSEC
resource "aws_kms_key" "dnssec_kms_key" {
  for_each = var.enables_dnssec != null ? var.enables_dnssec.key_signing_keys : {}

  description              = "Used as DNSSEC KSK for hosted zone ${aws_route53_zone.hosted_zone.name}"
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
}

resource "aws_kms_alias" "dnssec_kms_key_alias" {
  for_each = var.enables_dnssec != null ? var.enables_dnssec.key_signing_keys : {}

  name          = "alias/${each.key}"
  target_key_id = aws_kms_key.dnssec_kms_key[each.key].key_id
}
