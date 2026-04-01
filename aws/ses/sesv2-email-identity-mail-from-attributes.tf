resource "aws_sesv2_email_identity_mail_from_attributes" "custom_mail_from_domains" {
  for_each = { for k, v in var.domains : k => v if v.use_custom_mail_from_domain != null }

  email_identity         = aws_sesv2_email_identity.domain_identities[each.key].email_identity
  behavior_on_mx_failure = each.value.use_custom_mail_from_domain.behavior_on_mx_failure
  mail_from_domain       = "${each.value.use_custom_mail_from_domain.subdomain_name}.${aws_sesv2_email_identity.domain_identities[each.key].email_identity}"
}