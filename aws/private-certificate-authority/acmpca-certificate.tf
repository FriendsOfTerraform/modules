resource "aws_acmpca_certificate" "root_ca_certificate" {
  count = var.ca_type == "ROOT" ? 1 : 0

  certificate_authority_arn   = aws_acmpca_certificate_authority.certificate_authority.arn
  certificate_signing_request = aws_acmpca_certificate_authority.certificate_authority.certificate_signing_request
  signing_algorithm           = var.signing_algorithm

  validity {
    type = strcontains(var.validity, "year") ? "YEARS" : (
      strcontains(var.validity, "month") ? "MONTHS" : (
        strcontains(var.validity, "day") ? "DAYS" : null
      )
    )

    value = regex("^(\\d+)", var.validity)[0]
  }

  template_arn = "arn:aws:acm-pca:::template/RootCACertificate/V1"
}

# Signs Subordinate CA with AWS private CA
resource "aws_acmpca_certificate" "subordinate_ca_certificate" {
  count = var.ca_type == "SUBORDINATE" ? (
    var.subordinate_ca_configuration != null ? (
      var.subordinate_ca_configuration.parent_ca_arn != null ? 1 : 0
    ) : 0
  ) : 0

  certificate_authority_arn   = var.subordinate_ca_configuration.parent_ca_arn
  certificate_signing_request = aws_acmpca_certificate_authority.certificate_authority.certificate_signing_request
  signing_algorithm           = var.signing_algorithm

  validity {
    type = strcontains(var.validity, "year") ? "YEARS" : (
      strcontains(var.validity, "month") ? "MONTHS" : (
        strcontains(var.validity, "day") ? "DAYS" : null
      )
    )

    value = regex("^(\\d+)", var.validity)[0]
  }

  template_arn = "arn:aws:acm-pca:::template/SubordinateCACertificate_PathLen${var.subordinate_ca_configuration.path_length}/V1"
}
