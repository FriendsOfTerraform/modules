variable "behaviors" {
  type = map(object({
    /// Name of the origin or origin group that you want CloudFront to route
    /// requests to when a request matches the path pattern
    ///
    /// @since 1.0.0
    target_origin = string

    /// The name of the [cache policy][cloudfront-cache-policy] that is attached
    /// to the cache behavior.
    ///
    /// @link {cloudfront-cache-policy} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-the-cache-key.html
    /// @since 1.0.0
    cache_policy_name = string

    /// Controls which HTTP methods CloudFront processes and forwards to your
    /// origin.
    ///
    /// @enum GET|HEAD|OPTIONS|PUT|POST|PATCH|DELETE
    /// @since 1.0.0
    allowed_http_methods = optional(list(string), ["GET", "HEAD"])

    /// Whether you want CloudFront to automatically compress content for web
    /// requests that include `Accept-Encoding: gzip` in the request header.
    ///
    /// @since 1.0.0
    compress_objects_automatically = optional(bool, true)

    /// Associate a [field-level encryption configuration][cloudfront-field-level-encryption-configuration]
    /// with the cache behavior
    ///
    /// @link {cloudfront-field-level-encryption-configuration} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/field-level-encryption.html
    /// @since 1.0.0
    field_level_encryption_id = optional(string, null)

    /// Associate an [origin request policy][cloudfront-origin-request-policy]
    /// with the cache behavior
    ///
    /// @link {cloudfront-origin-request-policy} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-origin-requests.html
    /// @since 1.0.0
    origin_request_policy_name = optional(string, null)

    /// Associate a [real-time logs configuration][cloudfront-real-time-logs-configuration]
    /// with the cache behavior
    ///
    /// @link {cloudfront-real-time-logs-configuration} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/real-time-logs.html
    /// @since 1.0.0
    realtime_log_config_arn = optional(string, null)

    /// Associate a [response headers policy][cloudfront-response-headers-policy]
    /// with the cache behavior
    ///
    /// @link {cloudfront-response-headers-policy} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/understanding-response-headers-policies.html
    /// @since 1.0.0
    response_headers_policy_name = optional(string, null)

    /// Whether you want to distribute media files in Microsoft Smooth Streaming
    /// format using the origin that is associated with this cache behavior
    ///
    /// @since 1.0.0
    smooth_streaming = optional(bool, false)

    /// List of key group IDs that CloudFront can use to validate signed URLs or
    /// signed cookies.
    ///
    /// @link "Trusted Key Groups Documentation" https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html
    /// @since 1.0.0
    trusted_key_groups = optional(list(string), null)

    /// Specify the protocol that users can use to access the files in the origin
    /// when a request matches.
    ///
    /// @enum allow-all|https-only|redirect-to-https
    /// @since 1.0.0
    viewer_protocol_policy = optional(string, "redirect-to-https")

    /// Associate multiple edge functions (CloudFront Function or Lambda@Edge) to
    /// various CloudFront events. With edge functions you can write your own code
    /// to customize how your CloudFront distribution processes HTTP requests and
    /// responses. You can have up to four edge functions per cache behavior, one
    /// for each event type: `"viewer-request"`, `"viewer-response"`,
    /// `"origin-request"`, and `"origin-response"`. CloudFront Functions are only
    /// available for `"viewer-request"` and `"viewer-response"` event types.
    ///
    /// @example "Basic Usage" #basic-usage
    /// @since 1.0.0
    function_associations = optional(map(object({
      /// The ARN of a CloudFront function or Lambda@Edge function
      ///
      /// @since 1.0.0
      function_arn = string

      /// When using Lambda@Edge, your function code can access the body of the
      /// HTTP request.
      ///
      /// @since 1.0.0
      include_body = optional(bool, false)
    })), {})
  }))
  description = <<EOT
    Map of cache behaviors resource for this distribution. List from top to
    bottom in order of precedence. The topmost cache behavior will have
    precedence 0. The default behavior (`"*"`) must be specified.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
}

variable "origins" {
  type = map(object({
    /// The number of times that CloudFront attempts to connect to the origin.
    ///
    /// @enum 1|2|3
    /// @since 1.0.0
    connection_attempts = optional(number, 3)

    /// The number of seconds that CloudFront waits for a response from the
    /// origin, from `1 - 10`
    ///
    /// @since 1.0.0
    connection_timeout = optional(number, 10)

    /// Map of headers that CloudFront includes in all requests that it sends to
    /// your origin
    ///
    /// @since 1.0.0
    custom_headers = optional(map(string), {})

    /// Specify a URL path to append to the origin domain name for origin requests
    ///
    /// @since 1.0.0
    origin_path = optional(string, null)

    /// Configurations for [CloudFront custom origins][cloudfront-origins]
    ///
    /// @link {cloudfront-origins} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html
    /// @since 1.0.0
    custom_origin_config = optional(object({
      /// Specify the origin's HTTP port
      ///
      /// @since 1.0.0
      http_port = optional(number, 80)

      /// Specify the origin's HTTPS port
      ///
      /// @since 1.0.0
      https_port = optional(number, 443)

      /// The number of seconds that CloudFront maintains an idle connection with
      /// the origin, from `1 - 60`
      ///
      /// @since 1.0.0
      keep_alive_timeout = optional(number, 5)

      /// The minimum SSL protocol that CloudFront uses with the origin.
      ///
      /// @enum TLSv1.2|TLSv1.1|TLSv1|SSLv3
      /// @since 1.0.0
      minimum_ssl_protocol = optional(string, "TLSv1.2")

      /// The origin protocol policy determines the protocol (HTTP or HTTPS) that
      /// you want CloudFront to use when connecting to the origin.
      ///
      /// @enum http-only|https-only|match-viewer
      /// @since 1.0.0
      protocol_policy = optional(string, "https-only")

      /// The number of seconds that CloudFront waits for a response from the
      /// origin, from `1 - 60`
      ///
      /// @since 1.0.0
      response_timeout = optional(number, 30)
    }), null)

    /// [Origin shield][cloudfront-origin-shield] is an additional caching layer
    /// that can help reduce the load on your origin and help protect its
    /// availability
    ///
    /// @link {cloudfront-origin-shield} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html
    /// @since 1.0.0
    enable_origin_shield = optional(object({
      /// Specify the origin shield region
      ///
      /// @since 1.0.0
      region = string
    }), null)

    /// Configurations for [S3 origins][cloudfront-origins]
    ///
    /// @link {cloudfront-origins} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html
    /// @since 1.0.0
    s3_origin_config = optional(object({
      /// You can limit the access to your origin to only authenticated requests
      /// from CloudFront. We recommend using origin access control (OAC) in favor
      /// of origin access identity (OAI) for its wider range of features,
      /// including support of S3 buckets in all AWS Regions.
      ///
      /// @since 1.0.0
      origin_access = object({
        /// The ID of the origin access control to be associated to this origin.
        /// Mutually exclusive to `origin_access_identity`
        ///
        /// @since 1.0.0
        origin_access_control_id = optional(string, null)

        /// The ID of the origin access identity to be associated to this origin.
        /// Mutually exclusive to `origin_access_control_id`
        ///
        /// @since 1.0.0
        origin_access_identity = optional(string, null)
      })
    }), null)
  }))
  description = <<EOT
    Map of origins for this distribution.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the distribution

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "alternate_domain_names" {
  type        = list(string)
  description = <<EOT
    A list of custom domain names (CNAME) that you use in URLs for the files
    served by this distribution

    @since 1.0.0
  EOT
  default     = null
}

variable "custom_error_responses" {
  type = map(object({
    /// Specify the error caching minimum time to live (TTL), in seconds.
    ///
    /// @since 1.0.0
    error_caching_minimum_ttl = optional(number, 10)

    /// Specify the HTTP status code to return to the viewer. CloudFront can
    /// return a different status code to the viewer than what it received from
    /// the origin
    ///
    /// @since 1.0.0
    http_response_code = optional(number, null)

    /// Specify the path to the custom error response page.
    ///
    /// @since 1.0.0
    response_page_path = optional(string, null)
  }))
  description = <<EOT
    Configure CloudFront to return a custom error page for a matching HTTP status
    code.

    @link "Custom Error Response Documentation" https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html?icmpid=docs_cf_help_panel
    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = {}
}

variable "default_root_object" {
  type        = string
  description = <<EOT
    The object (file name) to return when a viewer requests the root URL (/)
    instead of a specific object

    @since 1.0.0
  EOT
  default     = null
}

variable "description" {
  type        = string
  description = <<EOT
    The description of the distribution

    @since 1.0.0
  EOT
  default     = null
}

variable "enable_ipv6" {
  type        = bool
  description = <<EOT
    Whether IPv6 is enabled for the distribution.

    @since 1.0.0
  EOT
  default     = false
}

variable "geographic_restrictions" {
  type = object({
    /// Whitelist a list of locations in this distribution. Please refer to
    /// [this file](./_common.tf) for a list of supported values.
    ///
    /// @since 1.0.0
    allow_list = optional(list(string), null)

    /// Blacklist a list of locations in this distribution. Please refer to
    /// [this file](./_common.tf) for a list of supported values.
    ///
    /// @since 1.0.0
    block_list = optional(list(string), null)
  })
  description = <<EOT
    Configures the CloudFront [geographic restriction][cloudfront-geographic-restriction].
    You can only specify one of `allow_list` or `block_list`. If none are
    specified, the distribution is unrestricted.

    @link {cloudfront-geographic-restriction} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html
    @since 1.0.0
  EOT
  default     = null
}

variable "max_http_version" {
  type        = string
  description = <<EOT
    Specify the max HTTP version this distribution supports.

    @enum http1.1|http2|http2and3|http3
    @since 1.0.0
  EOT
  default     = "http2"
}

variable "origin_groups" {
  type = map(object({
    /// Specify a list of members for this origin group
    ///
    /// @since 1.0.0
    origins = list(string)

    /// Specify the criteria for failover when CloudFront returns specific HTTP
    /// response status codes that indicate a failure
    ///
    /// @since 1.0.0
    failover_criteria = optional(list(number), [500])
  }))
  description = <<EOT
    Manages multiple [origin groups][cloudfront-origin-failover] for this
    distribution.

    @link {cloudfront-origin-failover} https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/high_availability_origin_failover.html
    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = {}
}

variable "price_class" {
  type        = string
  description = <<EOT
    Specify the price class for this distribution.

    - `PriceClass_100` - USA, Canada, Europe, & Israel
    - `PriceClass_200` - PriceClass_100 + South Africa, Kenya, Middle East, Japan, Singapore, South Korea, Taiwan, Hong Kong, & Philippines
    - `PriceClass_All` - All locations

    @enum PriceClass_100|PriceClass_200|PriceClass_All
    @since 1.0.0
  EOT
  default     = "PriceClass_All"
}

variable "viewer_certificate" {
  type = object({
    /// Associate a certificate from AWS Certificate Manager. The certificate must
    /// be in the US East (N. Virginia) Region (us-east-1). If not specified, the
    /// CloudFront default certificate will be used
    ///
    /// @since 1.0.0
    acm_certificate_arn = optional(string, null)

    /// The security policy determines the SSL or TLS protocol and the specific
    /// ciphers that CloudFront uses for HTTPS connections with viewers (clients).
    ///
    /// @enum TLSv1.2_2021|TLSv1.2_2019|TLSv1.2_2018|TLSv1.1_2016|TLSv1_2016|TLSv1
    /// @since 1.0.0
    security_policy = optional(string, "TLSv1.2_2021")

    /// Specify how you want CloudFront to serve HTTPS requests.
    ///
    /// @enum vip|sni-only|static-ip
    /// @since 1.0.0
    ssl_support_method = optional(string, "sni-only")
  })
  description = <<EOT
    Configure a custom SSL certificate for this distribution. If not specified,
    the CloudFront default certificate will be used.

    @since 1.0.0
  EOT
  default     = {}
}
