resource "aws_lb_listener" "application_load_balancer_listeners" {
  for_each = local.application_load_balancer ? var.application_load_balancer.listeners : {}

  load_balancer_arn = aws_lb.load_balancer.arn
  certificate_arn   = contains(local.secured_protocols, lower(split(":", each.key)[0])) ? each.value.default_ssl_certificate_arn : null
  port              = split(":", each.key)[1]
  protocol          = upper(split(":", each.key)[0])
  ssl_policy        = contains(local.secured_protocols, lower(split(":", each.key)[0])) ? each.value.security_policy : null

  # attributes
  routing_http_response_server_enabled                                  = each.value.attributes.add_alb_server_response_header
  routing_http_response_access_control_allow_credentials_header_value   = each.value.attributes.add_response_headers.access_control_allow_credentials
  routing_http_response_access_control_allow_headers_header_value       = each.value.attributes.add_response_headers.access_control_allow_headers
  routing_http_response_access_control_allow_methods_header_value       = each.value.attributes.add_response_headers.access_control_allow_methods
  routing_http_response_access_control_allow_origin_header_value        = each.value.attributes.add_response_headers.access_control_allow_origin
  routing_http_response_access_control_expose_headers_header_value      = each.value.attributes.add_response_headers.access_control_expose_headers
  routing_http_response_access_control_max_age_header_value             = each.value.attributes.add_response_headers.access_control_max_age
  routing_http_response_content_security_policy_header_value            = each.value.attributes.add_response_headers.content_security_policy
  routing_http_response_strict_transport_security_header_value          = each.value.attributes.add_response_headers.http_strict_transport_security
  routing_http_response_x_content_type_options_header_value             = each.value.attributes.add_response_headers.x_content_type_options
  routing_http_response_x_frame_options_header_value                    = each.value.attributes.add_response_headers.x_frame_options
  routing_http_request_x_amzn_mtls_clientcert_header_name               = each.value.attributes.modify_mtls_header_names.x_amzn_mtls_clientcert
  routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = each.value.attributes.modify_mtls_header_names.x_amzn_mtls_clientcert_issuer
  routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = each.value.attributes.modify_mtls_header_names.x_amzn_mtls_clientcert_leaf
  routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = each.value.attributes.modify_mtls_header_names.x_amzn_mtls_clientcert_serial_number
  routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = each.value.attributes.modify_mtls_header_names.x_amzn_mtls_clientcert_subject
  routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = each.value.attributes.modify_mtls_header_names.x_amzn_mtls_clientcert_validity
  routing_http_request_x_amzn_tls_cipher_suite_header_name              = each.value.attributes.modify_mtls_header_names.x_amzn_tls_cipher_suite
  routing_http_request_x_amzn_tls_version_header_name                   = each.value.attributes.modify_mtls_header_names.x_amzn_tls_version

  default_action {
    type = each.value.default_action.fixed_response != null ? "fixed-response" : (
      each.value.default_action.forward != null ? "forward" : (
        each.value.default_action.redirect != null ? "redirect" : (
          each.value.default_action.authenticate_users != null ? (
            each.value.default_action.authenticate_users.oidc != null ? "authenticate-oidc" : "authenticate-cognito"
          ) : null
        )
      )
    )

    dynamic "authenticate_cognito" {
      for_each = each.value.default_action.authenticate_users != null ? (each.value.default_action.authenticate_users.amazon_cognito != null ? [1] : []) : []

      content {
        user_pool_arn                       = each.value.default_action.authenticate_users.amazon_cognito.user_pool
        user_pool_client_id                 = each.value.default_action.authenticate_users.amazon_cognito.app_client
        user_pool_domain                    = each.value.default_action.authenticate_users.amazon_cognito.user_pool_domain
        authentication_request_extra_params = each.value.default_action.authenticate_users.extra_request_parameters
        on_unauthenticated_request          = each.value.default_action.authenticate_users.action_on_unauthenticatedd_request
        scope                               = each.value.default_action.authenticate_users.scope
        session_cookie_name                 = each.value.default_action.authenticate_users.session_cookie_name
        session_timeout                     = split(" ", each.value.default_action.authenticate_users.session_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.default_action.authenticate_users.session_timeout)[1], "s")]
      }
    }

    dynamic "authenticate_oidc" {
      for_each = each.value.default_action.authenticate_users != null ? (each.value.default_action.authenticate_users.oidc != null ? [1] : []) : []

      content {
        authorization_endpoint              = each.value.default_action.authenticate_users.oidc.authorization_endpoint
        client_id                           = each.value.default_action.authenticate_users.oidc.client_id
        client_secret                       = each.value.default_action.authenticate_users.oidc.client_secret
        issuer                              = each.value.default_action.authenticate_users.oidc.issuer
        token_endpoint                      = each.value.default_action.authenticate_users.oidc.token_endpoint
        user_info_endpoint                  = each.value.default_action.authenticate_users.oidc.user_info_endpoint
        authentication_request_extra_params = each.value.default_action.authenticate_users.extra_request_parameters
        on_unauthenticated_request          = each.value.default_action.authenticate_users.action_on_unauthenticatedd_request
        scope                               = each.value.default_action.authenticate_users.scope
        session_cookie_name                 = each.value.default_action.authenticate_users.session_cookie_name
        session_timeout                     = split(" ", each.value.default_action.authenticate_users.session_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.default_action.authenticate_users.session_timeout)[1], "s")]
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.default_action.fixed_response != null ? [1] : []

      content {
        content_type = each.value.default_action.fixed_response.content_type
        message_body = each.value.default_action.fixed_response.response_body
        status_code  = each.value.default_action.fixed_response.response_code
      }
    }

    dynamic "forward" {
      for_each = each.value.default_action.forward != null ? [1] : []

      content {
        dynamic "target_group" {
          for_each = each.value.default_action.forward.target_groups

          content {
            arn    = target_group.key
            weight = target_group.value.weight
          }
        }

        dynamic "stickiness" {
          for_each = each.value.default_action.forward.turn_on_target_group_stickiness != null ? [1] : []

          content {
            duration = split(" ", each.value.default_action.forward.turn_on_target_group_stickiness.duration)[0] * local.time_table[trimsuffix(split(" ", each.value.default_action.forward.turn_on_target_group_stickiness.duration)[1], "s")]
            enabled  = true
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = each.value.default_action.redirect != null ? [1] : []

      content {
        status_code = "HTTP_${each.value.default_action.redirect.status_code}"
        protocol    = regex(local.regex.url, each.value.default_action.redirect.url)[0]
        host        = split(":", regex(local.regex.url, each.value.default_action.redirect.url)[1])[0]
        port        = length(split(":", regex(local.regex.url, each.value.default_action.redirect.url)[1])) > 1 ? split(":", regex(local.regex.url, each.value.default_action.redirect.url)[1])[1] : local.port_table[regex(local.regex.url, each.value.default_action.redirect.url)[0]]
        path        = regex(local.regex.url, each.value.default_action.redirect.url)[2]
        query       = trimprefix(regex(local.regex.url, each.value.default_action.redirect.url)[3], "?")
      }
    }
  }

  dynamic "mutual_authentication" {
    for_each = each.value.enable_mutual_authentication != null ? [1] : []

    content {
      mode                             = each.value.enable_mutual_authentication.verify_with_trust_store != null ? "verify" : "passthrough"
      advertise_trust_store_ca_names   = each.value.enable_mutual_authentication.verify_with_trust_store != null ? each.value.enable_mutual_authentication.verify_with_trust_store.advertise_trust_store_ca_subject_name : null
      ignore_client_certificate_expiry = each.value.enable_mutual_authentication.verify_with_trust_store != null ? each.value.enable_mutual_authentication.verify_with_trust_store.allow_expired_client_certificates : null

      trust_store_arn = each.value.enable_mutual_authentication.verify_with_trust_store != null ? (
        each.value.enable_mutual_authentication.verify_with_trust_store.trust_store_arn != null ? each.value.enable_mutual_authentication.verify_with_trust_store.trust_store_arn : aws_lb_trust_store.trust_stores[each.key].arn
      ) : null
    }
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}

resource "aws_lb_listener" "gateway_load_balancer_listener" {
  count = local.gateway_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.load_balancer.arn

  default_action {
    type             = "forward"
    target_group_arn = var.gateway_load_balancer.listener.default_action.forward.target_group
  }

  tags = merge(
    local.common_tags,
    var.gateway_load_balancer.listener.additional_tags,
    var.additional_tags_all
  )
}

resource "aws_lb_listener" "network_load_balancer_listeners" {
  for_each = local.network_load_balancer ? var.network_load_balancer.listeners : {}

  load_balancer_arn = aws_lb.load_balancer.arn
  alpn_policy       = lower(split(":", each.key)[0]) == "tls" ? each.value.alpn_policy : null
  certificate_arn   = contains(local.secured_protocols, lower(split(":", each.key)[0])) ? each.value.default_ssl_certificate_arn : null
  port              = split(":", each.key)[1]
  protocol          = upper(split(":", each.key)[0])
  ssl_policy        = contains(local.secured_protocols, lower(split(":", each.key)[0])) ? each.value.security_policy : null

  # attributes
  tcp_idle_timeout_seconds = lower(split(":", each.key)[0]) == "tcp" ? (
    split(" ", each.value.attributes.tcp_idle_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.attributes.tcp_idle_timeout)[1], "s")]
  ) : null

  default_action {
    type             = "forward"
    target_group_arn = each.value.default_action.forward.target_group
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
