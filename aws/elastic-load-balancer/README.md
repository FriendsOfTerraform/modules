# Elastic Load Balancer Module

This module creates and configures a [Elastic Load Balancer](https://aws.amazon.com/elb/) and its associated listeners and rules

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Application Load Balacner](#application-load-balancer)
    - [Gateway Load Balacner](#gateway-load-balancer)
    - [Network Load Balacner](#network-load-balancer)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Application Load Balacner

```terraform
module "application_load_balancer" {
  source = "github.com/FriendsOfTerraform/aws-elastic-load-balancer.git?ref=v1.0.0"

  name               = "application-load-balancer"
  security_group_ids = ["sg-01701234567abcdef"]

  network_mapping = {
    subnets = {
      subnet-02b36c9f06aabcdef = {}
      subnet-0dd00f2963fabcdef = {}
    }
  }

  application_load_balancer = {
    # manage multiple listeners
    # the keys of the map are the listener's <protocol>:<port>
    listeners = {
      "HTTP:80" = {
        default_action = { fixed_response = { response_code = 503 } }
      }

      "HTTPS:443" = {
        default_action              = { fixed_response = { response_code = 503 } }
        default_ssl_certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/01234567-d3c2-4e3c-8be2-012345abcdef"

        # manages multiple listener rules
        # the keys of the map are the rule's name
        rules = {
          path-example = {
            priority = 1
            conditions = [
              { paths = ["/helloworld*", "/foobar*"] } # matches "/helloworld*" OR "/foobar*"(2 values)
            ]
            action = {
              forward = {
                target_groups = {
                  "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/demo-alb-target/59b4abdd020985d7"  = { weight = 50 }
                  "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/demo-alb-target2/b6882cdc912f4c5b" = { weight = 50 }
                }
              }
            }
          }

          http-header-example = {
            priority = 2
            conditions = [
              # http_headers can be specified multiple times
              # this rule is matched if:
              # (http header "hello" exists with the value "world" OR "worldz") AND (http header "quz" exists with the value "quux")
              { http_headers = { hello = ["world", "worldz*"] } },
              { http_headers = { quz = ["quux"] } }
            ]
            action = {
              # You can retain the URI components of the incoming request using the following reserved keywords: #{protocol}, #{host}, #{port}, #{path}, and #{query}
              redirect = { url = "https://#{host}/helloworld?#{query}" }
            }
          }

          query-string-example = {
            priority = 3
            conditions = [
              # query_strings can be specified multiple times
              # this rule is matched if:
              # (query string "hello = world" OR "foo = bar")(2 values) AND (query string "quz = quux")(1 value)
              { query_strings = { hello = "world", foo = "bar" } },
              { query_strings = { quz = "quux" } }
            ]
            action = {
              fixed_response = {
                response_code = 200
                response_body = "The page is not yet complete, please come back later"
              }
            }
          }

          multi-conditions-example = {
            priority = 100
            conditions = [
              # You can specify multiple conditions to match, with a maximum of 5 values per rule
              # this rule is matched if:
              # (host headers equal "demo-dev" OR "demo-uat")(2 values) AND (http request methods equal "GET" OR "LIST")(2 values) AND (source IP equal "10.0.0.0/16")(1 value)
              { host_headers = ["demo.dev", "demo.uat"] },
              { http_request_methods = ["GET", "LIST"] },
              { source_ips = ["10.0.0.0/16"] }
            ]
            action = {
              forward = {
                target_groups = {
                  "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/demo-alb-target3/945877ef1b3048cd" = {}
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### Gateway Load Balancer

```terraform
module "gateway_load_balancer" {
  source = "github.com/FriendsOfTerraform/aws-elastic-load-balancer.git?ref=v1.0.0"

  name = "gateway-load-balancer"

  network_mapping = {
    subnets = {
      subnet-02b36c9f06aabcdef = {}
      subnet-0dd00f2963fabcdef = {}
    }
  }

  gateway_load_balancer = {
    listener = {
      default_action = { forward = { target_group = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/demo-gateway-target/0095746f91b7b4f771" } }
    }
  }
}
```

### Network Load Balancer

```terraform
module "network_load_balancer" {
  source = "github.com/FriendsOfTerraform/aws-elastic-load-balancer.git?ref=v1.0.0"

  name               = "network-load-balancer"
  security_group_ids = ["sg-01701234567abcdef"]

  network_mapping = {
    subnets = {
      subnet-02b36c9f06aabcdef = {}
      subnet-0dd00f2963fabcdef = {}
    }
  }

  network_load_balancer = {
    listeners = {
      "TCP:80" = {
        default_action = { forward = { target_group = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/demo-nlb-target/4e43bf2d0b825230" } }
      }
      "TLS:443" = {
        default_action              = { forward = { target_group = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/demo-nlb-target/4e43bf2d0b825230" } }
        default_ssl_certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/01234567-d3c2-4e3c-8be2-012345abcdef"
      }
    }

    attributes = {
      enable_cross_zone_load_balancing = true
    }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the load balancer. All associated resources will also have their name prefixed with this value

- (object) **`network_mapping = []`** _[since v1.0.0]_

    The networking configuration of the load balancer

    - (map(object)) **`subnets`** _[since v1.0.0]_

        Map of subnet ARNs where the load balancer routes traffic to. You can only specify one subnet per availability zone. If you enabled dual-stack mode for the load balancer, select subnets with associated IPv6 CIDR blocks. You must specify at least two subnets

        - (string) **`elastic_ip_allocation_id = null`** _[since v1.0.0]_

            Specify an elastic IP allocation ID to provide your load balancer with a static IPv4 address in the selected Availability Zone. Only applicable to `network_load_balancer`

        - (string) **`ipv6_address = null`** _[since v1.0.0]_

            The front-end IPv6 address of the load balancer in the selected Availability Zone. It can be any available IP address within the subnet’s CIDR. Only applicable to `network_load_balancer`

        - (string) **`private_ipv4_address = null`** _[since v1.0.0]_

            Private IPv4 address for an internal load balancer. It can be any available IP address within the subnet’s CIDR. Only applicable to `network_load_balancer` and `internet_facing = false`

    - (string) **`ipam_pool_id = null`** _[since v1.0.0]_

        The ID of the IPAM pool to use with this load balancer. IPAM pools allow your Application Load Balancers to use IPv4 addresses you own. Only applicable to `application_load_balancer` and `internet_facing = true`

### Optional


- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the load balancer

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (object) **`application_load_balancer = null`** _[since v1.0.0]_

    Specify an Application load balancer. Mutually exclusive to `gateway_load_balancer`, `network_load_balancer`. Please [see example](#application-load-balacner)

    - (map(object)) **`listeners`** _[since v1.0.0]_

        Map of listeners in the `<protocol>:<port>` format

        - (object) **`default_action`** _[since v1.0.0]_

            Specify the default action that triggers if no other rules are matched for the incoming requests. Must specify only one of the following: `authenticate_users.amazon_cognito`, `authenticate_users.oidc`, `fixed_response`, `forward`, `redirect`

            - (object) **`authenticate_users = null`** _[since v1.0.0]_

                Configure user authentication through either OpenID Connect (OIDC) or Amazon Cognito. Please refer to [this documentation][alb-user-authentication] for prerequisites for both methods.

                - (string) **`action_on_unauthenticatedd_request = "authenticate"`** _[since v1.0.0]_

                    The response to a request from a user that is not authenticated. Valid values: `"authenticate"`, `"allow"`, `"deny"`

                - (map(string)) **`extra_request_parameters = {}`** _[since v1.0.0]_

                    A map of extra parameters to pass to the identity provider (IdP) during authentication

                - (string) **`scope = "openid"`** _[since v1.0.0]_

                    The attributes to be requested by the identity provider (IdP).

                - (string) **`session_cookie_name = "AWSELBAuthSessionCookie"`** _[since v1.0.0]_

                    The name of the cookie used to maintain session information.

                - (string) **`session_timeout = "7 days"`** _[since v1.0.0]_

                    The maximum time allowed for an authenticated session after which re-authentication will be required. Valid values: `"1 second" - "7 days"`

                - (object) **`amazon_cognito = null`** _[since v1.0.0]_

                    Configures an Amazon Cognito IdP for authentication

                    - (string) **`app_client`** _[since v1.0.0]_

                        ID of the Cognito user pool client.

                    - (string) **`user_pool`** _[since v1.0.0]_

                        The ARN of the Cognito user pool

                    - (string) **`user_pool_domain`** _[since v1.0.0]_

                        Domain prefix or fully-qualified domain name of the Cognito user pool.

                - (object) **`oidc = null`** _[since v1.0.0]_

                    Configures an Open ID Connect (OIDC) IdP for authentication

                    - (string) **`authorization_endpoint`** _[since v1.0.0]_

                        OpenID provider server endpoint.

                    - (string) **`client_id`** _[since v1.0.0]_

                        The ID of an app client in your user pool.

                    - (string) **`client_secret`** _[since v1.0.0]_

                        Provide a client secret associated with this client ID.

                    - (string) **`issuer`** _[since v1.0.0]_

                        OpenID provider.

                    - (string) **`token_endpoint`** _[since v1.0.0]_

                        URL of your token endpoint.

                    - (string) **`user_info_endpoint`** _[since v1.0.0]_

                        URL of your user info endpoint.

                - (object) **`fixed_response = null`** _[since v1.0.0]_

                    Configurate fixed-response action to drop client requests and return a custom HTTP response. When a fixed-response action is taken, the action and the URL of the redirect target are recorded in the access logs.

                    - (string) **`content_type = "text/plain"`** _[since v1.0.0]_

                        The format of your message. Valid values: `"text/plain"`, `"text/css"`, `"text/html"`, `"application/javascript"`, `"application/json"`

                    - (string) **`response_body = null`** _[since v1.0.0]_

                        The message body of the response

                    - (number) **`response_code = 503`** _[since v1.0.0]_

                        HTTP response code. Valid values: `2XX`, `4XX`, `5XX`

                - (object) **`forward = null`** _[since v1.0.0]_

                    Configure forward action to route requests to one or more target groups.

                    - (map(object)) **`target_groups`** _[since v1.0.0]_

                        Map of destination target groups in `<target_group_arn> = {<config>}` format. Please [see example](#application-load-balacner). You can only specify up to 5 target groups.

                        - (number) **`weight = null`** _[since v1.0.0]_

                            Specify a weight that controls the prioritization and selection of each target group. Weights must be set as an integer between `0 - 999`.

                    - (object) **`turn_on_target_group_stickiness = null`** _[since v1.0.0]_

                        Enables the load balancer to bind a user's session to a specific target group. To use stickiness the client must support cookies. If you want to bind a user's session to a specific target, turn on the Target Group attribute Stickiness.

                        - (string) **`duration = "1 hour"`** _[since v1.0.0]_

                            The stickiness duration. Valid values: `"1 second" - "7 days"`

                - (object) **`redirect = null`** _[since v1.0.0]_

                    Redirect client requests from one URL to another. You cannot redirect HTTPS to HTTP.

                    - (string) **`url`** _[since v1.0.0]_

                        The redirect URL. You can retain URI components of the original URL in the target URL by using the following reserved keywords:

                        | Keyword     | Description
                        |-------------|-------------------------------------------------------------------------
                        | #{protocol} | Retains the protocol. Use it in the protocol and query components.
                        | #{host}     | Retains the domain. Use it in the hostname, path, and query components.
                        | #{port}     | Retains the port. Use it in the port, path, and query components.
                        | #{path}     | Retains the path. Use it in the path and query components.
                        | #{query}    | Retains the query parameters. Use it in the query component.

                        To avoid a redirect loop, you must modify at least one of the following components: protocol, port, hostname or path.

                    - (number) **`status_code = 301`** _[since v1.0.0]_

                        HTTP response code. Valid values: `301`, `302`

        - (object) **`enable_mutual_authentication = null`** _[since v1.0.0]_

            Enable mTLS. Configure how the listener handles requests that present client certificates. This includes how the load balancer authenticates certificates and the amount of certificate metadata that is sent to the backend targets.

            - (object) **`verify_with_trust_store = null`** _[since v1.0.0]_

                The load balancer and client verify each other's identity and establish a TLS connection to encrypt communication between them. If this is not specified, the incoming certificate will be sent to the backend target as-it (`Passthrough`)

                - (bool) **`advertise_trust_store_ca_subject_name = false`** _[since v1.0.0]_

                    Whether the listener will advertise the Certificate Authorities (CAs) subject names trusted by its trust store.

                - (bool) **`allow_expired_client_certificates = false`** _[since v1.0.0]_

                    Whether incoming connection requests with an expired client certificates should be allowed

                - (string) **`trust_store_arn = null`** _[since v1.0.0]_

                    An existing trust store that contain the certificate authority (CA) bundle that you trust to identify clients. Mutually exclusive to `new_trust_store`

                - (object) **`new_trust_store = null`** _[since v1.0.0]_

                    Create a new trust store using an existing CA bundle and optionally certificate revocation lists. Mutually exclusive to `trust_store_arn`

                    - (object) **`certificate_authority_bundle`** _[since v1.0.0]_

                        The CA bundle

                        - (string) **`s3_uri`** _[since v1.0.0]_

                            The S3 URI where the CA bundle resides. For example: `"s3://demo-bucket/ca-bundles/ca.pem"`

                        - (string) **`version = null`** _[since v1.0.0]_

                            The S3 version ID of the CA bundle

                    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

                        Additional tags for the trust store

                    - (map(object)) **`certificate_revocation_lists = {}`** _[since v1.0.0]_

                        Map of CRLs to be imported into the trust store. The keys of the map are the S3 URI where the CRL resides.

                        - (string) **`version = null`** _[since v1.0.0]_

                            The S3 version ID of the CRL

        - (map(object)) **`rules = {}`** _[since v1.0.0]_

            Configure multiple listener rules

            - (number) **`priority`** _[since v1.0.0]_

                The rule priority. Rules are evaluated in priority order from the lowest value to the highest value.

            - (object) **`action`** _[since v1.0.0]_

                The action to trigger when an incoming request matches all conditions.

                - (object) **`authenticate_users = null`** _[since v1.0.0]_

                    Configure user authentication through either OpenID Connect (OIDC) or Amazon Cognito. Please refer to [this documentation][alb-user-authentication] for prerequisites for both methods.

                    - (string) **`action_on_unauthenticatedd_request = "authenticate"`** _[since v1.0.0]_

                        The response to a request from a user that is not authenticated. Valid values: `"authenticate"`, `"allow"`, `"deny"`

                    - (map(string)) **`extra_request_parameters = {}`** _[since v1.0.0]_

                        A map of extra parameters to pass to the identity provider (IdP) during authentication

                    - (string) **`scope = "openid"`** _[since v1.0.0]_

                        The attributes to be requested by the identity provider (IdP).

                    - (string) **`session_cookie_name = "AWSELBAuthSessionCookie"`** _[since v1.0.0]_

                        The name of the cookie used to maintain session information.

                    - (string) **`session_timeout = "7 days"`** _[since v1.0.0]_

                        The maximum time allowed for an authenticated session after which re-authentication will be required. Valid values: `"1 second" - "7 days"`

                    - (object) **`amazon_cognito = null`** _[since v1.0.0]_

                        Configures an Amazon Cognito IdP for authentication

                        - (string) **`app_client`** _[since v1.0.0]_

                            ID of the Cognito user pool client.

                        - (string) **`user_pool`** _[since v1.0.0]_

                            The ARN of the Cognito user pool

                        - (string) **`user_pool_domain`** _[since v1.0.0]_

                            Domain prefix or fully-qualified domain name of the Cognito user pool.

                    - (object) **`oidc = null`** _[since v1.0.0]_

                        Configures an Open ID Connect (OIDC) IdP for authentication

                        - (string) **`authorization_endpoint`** _[since v1.0.0]_

                            OpenID provider server endpoint.

                        - (string) **`client_id`** _[since v1.0.0]_

                            The ID of an app client in your user pool.

                        - (string) **`client_secret`** _[since v1.0.0]_

                            Provide a client secret associated with this client ID.

                        - (string) **`issuer`** _[since v1.0.0]_

                            OpenID provider.

                        - (string) **`token_endpoint`** _[since v1.0.0]_

                            URL of your token endpoint.

                        - (string) **`user_info_endpoint`** _[since v1.0.0]_

                            URL of your user info endpoint.

                    - (object) **`fixed_response = null`** _[since v1.0.0]_

                        Configurate fixed-response action to drop client requests and return a custom HTTP response. When a fixed-response action is taken, the action and the URL of the redirect target are recorded in the access logs.

                        - (string) **`content_type = "text/plain"`** _[since v1.0.0]_

                            The format of your message. Valid values: `"text/plain"`, `"text/css"`, `"text/html"`, `"application/javascript"`, `"application/json"`

                        - (string) **`response_body = null`** _[since v1.0.0]_

                            The message body of the response

                        - (number) **`response_code = 503`** _[since v1.0.0]_

                            HTTP response code. Valid values: `2XX`, `4XX`, `5XX`

                    - (object) **`forward = null`** _[since v1.0.0]_

                        Configure forward action to route requests to one or more target groups.

                        - (map(object)) **`target_groups`** _[since v1.0.0]_

                            Map of destination target groups in `<target_group_arn> = {<config>}` format. Please [see example](#application-load-balacner). You can only specify up to 5 target groups.

                            - (number) **`weight = null`** _[since v1.0.0]_

                                Specify a weight that controls the prioritization and selection of each target group. Weights must be set as an integer between `0 - 999`.

                        - (object) **`turn_on_target_group_stickiness = null`** _[since v1.0.0]_

                            Enables the load balancer to bind a user's session to a specific target group. To use stickiness the client must support cookies. If you want to bind a user's session to a specific target, turn on the Target Group attribute Stickiness.

                            - (string) **`duration = "1 hour"`** _[since v1.0.0]_

                                The stickiness duration. Valid values: `"1 second" - "7 days"`

                    - (object) **`redirect = null`** _[since v1.0.0]_

                        Redirect client requests from one URL to another. You cannot redirect HTTPS to HTTP.

                        - (string) **`url`** _[since v1.0.0]_

                            The redirect URL. You can retain URI components of the original URL in the target URL by using the following reserved keywords:

                            | Keyword     | Description
                            |-------------|-------------------------------------------------------------------------
                            | #{protocol} | Retains the protocol. Use it in the protocol and query components.
                            | #{host}     | Retains the domain. Use it in the hostname, path, and query components.
                            | #{port}     | Retains the port. Use it in the port, path, and query components.
                            | #{path}     | Retains the path. Use it in the path and query components.
                            | #{query}    | Retains the query parameters. Use it in the query component.

                            To avoid a redirect loop, you must modify at least one of the following components: protocol, port, hostname or path.

                        - (number) **`status_code = 301`** _[since v1.0.0]_

                            HTTP response code. Valid values: `301`, `302`

            - (list(object)) **`conditions`** _[since v1.0.0]_

                Specify specific conditions a request must match for the rules actions to be performed. You can specify up to 5 condition values per rule. Please [see example](#application-load-balacner)

                - (list(string)) **`host_headers = null`** _[since v1.0.0]_

                    A list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: `*` (matches 0 or more characters) and `?` (matches exactly 1 character).

                - (map(list(string))) **`http_headers = {}`** _[since v1.0.0]_

                    HTTP headers to match. This condition can be specified multiple times.

                - (list(string)) **`http_request_methods = null`** _[since v1.0.0]_

                    A list of HTTP request methods or verbs to match. Maximum size is 40 characters. Only allowed characters are A-Z, hyphen (-) and underscore (_). Comparison is case sensitive. Wildcards are not supported.

                - (list(string)) **`paths = null`** _[since v1.0.0]_

                    A list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters. Comparison is case sensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character).

                - (map(string)) **`query_strings = {}`** _[since v1.0.0]_

                    Query strings to match. This condition can be specified multiple times.

                - (list(string)) **`source_ips = null`** _[since v1.0.0]_

                    A list of source IP CIDR notations to match. You can use both IPv4 and IPv6 addresses. Wildcards are not supported.

            - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

                Additional tags for the listener rule

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags for the listener

        - (object) **`attributes = {}`** _[since v1.0.0]_

            Configure listener attributes

            - (bool) **`add_alb_server_response_header = true`** _[since v1.0.0]_

                Whether your Application Load Balancer adds a response header with value `awselb/2.0`.

            - (object) **`add_response_headers = {}`** _[since v1.0.0]_

                Control whether your Application Load Balancer adds certain headers to HTTP responses. If the HTTP response from your load balancer's target already includes a header, the load balancer will overwrite it with the configured value.

                - (string) **`access_control_allow_credentials = null`** _[since v1.0.0]_

                    Specifies whether the client should include credentials such as cookies, HTTP authentication or client certificates in cross-origin requests.

                - (string) **`access_control_allow_headers = null`** _[since v1.0.0]_

                    Specifies which custom or non-simple headers can be included in a cross-origin request. This header gives targets control over which headers can be sent by clients from different origins.

                - (string) **`access_control_allow_methods = null`** _[since v1.0.0]_

                    Specifies the HTTP methods that are allowed when making cross-origin requests to the target. It provides control over which actions can be performed from different origins.

                - (string) **`access_control_allow_origin = null`** _[since v1.0.0]_

                    Controls whether resources on a target can be accessed from different origins. This allows secure cross-origin interactions while preventing unauthorized access.

                - (string) **`access_control_expose_headers = null`** _[since v1.0.0]_

                    Allows the target to specify which additional response headers can be access by the client in cross-origin requests.

                - (string) **`access_control_max_age = null`** _[since v1.0.0]_

                    Defines how long the browser can cache the result of a preflight request, reducing the need for repeated preflight checks. This helps to optimize performance by reducing the number of OPTIONS requests required for certain cross-origin requests.

                - (string) **`content_security_policy = null`** _[since v1.0.0]_

                    Security feature that prevents code injection attacks like XSS by controlling which resources such as scripts, styles, images, etc. can be loaded and executed by a website.

                - (string) **`http_strict_transport_security = null`** _[since v1.0.0]_

                    Enforces HTTPS-only connections by the browser for a specified duration

                - (string) **`x_content_type_options = null`** _[since v1.0.0]_

                    With the no-sniff directive, enhances web security by preventing browsers from guessing the MIME type of a resource. It ensures that browsers only interpret content according to the declared Content-Type

                - (string) **`x_frame_options = null`** _[since v1.0.0]_

                    Header security mechanism that helps prevent click-jacking attacks by controlling whether a web page can be embedded in frames. Values such as DENY and SAMEORIGIN can ensure that content is not embedded on malicious or untrusted websites.

            - (object) **`modify_mtls_header_names = {}`** _[since v1.0.0]_

                Configure the HTTP headers added by the load balancer when using TLS or mTLS

                - (string) **`x_amzn_mtls_clientcert = null`** _[since v1.0.0]_

                    Carries the full client certificate. Allowing the target to verify the certificate’s authenticity, validate the certificate chain, and authenticate the client during the mTLS handshake process.

                - (string) **`x_amzn_mtls_clientcert_issuer = null`** _[since v1.0.0]_

                    Helps the target validate and authenticate the client certificate by identifying the certificate authority that issued the certificate.

                - (string) **`x_amzn_mtls_clientcert_leaf = null`** _[since v1.0.0]_

                    Provides the client certificate used in the mTLS handshake, allowing the server to authenticate the client and validate the certificate chain. This ensures the connection is secure and authorized.

                - (string) **`x_amzn_mtls_clientcert_serial_number = null`** _[since v1.0.0]_

                    Ensures that the target can identify and verify the specific certificate presented by the client during the TLS handshake.

                - (string) **`x_amzn_mtls_clientcert_subject = null`** _[since v1.0.0]_

                    Provides the target with detailed information about the entity the client certificate was issued to, which helps in identification, authentication, authorization, and logging during mTLS authentication.

                - (string) **`x_amzn_mtls_clientcert_validity = null`** _[since v1.0.0]_

                    Allows the target to verify that the client certificate being used is within its defined validity period, ensuring the certificate is not expired or prematurely used.

                - (string) **`x_amzn_tls_cipher_suite = null`** _[since v1.0.0]_

                    Indicates the combination of cryptographic algorithms used to secure a connection in TLS. This allows the server to assess the security of the connection, helping with compatibility troubleshooting, and ensuring compliance with security policies.

                - (string) **`x_amzn_tls_version = null`** _[since v1.0.0]_

                    Indicates the version of the TLS protocol used for a connection. It facilitates determining the security level of the communication, troubleshoot connection issues and ensuring compliance.

        - (list(string)) **`certificates_for_sni = []`** _[since v1.0.0]_

            Additional certificates for Server Name Indication (SNI). This enables the load balancer to support multiple domains on the same port and provide a different certificate for each domain.

        - (string) **`default_ssl_certificate_arn = null`** _[since v1.0.0]_

            The certificate to use if a client connects without SNI protocol, or if there are no matching certificates. This is required if a `HTTPS` listner is specified.

        - (string) **`security_policy = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"`** _[since v1.0.0]_

            Name of the SSL Policy for the listener. This is required if a `HTTPS` listner is specified.

    - (object) **`attributes = {}`** _[since v1.0.0]_

        Configure load balancer attributes

        - (string) **`connection_idle_timeout = "1 minute"`** _[since v1.0.0]_

            The amount of time a client or target connection can be idle before the load balancer closes it. Valid range is `"1 second" - "4000 seconds"`.

        - (string) **`desync_mitigation_mode = "defensive"`** _[since v1.0.0]_

            Determines how the load balancer handles requests that might pose a security risk to your application. Valid values: `"defensive"`, `"monitor"`, `"strictest"`

        - (bool) **`drop_invalid_header_fields = false`** _[since v1.0.0]_

            Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer

        - (bool) **`enable_arc_zonal_shift_integration = false`** _[since v1.0.0]_

            Controls whether Amazon Application Recovery Controller (ARC) zonal shift is available to the load balancer.

        - (bool) **`enable_http2 = true`** _[since v1.0.0]_

            Enable requests using the HTTP/2 protocol

        - (bool) **`enable_tls_version_and_cipher_headers = false`** _[since v1.0.0]_

            If enabled, the load balancer adds two TLS headers (x-amzn-tls-version and x-amzn-tls-cipher-suite) to the client request before sending it to the target.

        - (bool) **`enable_x_forwarded_for_client_port_preservation = false`** _[since v1.0.0]_

            Whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer.

        - (bool) **`enable_waf_fail_open = false`** _[since v1.0.0]_

            Allows requests through to backend target(s) when the application load balancer is unable to contact AWS Web Application Firewall (WAF).

        - (string) **`http_client_keepalive_duration = "1 hour"`** _[since v1.0.0]_

            The amount of time a client connection is kept open before the load balancer closes it. Valid range is `"1 minute" - "7 days"`

        - (bool) **`preserve_host_header = false`** _[since v1.0.0]_

            Whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to targets without any change.

        - (string) **`x_forwarded_for_header_processing_mode = "append"`** _[since v1.0.0]_

            Rather to append, preserve, or remove the X-Forwarded-For header in the HTTP request before the Application Load Balancer sends the request to the target. Valid values: `"append"`, `"preserve"`, `"remove"`

- (number) **`capacity_unit_reservation = null`** _[since v1.0.0]_

    Minimum capacity for the load balancer.

- (bool) **`enable_deletion_protection = false`** _[since v1.0.0]_

    If enabled, you must turn it off before you can delete the load balancer.

- (object) **`gateway_load_balancer = null`** _[since v1.0.0]_

    Specify a Gateway load balancer. Mutually exclusive to `application_load_balancer`, `network_load_balancer`. Please [see example](#gateway-load-balacner)

    - (object) **`listener`** _[since v1.0.0]_

        Configure the listener

        - (object) **`default_action`** _[since v1.0.0]_

            Specify the default action that triggers for the incoming requests.

            - (object) **`forward`** _[since v1.0.0]_

                Configure forward action to route requests to a target group.

                - (string) **`target_group`** _[since v1.0.0]_

                    The ARN of the target group to route traffic to

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags for the listener

    - (object) **`attributes = {}`** _[since v1.0.0]_

        Configure the load balancer attributes

        - (bool) **`enable_cross_zone_load_balancing = false`** _[since v1.0.0]_

            If enabled. Each load balancer node load balances traffic among healthy targets in all its enabled Availability Zones

- (bool) **`internet_facing = true`** _[since v1.0.0]_

    Whether the load balancer is publicly accessible

- (string) **`ip_address_type = "ipv4"`** _[since v1.0.0]_

    The front-end IP address type to assign to the load balancer. The subnets mapped to this load balancer must include the selected IP address types. Valid values:

    | LB type     | Valid values
    |-------------|------------------------------------------------------------
    | application | `"ipv4"`, `"dualstack"`, `"dualstack-without-public-ipv4"`
    | gateway     | `"ipv4"`, `"dualstack"`
    | network     | `"ipv4"`, `"dualstack"`

- (object) **`network_load_balancer = null`** _[since v1.0.0]_

    Specify a Network load balancer. Mutually exclusive to `application_load_balancer`, `gateway_load_balancer`. Please [see example](#network-load-balacner)

    - (map(object)) **`listeners`** _[since v1.0.0]_

        Map of listeners in the `<protocol>:<port>` format

        - (object) **`default_action`** _[since v1.0.0]_

            Specify the default action that triggers for the incoming requests.

            - (object) **`forward`** _[since v1.0.0]_

                Configure forward action to route requests to a target group.

                - (string) **`target_group`** _[since v1.0.0]_

                    The ARN of the target group to route traffic to

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags for the listener

        - (string) **`alpn_policy = null`** _[since v1.0.0]_

            Specify the Application-Layer Protocol Negotiation (ALPN) policy. Only applicable if protocol is `TLS`. Valid values: `"HTTP1Only"`, `"HTTP2Only"`, `"HTTP2Optional"`, `"HTTP2Preferred"`, `"None"`.

        - (object) **`attributes = {}`** _[since v1.0.0]_

            Configure the listener attributes

            - (string) **`tcp_idle_timeout = "350 seconds"`** _[since v1.0.0]_

                The number of seconds before the listener determines that the TCP connection is idle and closes it. Valid values: `"1 minutes" - "100 minutes"`. Only applicable if protocol is `TCP`

        - (list(string)) **`certificates_for_sni = []`** _[since v1.0.0]_

            Additional certificates for Server Name Indication (SNI). This enables the load balancer to support multiple domains on the same port and provide a different certificate for each domain.

        - (string) **`default_ssl_certificate_arn = null`** _[since v1.0.0]_

            The certificate to use if a client connects without SNI protocol, or if there are no matching certificates. This is required if a `TLS` listner is specified.

        - (string) **`security_policy = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"`** _[since v1.0.0]_

            Name of the SSL Policy for the listener. This is required if a `TLS` listner is specified.

    - (object) **`attributes = {}`** _[since v1.0.0]_

        Configure the load balancer attributes

        - (string) **`client_routing_policy = any_availability_zone`** _[since v1.0.0]_

            How traffic is distributed among the load balancer Availability Zones. Applies only to internal requests for clients resolving the load balancer DNS name using Route 53 Resolver. Valid values: `"any_availability_zone"`, `"availability_zone_affinity"`, `"partial_availability_zone_affinity"`

        - (bool) **`enable_arc_zonal_shift_integration = false`** _[since v1.0.0]_

            Controls whether Amazon Application Recovery Controller (ARC) zonal shift is available to the load balancer.

        - (bool) **`enable_cross_zone_load_balancing = false`** _[since v1.0.0]_

            If enabled. Each load balancer node load balances traffic among healthy targets in all its enabled Availability Zones

- (list(string)) **`security_group_ids = null`** _[since v1.0.0]_

    List of security group IDs to assign to the load balancer. Only valid for Load Balancers of type `application` or `network`.

## Outputs

- (object) **`load_balancer`** _[since v1.0.0]_

    Info for this load balancer

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the load balancer

    - (string) **`dns_name`** _[since v1.0.0]_

        DNS name of the load balancer

    - (string) **`zone_id`** _[since v1.0.0]_

        Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record).

- (map(object)) **`application_load_balancer_listeners`** _[since v1.0.0]_

    Info for the listeners if `application_load_balancer` is specified

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the listener

- (map(object)) **`gateway_load_balancer_listeners`** _[since v1.0.0]_

    Info for the listeners if `gateway_load_balancer` is specified

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the listener

- (map(object)) **`network_load_balancer_listeners`** _[since v1.0.0]_

    Info for the listeners if `network_load_balancer` is specified

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the listener

[alb-user-authentication]:https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html
