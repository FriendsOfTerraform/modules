locals {
  listeners_with_mtls        = local.application_load_balancer ? { for k, v in var.application_load_balancer.listeners : k => v if v.enable_mutual_authentication != null } : {}
  listeners_with_verify_mtls = { for k, v in local.listeners_with_mtls : k => v if v.enable_mutual_authentication.verify_with_trust_store != null }
  trust_stores_to_create     = { for k, v in local.listeners_with_verify_mtls : k => v if v.enable_mutual_authentication.verify_with_trust_store.new_trust_store != null }
}

resource "aws_lb_trust_store" "trust_stores" {
  for_each = local.trust_stores_to_create

  name = "${var.name}-${replace(each.key, ":", "-")}"

  ca_certificates_bundle_s3_bucket         = regex(local.regex.url, each.value.enable_mutual_authentication.verify_with_trust_store.new_trust_store.certificate_authority_bundle.s3_uri)[1]
  ca_certificates_bundle_s3_key            = trimprefix(regex(local.regex.url, each.value.enable_mutual_authentication.verify_with_trust_store.new_trust_store.certificate_authority_bundle.s3_uri)[2], "/")
  ca_certificates_bundle_s3_object_version = each.value.enable_mutual_authentication.verify_with_trust_store.new_trust_store.certificate_authority_bundle.version

  tags = merge(
    local.common_tags,
    each.value.enable_mutual_authentication.verify_with_trust_store.new_trust_store.additional_tags,
    var.additional_tags_all
  )
}
