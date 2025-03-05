variable "behaviors" {
  type = map(object({
    target_origin                  = string
    cache_policy_name              = string
    allowed_http_methods           = optional(list(string), ["GET", "HEAD"])
    compress_objects_automatically = optional(bool, true)
    field_level_encryption_id      = optional(string, null)
    origin_request_policy_name     = optional(string, null)
    realtime_log_config_arn        = optional(string, null)
    response_headers_policy_name   = optional(string, null)
    smooth_streaming               = optional(bool, false)
    trusted_key_groups             = optional(list(string), null)
    viewer_protocol_policy         = optional(string, "redirect-to-https")

    function_associations = optional(map(object({
      function_arn = string
      include_body = optional(bool, false)
    })), {})
  }))
  description = "list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0. The default behavior (*) must be specified"
}

variable "origins" {
  type = map(object({
    connection_attempts = optional(number, 3)
    connection_timeout  = optional(number, 10)
    custom_headers      = optional(map(string), {})
    origin_path         = optional(string, null)

    custom_origin_config = optional(object({
      http_port            = optional(number, 80)
      https_port           = optional(number, 443)
      keep_alive_timeout   = optional(number, 5)
      minimum_ssl_protocol = optional(string, "TLSv1.2")
      protocol_policy      = optional(string, "https-only")
      response_timeout     = optional(number, 30)
    }), null)

    enable_origin_shield = optional(object({
      region = string
    }), null)

    s3_origin_config = optional(object({
      origin_access = object({
        origin_access_control_id = optional(string, null)
        origin_access_identity   = optional(string, null)
      })
    }), null)
  }))
  description = "One or more origins for this distribution"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the cloudfront distribution"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "alternate_domain_names" {
  type        = list(string)
  description = "custom domain names that you use in URLs for the files served by this distribution"
  default     = null
}

variable "custom_error_responses" {
  type = map(object({
    error_caching_minimum_ttl = optional(number, 10)
    http_response_code        = optional(number, null)
    response_page_path        = optional(string, null)
  }))
  description = "Customize the custom error response when the origin sends this error code"
  default     = {}
}

variable "default_root_object" {
  type        = string
  description = "The object (file name) to return when a viewer requests the root URL (/) instead of a specific object"
  default     = null
}

variable "description" {
  type        = string
  description = "The description of the distribution"
  default     = null
}

variable "enable_ipv6" {
  type        = bool
  description = ""
  default     = false
}

variable "geographic_restrictions" {
  type = object({
    allow_list = optional(list(string), null)
    block_list = optional(list(string), null)
  })
  description = "Configures the CloudFront geographic restrictions"
  default     = null
}

variable "max_http_version" {
  type        = string
  description = "Max HTTP version this distribution supports. HTTP/1.0 and HTTP/1.1 are supported by default"
  default     = "http2"
}

variable "origin_groups" {
  type = map(object({
    origins           = list(string)
    failover_criteria = optional(list(number), [500])
  }))
  description = "One or more origin groups for this distribution"
  default     = {}
}

variable "price_class" {
  type        = string
  description = ""
  default     = "PriceClass_All" # "PriceClass_100" "PriceClass_200" "PriceClass_All"
}

variable "viewer_certificate" {
  type = object({
    acm_certificate_arn = optional(string, null)
    security_policy     = optional(string, "TLSv1.2_2021")
    ssl_support_method  = optional(string, "sni-only")
  })
  description = "Associate a certificate from AWS Certificate Manager. The certificate must be in the US East (N. Virginia) Region (us-east-1)"
  default     = {}
}
