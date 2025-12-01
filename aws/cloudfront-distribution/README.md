# Cloudfront Distribution Module

This module will build and configure a [CloudFront Distribution](https://aws.amazon.com/cloudfront/).

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-cloudfront-distribution.git?ref=v1.0.0"

  # manages multiple origins
  origins = {
    # the key of the map is the origin's domain name
    "psin-test-useast1.s3.us-east-1.amazonaws.com"  = {}
    "psin-test-uswest1.s3.us-west-1.amazonaws.com" = {}
  }

  # manages multiple origin groups
  origin_groups = {
    # the key of the map is the origin group's name
    "s3-group" = {
      origins = [
        "psin-test-useast1.s3.us-east-1.amazonaws.com",
        "psin-test-uswest1.s3.us-west-1.amazonaws.com"
      ]

      failover_criteria = [400, 500]
    }
  }

  # manages multiple behaviors in order of decreasing precedence
  behaviors = {
    # the key of the map is the path pattern to match
    # the default behavior "*" must be specified
    "*" = {
      target_origin     = "s3-group" # using an origin group as target
      cache_policy_name = "Managed-CachingOptimized"

      function_associations = {
        "viewer-request"  = { function_arn = "arn:aws:cloudfront::111122223333:function/psin-test" }
        "viewer-response" = { function_arn = "arn:aws:cloudfront::111122223333:function/psin-test" }
        "origin-request"  = { function_arn = "arn:aws:lambda:us-east-1:111122223333:function:psin-test:1" }
        "origin-response" = { function_arn = "arn:aws:lambda:us-east-1:111122223333:function:psin-test:1" }
      }
    }

    "/image" = {
      target_origin     = "psin-test-useast1.s3.us-east-1.amazonaws.com" # using a specific origin as target
      cache_policy_name = "Managed-CachingOptimized"
    }
  }

  geographic_restrictions = {
    allow_list = ["United States", "United Kingdom"]
  }

  # manages multiple custom error responses
  custom_error_responses = {
    # the key of the map is the http error code to match
    400 = {}
    500 = {}
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object({
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
  }))</code></td>
    <td width="100%">behaviors</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of cache behaviors resource for this distribution. List from top to
bottom in order of precedence. The topmost cache behavior will have
precedence 0. The default behavior (`"*"`) must be specified.

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#origins">Origins</a>))</code></td>
    <td width="100%">origins</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of origins for this distribution.

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

### Optional



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the distribution

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">alternate_domain_names</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of custom domain names (CNAME) that you use in URLs for the files
served by this distribution

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#customerrorresponses">CustomErrorResponses</a>))</code></td>
    <td width="100%">custom_error_responses</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configure CloudFront to return a custom error page for a matching HTTP status
code.

    
**Examples:**
- [Basic Usage](#basic-usage)

    
**Links:**
- [Custom Error Response Documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html?icmpid=docs_cf_help_panel)

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">default_root_object</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The object (file name) to return when a viewer requests the root URL (/)
instead of a specific object

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description of the distribution

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_ipv6</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether IPv6 is enabled for the distribution.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#geographicrestrictions">GeographicRestrictions</a>)</code></td>
    <td width="100%">geographic_restrictions</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the CloudFront [geographic restriction][cloudfront-geographic-restriction].
You can only specify one of `allow_list` or `block_list`. If none are
specified, the distribution is unrestricted.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">max_http_version</td>
    <td><code>"http2"</code></td>
</tr>
<tr><td colspan="3">

Specify the max HTTP version this distribution supports.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object({
    /// Specify a list of members for this origin group
    ///
    /// @since 1.0.0
    origins = list(string)

    /// Specify the criteria for failover when CloudFront returns specific HTTP
    /// response status codes that indicate a failure
    ///
    /// @since 1.0.0
    failover_criteria = optional(list(number), [500])
  }))</code></td>
    <td width="100%">origin_groups</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple [origin groups][cloudfront-origin-failover] for this
distribution.

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">price_class</td>
    <td><code>"PriceClass_All"</code></td>
</tr>
<tr><td colspan="3">

Specify the price class for this distribution.

- `PriceClass_100` - USA, Canada, Europe, & Israel
- `PriceClass_200` - PriceClass_100 + South Africa, Kenya, Middle East, Japan, Singapore, South Korea, Taiwan, Hong Kong, & Philippines
- `PriceClass_All` - All locations

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#viewercertificate">ViewerCertificate</a>)</code></td>
    <td width="100%">viewer_certificate</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configure a custom SSL certificate for this distribution. If not specified,
the CloudFront default certificate will be used.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

### Objects



#### CustomErrorResponses



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">error_caching_minimum_ttl</td>
    <td><code>10</code></td>
</tr>
<tr><td colspan="3">

Specify the error caching minimum time to live (TTL), in seconds.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">http_response_code</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the HTTP status code to return to the viewer. CloudFront can
return a different status code to the viewer than what it received from
the origin

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">response_page_path</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the path to the custom error response page.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### CustomOriginConfig

Configurations for [CloudFront custom origins][cloudfront-origins]

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">http_port</td>
    <td><code>80</code></td>
</tr>
<tr><td colspan="3">

Specify the origin's HTTP port

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">https_port</td>
    <td><code>443</code></td>
</tr>
<tr><td colspan="3">

Specify the origin's HTTPS port

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">keep_alive_timeout</td>
    <td><code>5</code></td>
</tr>
<tr><td colspan="3">

The number of seconds that CloudFront maintains an idle connection with
the origin, from `1 - 60`

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">minimum_ssl_protocol</td>
    <td><code>"TLSv1.2"</code></td>
</tr>
<tr><td colspan="3">

The minimum SSL protocol that CloudFront uses with the origin.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">protocol_policy</td>
    <td><code>"https-only"</code></td>
</tr>
<tr><td colspan="3">

The origin protocol policy determines the protocol (HTTP or HTTPS) that
you want CloudFront to use when connecting to the origin.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">response_timeout</td>
    <td><code>30</code></td>
</tr>
<tr><td colspan="3">

The number of seconds that CloudFront waits for a response from the
origin, from `1 - 60`

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnableOriginShield

[Origin shield][cloudfront-origin-shield] is an additional caching layer
that can help reduce the load on your origin and help protect its
availability

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">region</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the origin shield region

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### GeographicRestrictions



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">allow_list</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Whitelist a list of locations in this distribution. Please refer to
[this file](./_common.tf) for a list of supported values.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">block_list</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Blacklist a list of locations in this distribution. Please refer to
[this file](./_common.tf) for a list of supported values.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### OriginAccess

You can limit the access to your origin to only authenticated requests
from CloudFront. We recommend using origin access control (OAC) in favor
of origin access identity (OAI) for its wider range of features,
including support of S3 buckets in all AWS Regions.

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">origin_access_control_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ID of the origin access control to be associated to this origin.
Mutually exclusive to `origin_access_identity`

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">origin_access_identity</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ID of the origin access identity to be associated to this origin.
Mutually exclusive to `origin_access_control_id`

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Origins



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">connection_attempts</td>
    <td><code>3</code></td>
</tr>
<tr><td colspan="3">

The number of times that CloudFront attempts to connect to the origin.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">connection_timeout</td>
    <td><code>10</code></td>
</tr>
<tr><td colspan="3">

The number of seconds that CloudFront waits for a response from the
origin, from `1 - 10`

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">custom_headers</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Map of headers that CloudFront includes in all requests that it sends to
your origin

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">origin_path</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify a URL path to append to the origin domain name for origin requests

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#customoriginconfig">CustomOriginConfig</a>)</code></td>
    <td width="100%">custom_origin_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configurations for [CloudFront custom origins][cloudfront-origins]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enableoriginshield">EnableOriginShield</a>)</code></td>
    <td width="100%">enable_origin_shield</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

[Origin shield][cloudfront-origin-shield] is an additional caching layer
that can help reduce the load on your origin and help protect its
availability

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#s3originconfig">S3OriginConfig</a>)</code></td>
    <td width="100%">s3_origin_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configurations for [S3 origins][cloudfront-origins]

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### S3OriginConfig

Configurations for [S3 origins][cloudfront-origins]

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#originaccess">OriginAccess</a>)</code></td>
    <td width="100%">origin_access</td>
    <td></td>
</tr>
<tr><td colspan="3">

You can limit the access to your origin to only authenticated requests
from CloudFront. We recommend using origin access control (OAC) in favor
of origin access identity (OAI) for its wider range of features,
including support of S3 buckets in all AWS Regions.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ViewerCertificate



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">acm_certificate_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Associate a certificate from AWS Certificate Manager. The certificate must
be in the US East (N. Virginia) Region (us-east-1). If not specified, the
CloudFront default certificate will be used

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">security_policy</td>
    <td><code>"TLSv1.2_2021"</code></td>
</tr>
<tr><td colspan="3">

The security policy determines the SSL or TLS protocol and the specific
ciphers that CloudFront uses for HTTPS connections with viewers (clients).

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ssl_support_method</td>
    <td><code>"sni-only"</code></td>
</tr>
<tr><td colspan="3">

Specify how you want CloudFront to serve HTTPS requests.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[cloudfront-geographic-restriction]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html

[cloudfront-origin-failover]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/high_availability_origin_failover.html

[cloudfront-origin-shield]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html

[cloudfront-origins]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html


<!-- TFDOCS_EXTRAS_END -->

## Outputs

- (string) **`distribution_arn`** _[since v1.0.0]_

    ARN for the distribution

- (string) **`distribution_domain_name`** _[since v1.0.0]_

    Domain name corresponding to the distribution.

- (string) **`distribution_hosted_zone_id`** _[since v1.0.0]_

    CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to.

- (string) **`distribution_id`** _[since v1.0.0]_

    Identifier for the distribution

[cloudfront-cache-policy]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-the-cache-key.html
[cloudfront-custom-error-response]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html?icmpid=docs_cf_help_panel
[cloudfront-field-level-encryption-configuration]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/field-level-encryption.html
[cloudfront-geographic-restriction]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html
[cloudfront-origin-failover]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/high_availability_origin_failover.html
[cloudfront-origin-request-policy]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-origin-requests.html
[cloudfront-origin-shield]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html
[cloudfront-origins]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html
[cloudfront-real-time-logs-configuration]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/real-time-logs.html
[cloudfront-response-headers-policy]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/understanding-response-headers-policies.html
[cloudfront-trusted-key-groups]:https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html
