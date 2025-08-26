locals {
  listener_rules = local.application_load_balancer ? flatten([
    for listener_name, listener in var.application_load_balancer.listeners : [
      for k, v in listener.rules : {
        listener_name   = listener_name
        rule_name       = k
        priority        = v.priority
        additional_tags = v.additional_tags
        action          = v.action
        conditions      = v.conditions
      }
    ]
  ]) : []
}

resource "aws_lb_listener_rule" "listener_rules" {
  for_each = tomap({ for listener_rule in local.listener_rules : "${listener_rule.listener_name}-${listener_rule.rule_name}" => listener_rule })

  listener_arn = aws_lb_listener.application_load_balancer_listeners[each.value.listener_name].arn
  priority     = each.value.priority

  action {
    type = each.value.action.fixed_response != null ? "fixed-response" : (
      each.value.action.forward != null ? "forward" : (
        each.value.action.redirect != null ? "redirect" : (
          each.value.action.authenticate_users != null ? (
            each.value.action.authenticate_users.oidc != null ? "authenticate-oidc" : "authenticate-cognito"
          ) : null
        )
      )
    )

    dynamic "authenticate_cognito" {
      for_each = each.value.action.authenticate_users != null ? (each.value.action.authenticate_users.amazon_cognito != null ? [1] : []) : []

      content {
        user_pool_arn                       = each.value.action.authenticate_users.amazon_cognito.user_pool
        user_pool_client_id                 = each.value.action.authenticate_users.amazon_cognito.app_client
        user_pool_domain                    = each.value.action.authenticate_users.amazon_cognito.user_pool_domain
        authentication_request_extra_params = each.value.action.authenticate_users.extra_request_parameters
        on_unauthenticated_request          = each.value.action.authenticate_users.action_on_unauthenticatedd_request
        scope                               = each.value.action.authenticate_users.scope
        session_cookie_name                 = each.value.action.authenticate_users.session_cookie_name
        session_timeout                     = split(" ", each.value.action.authenticate_users.session_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.action.authenticate_users.session_timeout)[1], "s")]
      }
    }

    dynamic "authenticate_oidc" {
      for_each = each.value.action.authenticate_users != null ? (each.value.action.authenticate_users.oidc != null ? [1] : []) : []

      content {
        authorization_endpoint              = each.value.action.authenticate_users.oidc.authorization_endpoint
        client_id                           = each.value.action.authenticate_users.oidc.client_id
        client_secret                       = each.value.action.authenticate_users.oidc.client_secret
        issuer                              = each.value.action.authenticate_users.oidc.issuer
        token_endpoint                      = each.value.action.authenticate_users.oidc.token_endpoint
        user_info_endpoint                  = each.value.action.authenticate_users.oidc.user_info_endpoint
        authentication_request_extra_params = each.value.action.authenticate_users.extra_request_parameters
        on_unauthenticated_request          = each.value.action.authenticate_users.action_on_unauthenticatedd_request
        scope                               = each.value.action.authenticate_users.scope
        session_cookie_name                 = each.value.action.authenticate_users.session_cookie_name
        session_timeout                     = split(" ", each.value.action.authenticate_users.session_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.action.authenticate_users.session_timeout)[1], "s")]
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.action.fixed_response != null ? [1] : []

      content {
        content_type = each.value.action.fixed_response.content_type
        message_body = each.value.action.fixed_response.response_body
        status_code  = each.value.action.fixed_response.response_code
      }
    }

    dynamic "forward" {
      for_each = each.value.action.forward != null ? [1] : []

      content {
        dynamic "target_group" {
          for_each = each.value.action.forward.target_groups

          content {
            arn    = target_group.key
            weight = target_group.value.weight
          }
        }

        dynamic "stickiness" {
          for_each = each.value.action.forward.turn_on_target_group_stickiness != null ? [1] : []

          content {
            duration = split(" ", each.value.action.forward.turn_on_target_group_stickiness.duration)[0] * local.time_table[trimsuffix(split(" ", each.value.action.forward.turn_on_target_group_stickiness.duration)[1], "s")]
            enabled  = true
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = each.value.action.redirect != null ? [1] : []

      content {
        status_code = "HTTP_${each.value.action.redirect.status_code}"
        protocol    = startswith(regex(local.regex.url, each.value.action.redirect.url)[0], "http") ? upper(regex(local.regex.url, each.value.action.redirect.url)[0]) : regex(local.regex.url, each.value.action.redirect.url)[0]
        host        = split(":", regex(local.regex.url, each.value.action.redirect.url)[1])[0]
        port        = length(split(":", regex(local.regex.url, each.value.action.redirect.url)[1])) > 1 ? split(":", regex(local.regex.url, each.value.action.redirect.url)[1])[1] : local.port_table[regex(local.regex.url, each.value.action.redirect.url)[0]]
        path        = regex(local.regex.url, each.value.action.redirect.url)[2]
        query       = trimprefix(regex(local.regex.url, each.value.action.redirect.url)[3], "?")
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.conditions

    content {
      dynamic "host_header" {
        for_each = condition.value.host_headers != null ? [1] : []

        content {
          values = condition.value.host_headers
        }
      }

      dynamic "http_header" {
        for_each = condition.value.http_headers

        content {
          http_header_name = http_header.key
          values           = http_header.value
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.http_request_methods != null ? [1] : []

        content {
          values = condition.value.http_request_methods
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.paths != null ? [1] : []

        content {
          values = condition.value.paths
        }
      }

      dynamic "query_string" {
        for_each = condition.value.query_strings

        content {
          key   = query_string.key
          value = query_string.value
        }
      }

      dynamic "source_ip" {
        for_each = condition.value.source_ips != null ? [1] : []

        content {
          values = condition.value.source_ips
        }
      }
    }
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
