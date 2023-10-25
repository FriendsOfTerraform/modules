resource "aws_acmpca_certificate_authority_certificate" "import_root_ca_certificate" {
  count = var.ca_type == "ROOT" ? 1 : 0

  certificate_authority_arn = aws_acmpca_certificate_authority.certificate_authority.arn
  certificate               = aws_acmpca_certificate.root_ca_certificate[0].certificate
  certificate_chain         = aws_acmpca_certificate.root_ca_certificate[0].certificate_chain
}

resource "aws_acmpca_certificate_authority_certificate" "import_subordinate_ca_certificate" {
  count = var.ca_type == "SUBORDINATE" ? (
    var.subordinate_ca_configuration != null ? 1 : 0
  ) : 0

  certificate_authority_arn = aws_acmpca_certificate_authority.certificate_authority.arn

  certificate = var.subordinate_ca_configuration.parent_ca_arn != null ? aws_acmpca_certificate.subordinate_ca_certificate[0].certificate : (
    var.subordinate_ca_configuration.import_certificate.certificate
  )

  certificate_chain = var.subordinate_ca_configuration.parent_ca_arn != null ? aws_acmpca_certificate.subordinate_ca_certificate[0].certificate_chain : (
    var.subordinate_ca_configuration.import_certificate.certificate_chain
  )
}
