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

## Argument Reference

### Mandatory

- (map(object)) **`behaviors`** _[since v1.0.0]_

    Map of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0. The default behavior (`"*"`) must be specified. Please [see example](#basic-usage)

    - (string) **`target_origin`** _[since v1.0.0]_

        Name of the origin or origin group that you want CloudFront to route requests to when a request matches the path pattern

    - (string) **`cache_policy_name`** _[since v1.0.0]_

        The name of the [cache policy][cloudfront-cache-policy] that is attached to the cache behavior.

    - (list(string)) **`allowed_http_methods = ["GET", "HEAD"]`** _[since v1.0.0]_

        Controls which HTTP methods CloudFront processes and forwards to your origin. Valid values: `"GET"`, `"HEAD"`, `"OPTIONS"`, `"PUT"`, `"POST"`, `"PATCH"`, `"DELETE"`

    - (bool) **`compress_objects_automatically = true`** _[since v1.0.0]_

        Whether you want CloudFront to automatically compress content for web requests that include `Accept-Encoding: gzip` in the request header.

    - (string) **`field_level_encryption_id = null`** _[since v1.0.0]_

        Associate a [field-level encryption configuration][cloudfront-field-level-encryption-configuration] with the cache behavior

    - (string) **`origin_request_policy_name = null`** _[since v1.0.0]_

        Associate an [origin request policy][cloudfront-origin-request-policy] with the cache behavior

    - (string) **`realtime_log_config_arn = null`** _[since v1.0.0]_

        Associate a [real-time logs configuration][cloudfront-real-time-logs-configuration] with the cache behavior

    - (string) **`response_headers_policy_name = null`** _[since v1.0.0]_

        Associate a [response headers policy][cloudfront-response-headers-policy] with the cache behavior

    - (bool) **`smooth_streaming = false`** _[since v1.0.0]_

        Whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior

    - (list(string)) **`trusted_key_groups = null`** _[since v1.0.0]_

        List of key group IDs that CloudFront can use to validate signed URLs or signed cookies. Please refer to [this documentation][cloudfront-trusted-key-groups] for more information.

    - (string) **`viewer_protocol_policy = "redirect-to-https"`** _[since v1.0.0]_

        Specify the protocol that users can use to access the files in the origin when a request matches. Valid values: `"allow-all"`, `"https-only"`, `"redirect-to-https"`

    - (map(object)) **`function_associations = {}`** _[since v1.0.0]_

        Associate multiple edge functions (CloudFront Function or Lambda@Edge) to various cloudfront events. With edge functions you can write your own code to customize how your CloudFront distribution processes HTTP requests and responses. You can have up to four edge functions per cache behavior, one for each event type: `"viewer-request"`, `"viewer-response"`, `"origin-request"`, and `"origin-response"`. CloudFront Functions are only available for `"viewer-request"` and `viewer-response` event types. Please see [example](#basic-usage)

        - (string) **`function_arn`** _[since v1.0.0]_

            The ARN of a CloudFront function or Lambda@Edge function

        - (bool) **`include_body = false`** _[since v1.0.0]_

            When using Lambda@Edge, your function code can access the body of the HTTP request.

- (map(object)) **`origins`** _[since v1.0.0]_

    Map of origins for this distribution. Please [see example](#basic-usage)

    - (number) **`connection_attempts = 3`** _[since v1.0.0]_

        The number of times that CloudFront attempts to connect to the origin. Valid values: `1 - 3`

    - (number) **`connection_timeout = 10`** _[since v1.0.0]_

        The number of seconds that CloudFront waits for a response from the origin, from `1 - 10`

    - (map(string)) **`custom_headers = {}`** _[since v1.0.0]_

        Map of headers that CloudFront includes in all requests that it sends to your origin

    - (string) **`origin_path = null`** _[since v1.0.0]_

        Specify a URL path to append to the origin domain name for origin requests

    - (object) **`custom_origin_config = null`** _[since v1.0.0]_

        Configurations for [Cloudfront custom origins][cloudfront-origins]

        - (number) **`http_port = 80`** _[since v1.0.0]_

            Specify the origin's HTTP port

        - (number) **`https_port = 443`** _[since v1.0.0]_

            Specify the origin's HTTPS port

        - (number) **`keep_alive_timeout = 5`** _[since v1.0.0]_

            The number of seconds that CloudFront maintains an idle connection with the origin, from `1 - 60`

        - (string) **`minimum_ssl_protocol = "TLSv1.2"`** _[since v1.0.0]_

            The minimum SSL protocol that CloudFront uses with the origin. Valid values: `"TLSv1.2"`, `"TLSv1.1"`, `"TLSv1"`, `"SSLv3"`

        - (string) **`protocol_policy = "https-only"`** _[since v1.0.0]_

            The origin protocol policy determines the protocol (HTTP or HTTPS) that you want CloudFront to use when connecting to the origin. Valid values: `"http-only"`, `"https-only"`, `"match-viewer"`

        - (number) **`response_timeout = 30`** _[since v1.0.0]_

            The number of seconds that CloudFront waits for a response from the origin, from `1 - 60`

    - (object) **`enable_origin_shield = null`** _[since v1.0.0]_

        [Origin shield][cloudfront-origin-shield] is an additional caching layer that can help reduce the load on your origin and help protect its availability

        - (string) **`region`** _[since v1.0.0]_

            Specify the origin shield region

    - (object) **`s3_origin_config = null`** _[since v1.0.0]_

        Configurations for [S3 origins][cloudfront-origins]

        - (object) **`origin_access`** _[since v1.0.0]_

            You can limit the access to your origin to only authenticated requests from CloudFront. We recommend using origin access control (OAC) in favor of origin access identity (OAI) for its wider range of features, including support of S3 buckets in all AWS Regions.

            - (string) **`origin_access_control_id = null`** _[since v1.0.0]_

                The ID of the origin access control to be associated to this origin. Mutually exclusive to `origin_access_identity`

            - (string) **`origin_access_identity = null`** _[since v1.0.0]_

                The ID of the origin access identity to be associated to this origin. Mutually exclusive to `origin_access_control_id`

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the distribution

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (list(string)) **`alternate_domain_names = null`** _[since v1.0.0]_

    A list of custom domain names (CNAME) that you use in URLs for the files served by this distribution

- (map(object)) **`custom_error_responses = {}`** _[since v1.0.0]_

    Configure CloudFront to return a custom error page for a matching HTTP status code. Please refer to [this documentation][cloudfront-custom-error-response] for more information. See [example](#basic-usage)

    - (number) **`error_caching_minimum_ttl = 10`** _[since v1.0.0]_

        Specify the error caching minimum time to live (TTL), in seconds.

    - (number) **`http_response_code = null`** _[since v1.0.0]_

        Specify the HTTP status code to return to the viewer. CloudFront can return a different status code to the viewer than what it received from the origin

    - (string) **`response_page_path = null`** _[since v1.0.0]_

        Specify the path to the custom error response page.

- (string) **`default_root_object = null`** _[since v1.0.0]_

    The object (file name) to return when a viewer requests the root URL (/) instead of a specific object

- (string) **`description = null`** _[since v1.0.0]_

    The description of the distribution

- (bool) **`enable_ipv6 = false`** _[since v1.0.0]_

    Whether the IPv6 is enabled for the distribution.

- (object) **`geographic_restrictions = null`** _[since v1.0.0]_

    Configures the CloudFront [geographic restriction][cloudfront-geographic-restriction]. You can only specify one of `allow_list` or `block_list`. If none are specified, the distribution is unrestricted.

    - (list(string)) **`allow_list = null`** _[since v1.0.0]_

        Whitelist a list of locations in this distribution. Please refer to [this file](./_common.tf) for a list of supported values.

    - (list(string)) **`block_list = null`** _[since v1.0.0]_

        Blacklist a list of locations in this distribution. Please refer to [this file](./_common.tf) for a list of supported values.

- (string) **`max_http_version = "http2"`** _[since v1.0.0]_

    Specify the max HTTP version this distribution supports. Valid values: `"http1.1"`, `"http2"`, `"http2and3"`, `"http3"`

- (map(object)) **`origin_groups = {}`** _[since v1.0.0]_

    Manages multiple [origin groups][cloudfront-origin-failover] for this distribution. Please see [example](#basic-usage)

    - (list(string)) **`origins`** _[since v1.0.0]_

        Specify a list of members for this origin group

    - (list(number)) **`failover_criteria = [500]`** _[since v1.0.0]_

        Specify the criteria for failover when CloudFront returns specific HTTP response status codes that indicate a failure

- (string) **`price_class = "PriceClass_All"`** _[since v1.0.0]_

    Specify the price class for this distribution. Valid values:

    - `"PriceClass_100"` - USA, Canada, Europe, & Israel
    - `"PriceClass_200"` - PriceClass_100 + South Africa, Kenya, Middle East, Japan, Singapore, South Korea, Taiwan, Hong Kong, & Philippines
    - `"PriceClass_All"` - All locations

- (object) **`viewer_certificate = {}`** _[since v1.0.0]_

    Configure a custom SSL certificate for this distribution. If not specified, the Cloudfront default certificate will be used.

    - (string) **`acm_certificate_arn = null`** _[since v1.0.0]_

        Associate a certificate from AWS Certificate Manager. The certificate must be in the US East (N. Virginia) Region (us-east-1). If not specified, the Cloudfront default certificate will be used

    - (string) **`security_policy = "TLSv1.2_2021"`** _[since v1.0.0]_

        The security policy determines the SSL or TLS protocol and the specific ciphers that CloudFront uses for HTTPS connections with viewers (clients). Valid values: `"TLSv1.2_2021"`, `"TLSv1.2_2019"`, `"TLSv1.2_2018"`, `"TLSv1.1_2016"`, `"TLSv1_2016"`, `"TLSv1"`

    - (string) **`ssl_support_method = "sni-only"`** _[since v1.0.0]_

        Specify how you want CloudFront to serve HTTPS requests. Valid values: `"vip"`, `"sni-only"`, `"static-ip"`

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
