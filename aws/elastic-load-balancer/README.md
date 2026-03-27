# Elastic Load Balancer Module

This module creates and configures a [Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/) and its associated listeners and rules

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Application Load Balancer](#application-load-balancer)
  - [Gateway Load Balancer](#gateway-load-balancer)
  - [Network Load Balancer](#network-load-balancer)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

## Example Usage

### Application Load Balancer

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
              # (http header "hello" exists with the value "world" OR "worldz")(2 values) AND (http header "quz" exists with the value "quux")(1 value)
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
              # (host headers equal "demo.dev" OR "demo.uat")(2 values) AND (http request methods equal "GET" OR "LIST")(2 values) AND (source IP equal "10.0.0.0/16")(1 value)
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

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the load balancer. All associated resources will also have their name prefixed with this value

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#networkmapping">NetworkMapping</a>)</code></td>
    <td width="100%">network_mapping</td>
    <td></td>
</tr>
<tr><td colspan="3">

The networking configuration of the load balancer

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

Additional tags for the load balancer

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
    <td><code>object(<a href="#applicationloadbalancer">ApplicationLoadBalancer</a>)</code></td>
    <td width="100%">application_load_balancer</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Setup an Application load balancer. Mutually exclusive to `gateway_load_balancer`, `network_load_balancer`.

**Examples:**

- [Application Load Balancer](#application-load-balancer)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">capacity_unit_reservation</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Minimum capacity for the load balancer.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_deletion_protection</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

If enabled, you must turn it off before you can delete the load balancer.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#gatewayloadbalancer">GatewayLoadBalancer</a>)</code></td>
    <td width="100%">gateway_load_balancer</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Setup a Gateway load balancer. Mutually exclusive to `application_load_balancer`, `network_load_balancer`.

**Examples:**

- [Gateway Load Balancer](#gateway-load-balancer)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">internet_facing</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether the load balancer is publicly accessible

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ip_address_type</td>
    <td><code>"ipv4"</code></td>
</tr>
<tr><td colspan="3">

The front-end IP address type to assign to the load balancer. The subnets mapped to this load balancer must include the selected IP address types.

| LB type     | Valid values                                               |
| ----------- | ---------------------------------------------------------- |
| application | `"ipv4"`, `"dualstack"`, `"dualstack-without-public-ipv4"` |
| gateway     | `"ipv4"`, `"dualstack"`                                    |
| network     | `"ipv4"`, `"dualstack"`                                    |

**Allowed Values:**

- `ipv4`
- `dualstack`
- `dualstack-without-public-ipv4`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#networkloadbalancer">NetworkLoadBalancer</a>)</code></td>
    <td width="100%">network_load_balancer</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Setup a Network load balancer. Mutually exclusive to `application_load_balancer`, `gateway_load_balancer`.

**Examples:**

- [Network Load Balancer](#network-load-balancer)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

List of security group IDs to assign to the load balancer. Only valid for Load Balancers of type `application` or `network`.

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#applicationloadbalancerlisteners">ApplicationLoadBalancerListeners</a>))</code></td>
    <td width="100%">application_load_balancer_listeners</td>
    <td></td>
</tr>
<tr><td colspan="3">

Info for the listeners if `application_load_balancer` is specified

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#gatewayloadbalancerlisteners">GatewayLoadBalancerListeners</a>))</code></td>
    <td width="100%">gateway_load_balancer_listeners</td>
    <td></td>
</tr>
<tr><td colspan="3">

Info for the listeners if `gateway_load_balancer` is specified

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#loadbalancer">LoadBalancer</a>)</code></td>
    <td width="100%">load_balancer</td>
    <td></td>
</tr>
<tr><td colspan="3">

Info for this load balancer

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#networkloadbalancerlisteners">NetworkLoadBalancerListeners</a>))</code></td>
    <td width="100%">network_load_balancer_listeners</td>
    <td></td>
</tr>
<tr><td colspan="3">

Info for the listeners if `network_load_balancer` is specified

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Objects

#### Action

The action to trigger when an incoming request matches all conditions.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#authenticateusers">AuthenticateUsers</a>)</code></td>
    <td width="100%">authenticate_users</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configure user authentication through either OpenID Connect (OIDC) or Amazon Cognito. Please refer to [this documentation][alb-user-authentication] for prerequisites for both methods.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#fixedresponse">FixedResponse</a>)</code></td>
    <td width="100%">fixed_response</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configurate fixed-response action to drop client requests and return a custom HTTP response. When a fixed-response action is taken, the action and the URL of the redirect target are recorded in the access logs.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#forward">Forward</a>)</code></td>
    <td width="100%">forward</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configure forward action to route requests to one or more target groups.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#redirect">Redirect</a>)</code></td>
    <td width="100%">redirect</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Redirect client requests from one URL to another. You cannot redirect HTTPS to HTTP.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### AddResponseHeaders

Control whether your Application Load Balancer adds certain headers to HTTP responses. If the HTTP response from your load balancer's target already includes a header, the load balancer will overwrite it with the configured value.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_control_allow_credentials</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies whether the client should include credentials such as cookies, HTTP authentication or client certificates in cross-origin requests.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">access_control_allow_headers</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies which custom or non-simple headers can be included in a cross-origin request. This header gives targets control over which headers can be sent by clients from different origins.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">access_control_allow_methods</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies the HTTP methods that are allowed when making cross-origin requests to the target. It provides control over which actions can be performed from different origins.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">access_control_allow_origin</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Controls whether resources on a target can be accessed from different origins. This allows secure cross-origin interactions while preventing unauthorized access.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">access_control_expose_headers</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Allows the target to specify which additional response headers can be access by the client in cross-origin requests.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">access_control_max_age</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines how long the browser can cache the result of a preflight request, reducing the need for repeated preflight checks. This helps to optimize performance by reducing the number of OPTIONS requests required for certain cross-origin requests.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">content_security_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Security feature that prevents code injection attacks like XSS by controlling which resources such as scripts, styles, images, etc. can be loaded and executed by a website.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">http_strict_transport_security</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enforces HTTPS-only connections by the browser for a specified duration

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_content_type_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

With the no-sniff directive, enhances web security by preventing browsers from guessing the MIME type of a resource. It ensures that browsers only interpret content according to the declared Content-Type

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_frame_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Header security mechanism that helps prevent click-jacking attacks by controlling whether a web page can be embedded in frames. Values such as DENY and SAMEORIGIN can ensure that content is not embedded on malicious or untrusted websites.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### AmazonCognito

Configures an Amazon Cognito IdP for authentication

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">app_client</td>
    <td></td>
</tr>
<tr><td colspan="3">

ID of the Cognito user pool client.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">user_pool</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the Cognito user pool

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">user_pool_domain</td>
    <td></td>
</tr>
<tr><td colspan="3">

Domain prefix or fully-qualified domain name of the Cognito user pool.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ApplicationLoadBalancer

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#listeners">Listeners</a>))</code></td>
    <td width="100%">listeners</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of listeners in the `<protocol>:<port>` format

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#attributes">Attributes</a>)</code></td>
    <td width="100%">attributes</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configure listener attributes

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ApplicationLoadBalancerListeners

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the listener

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Attributes

Configure the load balancer attributes

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">client_routing_policy</td>
    <td><code>"any_availability_zone"</code></td>
</tr>
<tr><td colspan="3">

How traffic is distributed among the load balancer Availability Zones. Applies only to internal requests for clients resolving the load balancer DNS name using Route 53 Resolver.

**Allowed Values:**

- `any_availability_zone`
- `availability_zone_affinity`
- `partial_availability_zone_affinity`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_arc_zonal_shift_integration</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Controls whether Amazon Application Recovery Controller (ARC) zonal shift is available to the load balancer.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_cross_zone_load_balancing</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

If enabled. Each load balancer node load balances traffic among healthy targets in all its enabled Availability Zones

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### AuthenticateUsers

Configure user authentication through either OpenID Connect (OIDC) or Amazon Cognito. Please refer to [this documentation][alb-user-authentication] for prerequisites for both methods.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">action_on_unauthenticated_request</td>
    <td><code>"authenticate"</code></td>
</tr>
<tr><td colspan="3">

The response to a request from a user that is not authenticated.

**Allowed Values:**

- `authenticate`
- `allow`
- `deny`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">extra_request_parameters</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

A map of extra parameters to pass to the identity provider (IdP) during authentication

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">scope</td>
    <td><code>"openid"</code></td>
</tr>
<tr><td colspan="3">

The attributes to be requested by the identity provider (IdP).

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">session_cookie_name</td>
    <td><code>"AWSELBAuthSessionCookie"</code></td>
</tr>
<tr><td colspan="3">

The name of the cookie used to maintain session information.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">session_timeout</td>
    <td><code>"7 days"</code></td>
</tr>
<tr><td colspan="3">

The maximum time allowed for an authenticated session after which re-authentication will be required. Valid values: `"1 second" - "7 days"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#amazoncognito">AmazonCognito</a>)</code></td>
    <td width="100%">amazon_cognito</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures an Amazon Cognito IdP for authentication

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#oidc">Oidc</a>)</code></td>
    <td width="100%">oidc</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures an Open ID Connect (OIDC) IdP for authentication

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### CertificateAuthorityBundle

The CA bundle

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">s3_uri</td>
    <td></td>
</tr>
<tr><td colspan="3">

The S3 URI where the CA bundle resides. For example: `"s3://demo-bucket/ca-bundles/ca.pem"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">version</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The S3 version ID of the CA bundle

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### CertificateRevocationLists

Map of CRLs to be imported into the trust store. The keys of the map are the S3 URI where the CRL resides.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">version</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The S3 version ID of the CRL

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Conditions

Specify specific conditions a request must match for the rules actions to be performed. You can specify up to 5 condition values per rule.

**Examples:**

- [Application Load Balancer](#application-load-balancer)

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">host_headers</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: `*` (matches 0 or more characters) and `?` (matches exactly 1 character).

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">paths</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters. Comparison is case sensitive. Wildcard characters supported: \* (matches 0 or more characters) and ? (matches exactly 1 character).

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">query_strings</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Query strings to match. This condition can be specified multiple times.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">http_request_methods</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of HTTP request methods or verbs to match. Maximum size is 40 characters. Only allowed characters are A-Z, hyphen (-) and underscore (\_). Comparison is case sensitive. Wildcards are not supported.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(list(string))</code></td>
    <td width="100%">http_headers</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

HTTP headers to match. This condition can be specified multiple times.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">source_ips</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of source IP CIDR notations to match. You can use both IPv4 and IPv6 addresses. Wildcards are not supported.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### DefaultAction

Specify the default action that triggers for the incoming requests.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#forward">Forward</a>)</code></td>
    <td width="100%">forward</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configure forward action to route requests to a target group.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### EnableMutualAuthentication

Enable mTLS. Configure how the listener handles requests that present client certificates. This includes how the load balancer authenticates certificates and the amount of certificate metadata that is sent to the backend targets.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#verifywithtruststore">VerifyWithTrustStore</a>)</code></td>
    <td width="100%">verify_with_trust_store</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The load balancer and client verify each other's identity and establish a TLS connection to encrypt communication between them. If this is not specified, the incoming certificate will be sent to the backend target as-is (`Passthrough`)

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### FixedResponse

Configurate fixed-response action to drop client requests and return a custom HTTP response. When a fixed-response action is taken, the action and the URL of the redirect target are recorded in the access logs.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">content_type</td>
    <td><code>"text/plain"</code></td>
</tr>
<tr><td colspan="3">

The format of your message.

**Allowed Values:**

- `text/plain`
- `text/css`
- `text/html`
- `application/javascript`
- `application/json`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">response_body</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The message body of the response

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">response_code</td>
    <td><code>503</code></td>
</tr>
<tr><td colspan="3">

HTTP response code. Valid values are 2xx, 4xx, and 5xx HTTP codes.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Forward

Configure forward action to route requests to a target group.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">target_group</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the target group to route traffic to

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### GatewayLoadBalancer

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#listener">Listener</a>)</code></td>
    <td width="100%">listener</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configure the listener

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#attributes">Attributes</a>)</code></td>
    <td width="100%">attributes</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configure the load balancer attributes

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### GatewayLoadBalancerListeners

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the listener

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Listener

Configure the listener

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#defaultaction">DefaultAction</a>)</code></td>
    <td width="100%">default_action</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the default action that triggers for the incoming requests.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the listener

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Listeners

Map of listeners in the `<protocol>:<port>` format

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#defaultaction">DefaultAction</a>)</code></td>
    <td width="100%">default_action</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the default action that triggers for the incoming requests.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#attributes">Attributes</a>)</code></td>
    <td width="100%">attributes</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configure the listener attributes

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the listener

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">alpn_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the Application-Layer Protocol Negotiation (ALPN) policy. Only applicable if protocol is `TLS`.

**Allowed Values:**

- `HTTP1Only`
- `HTTP2Only`
- `HTTP2Optional`
- `HTTP2Preferred`
- `None`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">certificates_for_sni</td>
    <td></td>
</tr>
<tr><td colspan="3">

Additional certificates for Server Name Indication (SNI). This enables the load balancer to support multiple domains on the same port and provide a different certificate for each domain.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">default_ssl_certificate_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The certificate to use if a client connects without SNI protocol, or if there are no matching certificates. This is required if a `TLS` listener is specified.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">security_policy</td>
    <td><code>"ELBSecurityPolicy-TLS13-1-2-Res-2021-06"</code></td>
</tr>
<tr><td colspan="3">

Name of the SSL Policy for the listener. This is required if a `TLS` listener is specified.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### LoadBalancer

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the load balancer

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">dns_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

DNS name of the load balancer

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">zone_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record).

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ModifyMtlsHeaderNames

Configure the HTTP headers added by the load balancer when using TLS or mTLS

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_mtls_clientcert</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Carries the full client certificate. Allowing the target to verify the certificate’s authenticity, validate the certificate chain, and authenticate the client during the mTLS handshake process.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_mtls_clientcert_issuer</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Helps the target validate and authenticate the client certificate by identifying the certificate authority that issued the certificate.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_mtls_clientcert_leaf</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Provides the client certificate used in the mTLS handshake, allowing the server to authenticate the client and validate the certificate chain. This ensures the connection is secure and authorized.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_mtls_clientcert_serial_number</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Ensures that the target can identify and verify the specific certificate presented by the client during the TLS handshake.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_mtls_clientcert_subject</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Provides the target with detailed information about the entity the client certificate was issued to, which helps in identification, authentication, authorization, and logging during mTLS authentication.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_mtls_clientcert_validity</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Allows the target to verify that the client certificate being used is within its defined validity period, ensuring the certificate is not expired or prematurely used.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_tls_cipher_suite</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Indicates the combination of cryptographic algorithms used to secure a connection in TLS. This allows the server to assess the security of the connection, helping with compatibility troubleshooting, and ensuring compliance with security policies.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">x_amzn_tls_version</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Indicates the version of the TLS protocol used for a connection. It facilitates determining the security level of the communication, troubleshoot connection issues and ensuring compliance.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### NetworkLoadBalancer

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#listeners">Listeners</a>))</code></td>
    <td width="100%">listeners</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of listeners in the `<protocol>:<port>` format

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#attributes">Attributes</a>)</code></td>
    <td width="100%">attributes</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configure the load balancer attributes

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### NetworkLoadBalancerListeners

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the listener

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### NetworkMapping

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#subnets">Subnets</a>))</code></td>
    <td width="100%">subnets</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of subnet ARNs where the load balancer routes traffic to. You can only specify one subnet per availability zone. If you enabled dual-stack mode for the load balancer, select subnets with associated IPv6 CIDR blocks. You must specify at least two subnets

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ipam_pool_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ID of the IPAM pool to use with this load balancer. IPAM pools allow your Application Load Balancers to use IPv4 addresses you own. Only applicable to `application_load_balancer` and `internet_facing = true`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### NewTrustStore

Create a new trust store using an existing CA bundle and optionally certificate revocation lists. Mutually exclusive to `trust_store_arn`

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#certificateauthoritybundle">CertificateAuthorityBundle</a>)</code></td>
    <td width="100%">certificate_authority_bundle</td>
    <td></td>
</tr>
<tr><td colspan="3">

The CA bundle

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the trust store

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#certificaterevocationlists">CertificateRevocationLists</a>))</code></td>
    <td width="100%">certificate_revocation_lists</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Map of CRLs to be imported into the trust store. The keys of the map are the S3 URI where the CRL resides.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Oidc

Configures an Open ID Connect (OIDC) IdP for authentication

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">authorization_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

OpenID provider server endpoint.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">client_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of an app client in your user pool.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">client_secret</td>
    <td></td>
</tr>
<tr><td colspan="3">

Provide a client secret associated with this client ID.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">issuer</td>
    <td></td>
</tr>
<tr><td colspan="3">

OpenID provider.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">token_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

URL of your token endpoint.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">user_info_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

URL of your user info endpoint.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Redirect

Redirect client requests from one URL to another. You cannot redirect HTTPS to HTTP.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">url</td>
    <td></td>
</tr>
<tr><td colspan="3">

The redirect URL. You can retain URI components of the original URL in the target URL by using the following reserved keywords:

| Keyword     | Description                                                             |
| ----------- | ----------------------------------------------------------------------- |
| #{protocol} | Retains the protocol. Use it in the protocol and query components.      |
| #{host}     | Retains the domain. Use it in the hostname, path, and query components. |
| #{port}     | Retains the port. Use it in the port, path, and query components.       |
| #{path}     | Retains the path. Use it in the path and query components.              |
| #{query}    | Retains the query parameters. Use it in the query component.            |

To avoid a redirect loop, you must modify at least one of the following components: protocol, port, hostname or path.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">status_code</td>
    <td><code>301</code></td>
</tr>
<tr><td colspan="3">

HTTP response code.

**Allowed Values:**

- `301`
- `302`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Rules

Configure multiple listener rules

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">priority</td>
    <td></td>
</tr>
<tr><td colspan="3">

The rule priority. Rules are evaluated in priority order from the lowest value to the highest value.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the listener rule

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#action">Action</a>)</code></td>
    <td width="100%">action</td>
    <td></td>
</tr>
<tr><td colspan="3">

The action to trigger when an incoming request matches all conditions.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(object(<a href="#conditions">Conditions</a>))</code></td>
    <td width="100%">conditions</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify specific conditions a request must match for the rules actions to be performed. You can specify up to 5 condition values per rule.

**Examples:**

- [Application Load Balancer](#application-load-balancer)

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Subnets

Map of subnet ARNs where the load balancer routes traffic to. You can only specify one subnet per availability zone. If you enabled dual-stack mode for the load balancer, select subnets with associated IPv6 CIDR blocks. You must specify at least two subnets

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">elastic_ip_allocation_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify an elastic IP allocation ID to provide your load balancer with a static IPv4 address in the selected Availability Zone. Only applicable to `network_load_balancer`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ipv6_address</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The front-end IPv6 address of the load balancer in the selected Availability Zone. It can be any available IP address within the subnet’s CIDR. Only applicable to `network_load_balancer`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">private_ipv4_address</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Private IPv4 address for an internal load balancer. It can be any available IP address within the subnet’s CIDR. Only applicable to `network_load_balancer` and `internet_facing = false`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### TargetGroups

Map of destination target groups in `<target_group_arn> = {<config>}` format. You can only specify up to 5 target groups.

**Examples:**

- [Application Load Balancer](#application-load-balancer)

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">weight</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify a weight that controls the prioritization and selection of each target group. Weights must be set as an integer between `0 - 999`.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### TurnOnTargetGroupStickiness

Enables the load balancer to bind a user's session to a specific target group. To use stickiness the client must support cookies. If you want to bind a user's session to a specific target, turn on the Target Group attribute Stickiness.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">duration</td>
    <td><code>"1 hour"</code></td>
</tr>
<tr><td colspan="3">

The stickiness duration. Valid values: `"1 second" - "7 days"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### VerifyWithTrustStore

The load balancer and client verify each other's identity and establish a TLS connection to encrypt communication between them. If this is not specified, the incoming certificate will be sent to the backend target as-is (`Passthrough`)

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">advertise_trust_store_ca_subject_name</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether the listener will advertise the Certificate Authorities (CAs) subject names trusted by its trust store.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">allow_expired_client_certificates</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether incoming connection requests with an expired client certificates should be allowed

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">trust_store_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

An existing trust store that contain the certificate authority (CA) bundle that you trust to identify clients. Mutually exclusive to `new_trust_store`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#newtruststore">NewTrustStore</a>)</code></td>
    <td width="100%">new_trust_store</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Create a new trust store using an existing CA bundle and optionally certificate revocation lists. Mutually exclusive to `trust_store_arn`

**Since:** 1.0.0

</td></tr>
</tbody></table>

[alb-user-authentication]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html

<!-- TFDOCS_EXTRAS_END -->
