locals {
  authorization_policies = flatten([
    for identity_name, identity_config in var.identities : [
      for policy_name, policy in identity_config.authorization_policies : {
        identity    = identity_name
        policy_name = policy_name
        policy      = policy
      }
    ]
  ])
}

resource "aws_sesv2_email_identity_policy" "authorization_policies" {
  for_each = { for policy in local.authorization_policies : "${policy.identity}/${policy.policy_name}" => policy }

  email_identity = strcontains(each.value.identity, "@") ? aws_sesv2_email_identity.email_identities[each.value.identity].email_identity : aws_sesv2_email_identity.domain_identities[each.value.identity].email_identity
  policy_name    = each.value.policy_name
  policy         = each.value.policy
}