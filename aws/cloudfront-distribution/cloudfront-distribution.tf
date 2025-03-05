data "aws_cloudfront_cache_policy" "cache_policies" {
  for_each = var.behaviors

  name = each.value.cache_policy_name
}

data "aws_cloudfront_origin_request_policy" "origin_request_policies" {
  for_each = { for k, v in var.behaviors : k => v if v.origin_request_policy_name != null }

  name = each.value.origin_request_policy_name
}

data "aws_cloudfront_response_headers_policy" "response_headers_policies" {
  for_each = { for k, v in var.behaviors : k => v if v.response_headers_policy_name != null }

  name = each.value.response_headers_policy_name
}

locals {
  cloudfront_function_regex = "arn:aws:cloudfront::\\d{12}:function\\/"
  lambda_function_regex     = "arn:aws:lambda:\\w+(?:-\\w+)+:\\d{12}:function"

  geo_restriction_allow_list = var.geographic_restrictions != null ? (
    var.geographic_restrictions.allow_list != null ? [for country in var.geographic_restrictions.allow_list : local.countries[country]] : null
  ) : null

  geo_restriction_block_list = var.geographic_restrictions != null ? (
    var.geographic_restrictions.block_list != null ? [for country in var.geographic_restrictions.block_list : local.countries[country]] : null
  ) : null
}

resource "aws_cloudfront_distribution" "distribution" {
  aliases             = var.alternate_domain_names
  comment             = var.description
  enabled             = true
  price_class         = var.price_class
  http_version        = var.max_http_version
  default_root_object = var.default_root_object
  is_ipv6_enabled     = var.enable_ipv6


  restrictions {
    geo_restriction {
      locations        = local.geo_restriction_allow_list != null ? local.geo_restriction_allow_list : local.geo_restriction_block_list != null ? local.geo_restriction_block_list : []
      restriction_type = local.geo_restriction_allow_list != null ? "whitelist" : local.geo_restriction_block_list != null ? "blacklist" : "none"
    }
  }

  dynamic "origin" {
    for_each = var.origins

    content {
      domain_name              = origin.key
      origin_id                = origin.key
      origin_path              = origin.value.origin_path
      connection_attempts      = origin.value.connection_attempts
      connection_timeout       = origin.value.connection_timeout
      origin_access_control_id = origin.value.s3_origin_config != null ? origin.value.s3_origin_config.origin_access.origin_access_control_id : null

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [1] : []

        content {
          http_port                = origin.value.custom_origin_config.http_port
          https_port               = origin.value.custom_origin_config.https_port
          origin_protocol_policy   = origin.value.custom_origin_config.protocol_policy
          origin_ssl_protocols     = [origin.value.custom_origin_config.minimum_ssl_protocol]
          origin_keepalive_timeout = origin.value.custom_origin_config.keep_alive_timeout
          origin_read_timeout      = origin.value.custom_origin_config.response_timeout
        }
      }

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? origin.value.s3_origin_config.origin_access.origin_access_identity != null ? [1] : [] : []

        content {
          origin_access_identity = origin.value.s3_origin_config.origin_access.origin_access_identity
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers

        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.enable_origin_shield != null ? [1] : []

        content {
          enabled              = true
          origin_shield_region = origin.value.enable_origin_shield.region
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.origin_groups

    content {
      origin_id = origin_group.key

      failover_criteria {
        status_codes = origin_group.value.failover_criteria
      }

      dynamic "member" {
        for_each = origin_group.value.origins

        content {
          origin_id = member.value
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods            = var.behaviors["*"].allowed_http_methods
    cached_methods             = var.behaviors["*"].allowed_http_methods
    cache_policy_id            = data.aws_cloudfront_cache_policy.cache_policies["*"].id
    field_level_encryption_id  = var.behaviors["*"].field_level_encryption_id
    compress                   = var.behaviors["*"].compress_objects_automatically
    origin_request_policy_id   = var.behaviors["*"].origin_request_policy_name != null ? data.aws_cloudfront_origin_request_policy.origin_request_policies["*"].id : null
    realtime_log_config_arn    = var.behaviors["*"].realtime_log_config_arn
    response_headers_policy_id = var.behaviors["*"].response_headers_policy_name != null ? data.aws_cloudfront_response_headers_policy.response_headers_policies["*"].id : null
    smooth_streaming           = var.behaviors["*"].smooth_streaming
    target_origin_id           = var.behaviors["*"].target_origin
    viewer_protocol_policy     = var.behaviors["*"].viewer_protocol_policy
    trusted_key_groups         = var.behaviors["*"].trusted_key_groups

    dynamic "function_association" {
      for_each = { for k, v in var.behaviors["*"].function_associations : k => v if length(regexall(local.cloudfront_function_regex, v.function_arn)) > 0 }

      content {
        event_type   = function_association.key
        function_arn = function_association.value.function_arn
      }
    }

    dynamic "lambda_function_association" {
      for_each = { for k, v in var.behaviors["*"].function_associations : k => v if length(regexall(local.lambda_function_regex, v.function_arn)) > 0 }

      content {
        event_type   = lambda_function_association.key
        lambda_arn   = lambda_function_association.value.function_arn
        include_body = lambda_function_association.value.include_body
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = { for k, v in var.behaviors : k => v if k != "*" }

    content {
      path_pattern               = ordered_cache_behavior.key
      allowed_methods            = ordered_cache_behavior.value.allowed_http_methods
      cached_methods             = ordered_cache_behavior.value.allowed_http_methods
      cache_policy_id            = data.aws_cloudfront_cache_policy.cache_policies[ordered_cache_behavior.key].id
      field_level_encryption_id  = ordered_cache_behavior.value.field_level_encryption_id
      compress                   = ordered_cache_behavior.value.compress_objects_automatically
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_name != null ? data.aws_cloudfront_origin_request_policy.origin_request_policies[ordered_cache_behavior.key].id : null
      realtime_log_config_arn    = ordered_cache_behavior.value.realtime_log_config_arn
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_name != null ? data.aws_cloudfront_response_headers_policy.response_headers_policies[ordered_cache_behavior.key].id : null
      smooth_streaming           = ordered_cache_behavior.value.smooth_streaming
      target_origin_id           = ordered_cache_behavior.value.target_origin
      viewer_protocol_policy     = ordered_cache_behavior.value.viewer_protocol_policy
      trusted_key_groups         = ordered_cache_behavior.value.trusted_key_groups

      dynamic "function_association" {
        for_each = { for k, v in var.behaviors["*"].function_associations : k => v if length(regexall(local.cloudfront_function_regex, v.function_arn)) > 0 }

        content {
          event_type   = function_association.key
          function_arn = function_association.value.function_arn
        }
      }

      dynamic "lambda_function_association" {
        for_each = { for k, v in var.behaviors["*"].function_associations : k => v if length(regexall(local.lambda_function_regex, v.function_arn)) > 0 }

        content {
          event_type   = lambda_function_association.key
          lambda_arn   = lambda_function_association.value.function_arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_minimum_ttl
      error_code            = custom_error_response.key
      response_code         = custom_error_response.value.http_response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate.acm_certificate_arn
    cloudfront_default_certificate = var.viewer_certificate.acm_certificate_arn == null
    minimum_protocol_version       = var.viewer_certificate.acm_certificate_arn != null ? var.viewer_certificate.security_policy : "TLSv1"
    ssl_support_method             = var.viewer_certificate.acm_certificate_arn != null ? var.viewer_certificate.ssl_support_method : null
  }

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
