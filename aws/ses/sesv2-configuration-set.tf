resource "aws_sesv2_configuration_set" "configuration_sets" {
  for_each = var.configuration_sets

  configuration_set_name = each.key
  tags                   = merge(local.common_tags, var.additional_tags_all, each.value.additional_tags)

  delivery_options {
    max_delivery_seconds = each.value.maximum_delivery_duration != null ? split(" ", each.value.maximum_delivery_duration)[0] * local.time_table[trimsuffix(split(" ", each.value.maximum_delivery_duration)[1], "s")] : null
    sending_pool_name    = each.value.sending_ip_pool
    tls_policy           = each.value.require_tls ? "REQUIRE" : "OPTIONAL"
  }

  reputation_options {
    reputation_metrics_enabled = each.value.reputation_metrics_enabled
  }

  sending_options {
    sending_enabled = true
  }

  dynamic "suppression_options" {
    for_each = each.value.override_account_level_settings != null && each.value.override_account_level_settings.suppression_list_settings != null ? [1] : []

    content {
      suppressed_reasons = each.value.override_account_level_settings.suppression_list_settings.suppression_reason
    }
  }

  dynamic "tracking_options" {
    for_each = each.value.use_a_custom_redirect_domain != null ? [1] : []

    content {
      custom_redirect_domain = each.value.use_a_custom_redirect_domain.domain_name
      https_policy           = each.value.use_a_custom_redirect_domain.https_policy
    }
  }

  dynamic "vdm_options" {
    for_each = each.value.override_account_level_settings != null && each.value.override_account_level_settings.virtual_deliverability_manager_options != null ? [1] : []

    content {
      dashboard_options { engagement_metrics = each.value.override_account_level_settings.virtual_deliverability_manager_options.engagement_tracking_enabled ? "ENABLED" : "DISABLED" }
      guardian_options { optimized_shared_delivery = each.value.override_account_level_settings.virtual_deliverability_manager_options.optimized_shared_delivery_enabled ? "ENABLED" : "DISABLED" }
    }
  }
}