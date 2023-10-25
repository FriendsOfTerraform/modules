resource "aws_acmpca_certificate_authority" "certificate_authority" {
  certificate_authority_configuration {
    key_algorithm     = var.key_algorithm
    signing_algorithm = var.signing_algorithm

    subject {
      common_name         = var.subject.common_name
      country             = var.subject.country
      locality            = var.subject.locality
      organization        = var.subject.organization
      organizational_unit = var.subject.organization_unit
      state               = var.subject.state
    }
  }

  dynamic "revocation_configuration" {
    for_each = var.crl_configuration != null ? [1] : (
      var.ocsp_configuration != null ? [1] : []
    )

    content {
      dynamic "crl_configuration" {
        for_each = var.crl_configuration != null ? [1] : []

        content {
          custom_cname       = var.crl_configuration.custom_crl_name
          enabled            = var.crl_configuration.enabled
          expiration_in_days = var.crl_configuration.validity_in_days
          s3_bucket_name     = var.crl_configuration.create_s3_bucket != null ? aws_s3_bucket.crl_bucket[0].id : var.crl_configuration.s3_bucket_name
          s3_object_acl      = var.crl_configuration.create_s3_bucket != null ? "PUBLIC_READ" : "BUCKET_OWNER_FULL_CONTROL"
        }
      }

      dynamic "ocsp_configuration" {
        for_each = var.ocsp_configuration != null ? [1] : []

        content {
          enabled           = true
          ocsp_custom_cname = var.ocsp_configuration.custom_ocsp_endpoint
        }
      }
    }
  }

  usage_mode = var.usage_mode

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )

  type = var.ca_type
}
