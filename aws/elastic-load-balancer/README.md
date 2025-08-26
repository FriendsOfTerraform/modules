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

    Additional tags for the resource share

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

                - (list(string)) **`certificates_for_sni = []`** _[since v1.0.0]_

                    Additional certificates for Server Name Indication (SNI). This enables the load balancer to support multiple domains on the same port and provide a different certificate for each domain.

                - (string) **`default_ssl_certificate_arn = null`** _[since v1.0.0]_

                    The certificate to use if a client connects without SNI protocol, or if there are no matching certificates. This is required if a `HTTPS` listner is specified.

                - (string) **`security_policy = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"`** _[since v1.0.0]_

                    Name of the SSL Policy for the listener. This is required if a `HTTPS` listner is specified.

## Outputs

[alb-user-authentication]:https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html

