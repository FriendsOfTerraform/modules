resource "aws_sesv2_email_identity" "domain_identities" {
  for_each = { for identity_name, identity in var.identities : identity_name => identity if strcontains(identity_name, "@") == false }

  email_identity         = each.key
  tags                   = merge(local.common_tags, var.additional_tags_all, each.value.additional_tags)
  configuration_set_name = each.value.default_configuration_set != null ? aws_sesv2_configuration_set.configuration_sets[each.value.default_configuration_set].configuration_set_name : null

  dynamic "dkim_signing_attributes" {
    for_each = each.value.dkim_settings != null ? [1] : []

    content {
      domain_signing_private_key = each.value.dkim_settings.provide_dkim_authentication_token != null ? each.value.dkim_settings.provide_dkim_authentication_token.private_key : null
      domain_signing_selector    = each.value.dkim_settings.provide_dkim_authentication_token != null ? each.value.dkim_settings.provide_dkim_authentication_token.selector_name : null
      next_signing_key_length    = each.value.dkim_settings.easy_dkim != null ? each.value.dkim_settings.easy_dkim.signing_key_length : null
    }
  }
}

resource "aws_sesv2_email_identity" "email_identities" {
  for_each = { for identity_name, identity in var.identities : identity_name => identity if strcontains(identity_name, "@") }

  email_identity         = each.key
  tags                   = merge(local.common_tags, var.additional_tags_all, each.value.additional_tags)
  configuration_set_name = each.value.default_configuration_set != null ? aws_sesv2_configuration_set.configuration_sets[each.value.default_configuration_set].configuration_set_name : null
}