resource "aws_sesv2_email_identity_feedback_attributes" "feedback_forwarding" {
  for_each = var.identities

  email_identity           = strcontains(each.key, "@") ? aws_sesv2_email_identity.email_identities[each.key].email_identity : aws_sesv2_email_identity.domain_identities[each.key].email_identity
  email_forwarding_enabled = each.value.enable_feedback_forwarding
}