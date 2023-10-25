resource "aws_acmpca_policy" "private_ca_policy" {
  count = var.policy != null ? 1 : 0

  resource_arn = aws_acmpca_certificate_authority.certificate_authority.arn
  policy       = var.policy
}
