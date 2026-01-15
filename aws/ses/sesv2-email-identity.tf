locals {
  domains_with_email_addresses = { for domain_name, domain in var.domains : domain_name => domain if length(domain.email_addresses) > 0 }
  email_identities = flatten([
    for domain_name, domain in local.domains_with_email_addresses : [
      for email_address, email in domain.email_addresses : {
        domain_name    = domain_name
        email_address  = email_address
        email_identity = email
      }
    ]
  ])
}

resource "aws_sesv2_email_identity" "domain_identities" {
  for_each = var.domains

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
  for_each = { for email_identity in local.email_identities : "${email_identity.domain_name}-${email_identity.email_address}" => email_identity }

  email_identity         = endswith(each.value.email_address, each.value.domain_name) ? each.value.email_address : "${each.value.email_address}@${each.value.domain_name}"
  tags                   = merge(local.common_tags, var.additional_tags_all, each.value.email_identity.additional_tags)
  configuration_set_name = each.value.email_identity.default_configuration_set != null ? aws_sesv2_configuration_set.configuration_sets[each.value.email_identity.default_configuration_set].configuration_set_name : null
}