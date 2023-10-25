resource "aws_acmpca_permission" "allow_acm_access" {
  count = var.authorize_acm_access_to_renew_certificates ? 1 : 0

  certificate_authority_arn = aws_acmpca_certificate_authority.certificate_authority.arn
  actions                   = ["IssueCertificate", "GetCertificate", "ListPermissions"]
  principal                 = "acm.amazonaws.com"
}
