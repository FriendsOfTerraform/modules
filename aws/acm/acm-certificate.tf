resource "aws_acm_certificate" "public_certificates" {
  for_each = var.public_certificates

  domain_name               = each.key
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method

  options {
    export = each.value.allow_export ? "ENABLED" : "DISABLED"
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )

  lifecycle {
    create_before_destroy = true
  }
}
