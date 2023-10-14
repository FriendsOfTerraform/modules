resource "aws_rolesanywhere_trust_anchor" "trust_anchors" {
  for_each = var.trust_anchors

  name    = each.key
  enabled = true

  source {
    source_data {
      acm_pca_arn           = each.value.certificate_authority_source.aws_private_certificate_authority_arn
      x509_certificate_data = each.value.certificate_authority_source.external_certificate_bundle
    }

    source_type = each.value.certificate_authority_source.aws_private_certificate_authority_arn != null ? "AWS_ACM_PCA" : "CERTIFICATE_BUNDLE"
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
