resource "aws_route53_hosted_zone_dnssec" "hosted_zone_dnssec" {
  count = var.enables_dnssec != null ? 1 : 0
  depends_on = [
    aws_route53_key_signing_key.key_signing_keys
  ]

  hosted_zone_id = aws_route53_zone.hosted_zone.id
  signing_status = var.enables_dnssec.status
}
