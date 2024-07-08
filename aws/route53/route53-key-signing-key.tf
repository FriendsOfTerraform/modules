resource "aws_route53_key_signing_key" "key_signing_keys" {
  for_each = var.enables_dnssec != null ? var.enables_dnssec.key_signing_keys : {}
  depends_on = [
    aws_kms_key.dnssec_kms_key,
    aws_kms_alias.dnssec_kms_key_alias
  ]

  hosted_zone_id             = aws_route53_zone.hosted_zone.id
  key_management_service_arn = aws_kms_key.dnssec_kms_key[each.key].arn
  name                       = each.key
  status                     = each.value.status
}
