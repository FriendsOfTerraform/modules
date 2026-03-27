variable "name" {
  type        = string
  description = <<EOT
    The name of the load balancer. All associated resources will also have their name prefixed with this value

    @since 1.0.0
  EOT
}

variable "network_mapping" {
  type = object({
    /// Map of subnet ARNs where the load balancer routes traffic to. You can only specify one subnet per availability zone. If you enabled dual-stack mode for the load balancer, select subnets with associated IPv6 CIDR blocks. You must specify at least two subnets
    ///
    /// @since 1.0.0
    subnets = map(object({
      /// Specify an elastic IP allocation ID to provide your load balancer with a static IPv4 address in the selected Availability Zone. Only applicable to `network_load_balancer`
      ///
      /// @since 1.0.0
      elastic_ip_allocation_id = optional(string, null)
      /// The front-end IPv6 address of the load balancer in the selected Availability Zone. It can be any available IP address within the subnet’s CIDR. Only applicable to `network_load_balancer`
      ///
      /// @since 1.0.0
      ipv6_address = optional(string, null)
      /// Private IPv4 address for an internal load balancer. It can be any available IP address within the subnet’s CIDR. Only applicable to `network_load_balancer` and `internet_facing = false`
      ///
      /// @since 1.0.0
      private_ipv4_address = optional(string, null)
    }))

    # This option is not yet available in the latest provider 6.10.0
    # enable_prefix_for_ipv6_source_nat = optional(bool, false)

    /// The ID of the IPAM pool to use with this load balancer. IPAM pools allow your Application Load Balancers to use IPv4 addresses you own. Only applicable to `application_load_balancer` and `internet_facing = true`
    ///
    /// @since 1.0.0
    ipam_pool_id = optional(string, null)
  })
  description = <<EOT
    The networking configuration of the load balancer

    @since 1.0.0
  EOT
}

variable "application_load_balancer" {
  type = object({
    /// Map of listeners in the `<protocol>:<port>` format
    ///
    /// @since 1.0.0
    listeners = map(object({
      /// Specify the default action that triggers if no other rules are matched for the incoming requests. Must specify only one of the following: `authenticate_users.amazon_cognito`, `authenticate_users.oidc`, `fixed_response`, `forward`, `redirect`
      ///
      /// @since 1.0.0
      default_action = object({
        /// Configure user authentication through either OpenID Connect (OIDC) or Amazon Cognito. Please refer to [this documentation][alb-user-authentication] for prerequisites for both methods.
        ///
        /// @link {alb-user-authentication} https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html
        /// @since 1.0.0
        authenticate_users = optional(object({
          /// The response to a request from a user that is not authenticated.
          ///
          /// @enum authenticate|allow|deny
          /// @since 1.0.0
          action_on_unauthenticated_request = optional(string, "authenticate")
          /// A map of extra parameters to pass to the identity provider (IdP) during authentication
          ///
          /// @since 1.0.0
          extra_request_parameters = optional(map(string), {})
          /// The attributes to be requested by the identity provider (IdP).
          ///
          /// @since 1.0.0
          scope = optional(string, "openid")
          /// The name of the cookie used to maintain session information.
          ///
          /// @since 1.0.0
          session_cookie_name = optional(string, "AWSELBAuthSessionCookie")
          /// The maximum time allowed for an authenticated session after which re-authentication will be required. Valid values: `"1 second" - "7 days"`
          ///
          /// @since 1.0.0
          session_timeout = optional(string, "7 days")

          /// Configures an Amazon Cognito IdP for authentication
          ///
          /// @since 1.0.0
          amazon_cognito = optional(object({
            /// ID of the Cognito user pool client.
            ///
            /// @since 1.0.0
            app_client = string
            /// The ARN of the Cognito user pool
            ///
            /// @since 1.0.0
            user_pool = string
            /// Domain prefix or fully-qualified domain name of the Cognito user pool.
            ///
            /// @since 1.0.0
            user_pool_domain = string
          }), null)

          /// Configures an Open ID Connect (OIDC) IdP for authentication
          ///
          /// @since 1.0.0
          oidc = optional(object({
            /// OpenID provider server endpoint.
            ///
            /// @since 1.0.0
            authorization_endpoint = string
            /// The ID of an app client in your user pool.
            ///
            /// @since 1.0.0
            client_id = string
            /// Provide a client secret associated with this client ID.
            ///
            /// @since 1.0.0
            client_secret = string
            /// OpenID provider.
            ///
            /// @since 1.0.0
            issuer = string
            /// URL of your token endpoint.
            ///
            /// @since 1.0.0
            token_endpoint = string
            /// URL of your user info endpoint.
            ///
            /// @since 1.0.0
            user_info_endpoint = string
          }), null)
        }), null)

        /// Configurate fixed-response action to drop client requests and return a custom HTTP response. When a fixed-response action is taken, the action and the URL of the redirect target are recorded in the access logs.
        ///
        /// @since 1.0.0
        fixed_response = optional(object({
          /// The format of your message.
          ///
          /// @enum text/plain|text/css|text/html|application/javascript|application/json
          /// @since 1.0.0
          content_type = optional(string, "text/plain")
          /// The message body of the response
          ///
          /// @since 1.0.0
          response_body = optional(string, null)
          /// HTTP response code. Valid values are 2xx, 4xx, and 5xx HTTP codes.
          ///
          /// @since 1.0.0
          response_code = optional(number, 503)
        }), null)

        /// Configure forward action to route requests to one or more target groups.
        ///
        /// @since 1.0.0
        forward = optional(object({
          /// Map of destination target groups in `<target_group_arn> = {<config>}` format. You can only specify up to 5 target groups.
          ///
          /// @example "Application Load Balancer" #application-load-balancer
          /// @since 1.0.0
          target_groups = map(object({
            /// Specify a weight that controls the prioritization and selection of each target group. Weights must be set as an integer between `0 - 999`.
            ///
            /// @since 1.0.0
            weight = optional(number, null)
          }))
          /// Enables the load balancer to bind a user's session to a specific target group. To use stickiness the client must support cookies. If you want to bind a user's session to a specific target, turn on the Target Group attribute Stickiness.
          ///
          /// @since 1.0.0
          turn_on_target_group_stickiness = optional(object({
            /// The stickiness duration. Valid values: `"1 second" - "7 days"`
            ///
            /// @since 1.0.0
            duration = optional(string, "1 hour")
          }), null)
        }), null)

        /// Redirect client requests from one URL to another. You cannot redirect HTTPS to HTTP.
        ///
        /// @since 1.0.0
        redirect = optional(object({
          /// The redirect URL. You can retain URI components of the original URL in the target URL by using the following reserved keywords:
          ///
          /// | Keyword     | Description
          /// |-------------|-------------------------------------------------------------------------
          /// | #{protocol} | Retains the protocol. Use it in the protocol and query components.
          /// | #{host}     | Retains the domain. Use it in the hostname, path, and query components.
          /// | #{port}     | Retains the port. Use it in the port, path, and query components.
          /// | #{path}     | Retains the path. Use it in the path and query components.
          /// | #{query}    | Retains the query parameters. Use it in the query component.
          ///
          /// To avoid a redirect loop, you must modify at least one of the following components: protocol, port, hostname or path.
          ///
          /// @since 1.0.0
          url = string
          /// HTTP response code.
          ///
          /// @enum 301|302
          /// @since 1.0.0
          status_code = optional(number, 301)
        }), null)
      })

      /// Configure listener attributes
      ///
      /// @since 1.0.0
      attributes = optional(object({
        /// Whether your Application Load Balancer adds a response header with value `awselb/2.0`.
        ///
        /// @since 1.0.0
        add_alb_server_response_header = optional(bool, true)

        /// Control whether your Application Load Balancer adds certain headers to HTTP responses. If the HTTP response from your load balancer's target already includes a header, the load balancer will overwrite it with the configured value.
        ///
        /// @since 1.0.0
        add_response_headers = optional(object({
          /// Specifies whether the client should include credentials such as cookies, HTTP authentication or client certificates in cross-origin requests.
          ///
          /// @since 1.0.0
          access_control_allow_credentials = optional(string, null)
          /// Specifies which custom or non-simple headers can be included in a cross-origin request. This header gives targets control over which headers can be sent by clients from different origins.
          ///
          /// @since 1.0.0
          access_control_allow_headers = optional(string, null)
          /// Specifies the HTTP methods that are allowed when making cross-origin requests to the target. It provides control over which actions can be performed from different origins.
          ///
          /// @since 1.0.0
          access_control_allow_methods = optional(string, null)
          /// Controls whether resources on a target can be accessed from different origins. This allows secure cross-origin interactions while preventing unauthorized access.
          ///
          /// @since 1.0.0
          access_control_allow_origin = optional(string, null)
          /// Allows the target to specify which additional response headers can be access by the client in cross-origin requests.
          ///
          /// @since 1.0.0
          access_control_expose_headers = optional(string, null)
          /// Defines how long the browser can cache the result of a preflight request, reducing the need for repeated preflight checks. This helps to optimize performance by reducing the number of OPTIONS requests required for certain cross-origin requests.
          ///
          /// @since 1.0.0
          access_control_max_age = optional(string, null)
          /// Security feature that prevents code injection attacks like XSS by controlling which resources such as scripts, styles, images, etc. can be loaded and executed by a website.
          ///
          /// @since 1.0.0
          content_security_policy = optional(string, null)
          /// Enforces HTTPS-only connections by the browser for a specified duration
          ///
          /// @since 1.0.0
          http_strict_transport_security = optional(string, null)
          /// With the no-sniff directive, enhances web security by preventing browsers from guessing the MIME type of a resource. It ensures that browsers only interpret content according to the declared Content-Type
          ///
          /// @since 1.0.0
          x_content_type_options = optional(string, null)
          /// Header security mechanism that helps prevent click-jacking attacks by controlling whether a web page can be embedded in frames. Values such as DENY and SAMEORIGIN can ensure that content is not embedded on malicious or untrusted websites.
          ///
          /// @since 1.0.0
          x_frame_options = optional(string, null)
        }), {})

        /// Configure the HTTP headers added by the load balancer when using TLS or mTLS
        ///
        /// @since 1.0.0
        modify_mtls_header_names = optional(object({
          /// Carries the full client certificate. Allowing the target to verify the certificate’s authenticity, validate the certificate chain, and authenticate the client during the mTLS handshake process.
          ///
          /// @since 1.0.0
          x_amzn_mtls_clientcert = optional(string, null)
          /// Helps the target validate and authenticate the client certificate by identifying the certificate authority that issued the certificate.
          ///
          /// @since 1.0.0
          x_amzn_mtls_clientcert_issuer = optional(string, null)
          /// Provides the client certificate used in the mTLS handshake, allowing the server to authenticate the client and validate the certificate chain. This ensures the connection is secure and authorized.
          ///
          /// @since 1.0.0
          x_amzn_mtls_clientcert_leaf = optional(string, null)
          /// Ensures that the target can identify and verify the specific certificate presented by the client during the TLS handshake.
          ///
          /// @since 1.0.0
          x_amzn_mtls_clientcert_serial_number = optional(string, null)
          /// Provides the target with detailed information about the entity the client certificate was issued to, which helps in identification, authentication, authorization, and logging during mTLS authentication.
          ///
          /// @since 1.0.0
          x_amzn_mtls_clientcert_subject = optional(string, null)
          /// Allows the target to verify that the client certificate being used is within its defined validity period, ensuring the certificate is not expired or prematurely used.
          ///
          /// @since 1.0.0
          x_amzn_mtls_clientcert_validity = optional(string, null)
          /// Indicates the combination of cryptographic algorithms used to secure a connection in TLS. This allows the server to assess the security of the connection, helping with compatibility troubleshooting, and ensuring compliance with security policies.
          ///
          /// @since 1.0.0
          x_amzn_tls_cipher_suite = optional(string, null)
          /// Indicates the version of the TLS protocol used for a connection. It facilitates determining the security level of the communication, troubleshoot connection issues and ensuring compliance.
          ///
          /// @since 1.0.0
          x_amzn_tls_version = optional(string, null)
        }), {})
      }), {})

      /// Enable mTLS. Configure how the listener handles requests that present client certificates. This includes how the load balancer authenticates certificates and the amount of certificate metadata that is sent to the backend targets.
      ///
      /// @since 1.0.0
      enable_mutual_authentication = optional(object({
        /// The load balancer and client verify each other's identity and establish a TLS connection to encrypt communication between them. If this is not specified, the incoming certificate will be sent to the backend target as-is (`Passthrough`)
        ///
        /// @since 1.0.0
        verify_with_trust_store = optional(object({
          /// Whether the listener will advertise the Certificate Authorities (CAs) subject names trusted by its trust store.
          ///
          /// @since 1.0.0
          advertise_trust_store_ca_subject_name = optional(bool, false)
          /// Whether incoming connection requests with an expired client certificates should be allowed
          ///
          /// @since 1.0.0
          allow_expired_client_certificates = optional(bool, false)
          /// An existing trust store that contain the certificate authority (CA) bundle that you trust to identify clients. Mutually exclusive to `new_trust_store`
          ///
          /// @since 1.0.0
          trust_store_arn = optional(string, null)

          /// Create a new trust store using an existing CA bundle and optionally certificate revocation lists. Mutually exclusive to `trust_store_arn`
          ///
          /// @since 1.0.0
          new_trust_store = optional(object({
            /// The CA bundle
            ///
            /// @since 1.0.0
            certificate_authority_bundle = object({
              /// The S3 URI where the CA bundle resides. For example: `"s3://demo-bucket/ca-bundles/ca.pem"`
              ///
              /// @since 1.0.0
              s3_uri = string
              /// The S3 version ID of the CA bundle
              ///
              /// @since 1.0.0
              version = optional(string, null)
            })

            /// Additional tags for the trust store
            ///
            /// @since 1.0.0
            additional_tags = optional(map(string), {})

            /// Map of CRLs to be imported into the trust store. The keys of the map are the S3 URI where the CRL resides.
            ///
            /// @since 1.0.0
            certificate_revocation_lists = optional(map(object({
              /// The S3 version ID of the CRL
              ///
              /// @since 1.0.0
              version = optional(string, null)
            })), {})
          }), null)
        }), null)
      }), null)

      /// Configure multiple listener rules
      ///
      /// @since 1.0.0
      rules = optional(map(object({
        /// The rule priority. Rules are evaluated in priority order from the lowest value to the highest value.
        ///
        /// @since 1.0.0
        priority = number
        /// Additional tags for the listener rule
        ///
        /// @since 1.0.0
        additional_tags = optional(map(string), {})

        /// The action to trigger when an incoming request matches all conditions.
        ///
        /// @since 1.0.0
        action = object({
          /// Configure user authentication through either OpenID Connect (OIDC) or Amazon Cognito. Please refer to [this documentation][alb-user-authentication] for prerequisites for both methods.
          ///
          /// @link {alb-user-authentication} https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html
          /// @since 1.0.0
          authenticate_users = optional(object({
            /// The response to a request from a user that is not authenticated.
            ///
            /// @enum authenticate|allow|deny
            /// @since 1.0.0
            action_on_unauthenticated_request = optional(string, "authenticate")
            /// A map of extra parameters to pass to the identity provider (IdP) during authentication
            ///
            /// @since 1.0.0
            extra_request_parameters = optional(map(string), {})
            /// The attributes to be requested by the identity provider (IdP).
            ///
            /// @since 1.0.0
            scope = optional(string, "openid")
            /// The name of the cookie used to maintain session information.
            ///
            /// @since 1.0.0
            session_cookie_name = optional(string, "AWSELBAuthSessionCookie")
            /// The maximum time allowed for an authenticated session after which re-authentication will be required. Valid values: `"1 second" - "7 days"`
            ///
            /// @since 1.0.0
            session_timeout = optional(string, "7 days")

            /// Configures an Amazon Cognito IdP for authentication
            ///
            /// @since 1.0.0
            amazon_cognito = optional(object({
              /// ID of the Cognito user pool client.
              ///
              /// @since 1.0.0
              app_client = string
              /// The ARN of the Cognito user pool
              ///
              /// @since 1.0.0
              user_pool = string
              /// Domain prefix or fully-qualified domain name of the Cognito user pool.
              ///
              /// @since 1.0.0
              user_pool_domain = string
            }), null)

            /// Configures an Open ID Connect (OIDC) IdP for authentication
            ///
            /// @since 1.0.0
            oidc = optional(object({
              /// OpenID provider server endpoint.
              ///
              /// @since 1.0.0
              authorization_endpoint = string
              /// The ID of an app client in your user pool.
              ///
              /// @since 1.0.0
              client_id = string
              /// Provide a client secret associated with this client ID.
              ///
              /// @since 1.0.0
              client_secret = string
              /// OpenID provider.
              ///
              /// @since 1.0.0
              issuer = string
              /// URL of your token endpoint.
              ///
              /// @since 1.0.0
              token_endpoint = string
              /// URL of your user info endpoint.
              ///
              /// @since 1.0.0
              user_info_endpoint = string
            }), null)
          }), null)

          /// Configurate fixed-response action to drop client requests and return a custom HTTP response. When a fixed-response action is taken, the action and the URL of the redirect target are recorded in the access logs.
          ///
          /// @since 1.0.0
          fixed_response = optional(object({
            /// The format of your message.
            ///
            /// @enum text/plain|text/css|text/html|application/javascript|application/json
            /// @since 1.0.0
            content_type = optional(string, "text/plain")
            /// The message body of the response
            ///
            /// @since 1.0.0
            response_body = optional(string, null)
            /// HTTP response code. Valid values are 2xx, 4xx, and 5xx HTTP codes.
            ///
            /// @since 1.0.0
            response_code = optional(number, 503)
          }), null)

          /// Configure forward action to route requests to one or more target groups.
          ///
          /// @since 1.0.0
          forward = optional(object({
            /// Map of destination target groups in `<target_group_arn> = {<config>}` format. You can only specify up to 5 target groups.
            ///
            /// @example "Application Load Balancer" #application-load-balancer
            /// @since 1.0.0
            target_groups = map(object({
              /// Specify a weight that controls the prioritization and selection of each target group. Weights must be set as an integer between `0 - 999`.
              ///
              /// @since 1.0.0
              weight = optional(number, null)
            }))
            /// Enables the load balancer to bind a user's session to a specific target group. To use stickiness the client must support cookies. If you want to bind a user's session to a specific target, turn on the Target Group attribute Stickiness.
            ///
            /// @since 1.0.0
            turn_on_target_group_stickiness = optional(object({
              /// The stickiness duration. Valid values: `"1 second" - "7 days"`
              ///
              /// @since 1.0.0
              duration = optional(string, "1 hour")
            }), null)
          }), null)

          /// Redirect client requests from one URL to another. You cannot redirect HTTPS to HTTP.
          ///
          /// @since 1.0.0
          redirect = optional(object({
            /// The redirect URL. You can retain URI components of the original URL in the target URL by using the following reserved keywords:
            ///
            /// | Keyword     | Description
            /// |-------------|-------------------------------------------------------------------------
            /// | #{protocol} | Retains the protocol. Use it in the protocol and query components.
            /// | #{host}     | Retains the domain. Use it in the hostname, path, and query components.
            /// | #{port}     | Retains the port. Use it in the port, path, and query components.
            /// | #{path}     | Retains the path. Use it in the path and query components.
            /// | #{query}    | Retains the query parameters. Use it in the query component.
            ///
            /// To avoid a redirect loop, you must modify at least one of the following components: protocol, port, hostname or path.
            ///
            /// @since 1.0.0
            url = string
            /// HTTP response code.
            ///
            /// @enum 301|302
            /// @since 1.0.0
            status_code = optional(number, 301)
          }), null)
        })

        /// Specify specific conditions a request must match for the rules actions to be performed. You can specify up to 5 condition values per rule.
        ///
        /// @example "Application Load Balancer" #application-load-balancer
        /// @since 1.0.0
        conditions = list(object({
          /// A list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: `*` (matches 0 or more characters) and `?` (matches exactly 1 character).
          ///
          /// @since 1.0.0
          host_headers = optional(list(string), null)
          /// A list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters. Comparison is case sensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character).
          ///
          /// @since 1.0.0
          paths = optional(list(string), null)
          /// Query strings to match. This condition can be specified multiple times.
          ///
          /// @since 1.0.0
          query_strings = optional(map(string), {})
          /// A list of HTTP request methods or verbs to match. Maximum size is 40 characters. Only allowed characters are A-Z, hyphen (-) and underscore (_). Comparison is case sensitive. Wildcards are not supported.
          ///
          /// @since 1.0.0
          http_request_methods = optional(list(string), null)
          /// HTTP headers to match. This condition can be specified multiple times.
          ///
          /// @since 1.0.0
          http_headers = optional(map(list(string)), {})
          /// A list of source IP CIDR notations to match. You can use both IPv4 and IPv6 addresses. Wildcards are not supported.
          ///
          /// @since 1.0.0
          source_ips = optional(list(string), null)
        }))
      })), {})

      /// Additional tags for the listener
      ///
      /// @since 1.0.0
      additional_tags = optional(map(string), {})
      /// Additional certificates for Server Name Indication (SNI). This enables the load balancer to support multiple domains on the same port and provide a different certificate for each domain.
      ///
      /// @since 1.0.0
      certificates_for_sni = optional(list(string), [])
      /// The certificate to use if a client connects without SNI protocol, or if there are no matching certificates. This is required if a `HTTPS` listener is specified.
      ///
      /// @since 1.0.0
      default_ssl_certificate_arn = optional(string, null)
      /// Name of the SSL Policy for the listener. This is required if a `HTTPS` listener is specified.
      ///
      /// @since 1.0.0
      security_policy = optional(string, "ELBSecurityPolicy-TLS13-1-2-Res-2021-06")
    }))

    /// Configure listener attributes
    ///
    /// @since 1.0.0
    attributes = optional(object({
      /// The amount of time a client or target connection can be idle before the load balancer closes it. Valid range is `"1 second" - "4000 seconds"`.
      ///
      /// @since 1.0.0
      connection_idle_timeout = optional(string, "1 minute")
      /// Determines how the load balancer handles requests that might pose a security risk to your application.
      ///
      /// @enum defensive|monitor|strictest
      /// @since 1.0.0
      desync_mitigation_mode = optional(string, "defensive")
      /// Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer
      ///
      /// @since 1.0.0
      drop_invalid_header_fields = optional(bool, false)
      /// Controls whether Amazon Application Recovery Controller (ARC) zonal shift is available to the load balancer.
      ///
      /// @since 1.0.0
      enable_arc_zonal_shift_integration = optional(bool, false)
      /// Enable requests using the HTTP/2 protocol
      ///
      /// @since 1.0.0
      enable_http2 = optional(bool, true)
      /// If enabled, the load balancer adds two TLS headers (`x-amzn-tls-version` and `x-amzn-tls-cipher-suite`) to the client request before sending it to the target.
      ///
      /// @since 1.0.0
      enable_tls_version_and_cipher_headers = optional(bool, false)
      /// Whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer.
      ///
      /// @since 1.0.0
      enable_x_forwarded_for_client_port_preservation = optional(bool, false)
      /// Allows requests through to backend target(s) when the application load balancer is unable to contact AWS Web Application Firewall (WAF).
      ///
      /// @since 1.0.0
      enable_waf_fail_open = optional(bool, false)
      /// The amount of time a client connection is kept open before the load balancer closes it. Valid range is `"1 minute" - "7 days"`
      ///
      /// @since 1.0.0
      http_client_keepalive_duration = optional(string, "1 hour")
      /// Whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to targets without any change.
      ///
      /// @since 1.0.0
      preserve_host_header = optional(bool, false)
      /// Rather to append, preserve, or remove the X-Forwarded-For header in the HTTP request before the Application Load Balancer sends the request to the target.
      ///
      /// @enum append|preserve|remove
      /// @since 1.0.0
      x_forwarded_for_header_processing_mode = optional(string, "append")
    }), {})
  })
  description = <<EOT
    Setup an Application load balancer. Mutually exclusive to `gateway_load_balancer`, `network_load_balancer`.

    @example "Application Load Balancer" #application-load-balancer
    @since 1.0.0
  EOT
  default     = null
}

variable "gateway_load_balancer" {
  type = object({
    /// Configure the listener
    ///
    /// @since 1.0.0
    listener = object({
      /// Specify the default action that triggers for the incoming requests.
      ///
      /// @since 1.0.0
      default_action = object({
        /// Configure forward action to route requests to a target group.
        ///
        /// @since 1.0.0
        forward = object({
          /// The ARN of the target group to route traffic to
          ///
          /// @since 1.0.0
          target_group = string
        })
      })

      /// Additional tags for the listener
      ///
      /// @since 1.0.0
      additional_tags = optional(map(string), {})
    })

    /// Configure the load balancer attributes
    ///
    /// @since 1.0.0
    attributes = optional(object({
      /// If enabled. Each load balancer node load balances traffic among healthy targets in all its enabled Availability Zones
      ///
      /// @since 1.0.0
      enable_cross_zone_load_balancing = optional(bool, false)
    }), {})
  })
  description = <<EOT
    Setup a Gateway load balancer. Mutually exclusive to `application_load_balancer`, `network_load_balancer`.

    @example "Gateway Load Balancer" #gateway-load-balancer
    @since 1.0.0
  EOT
  default     = null
}

variable "network_load_balancer" {
  type = object({
    /// Map of listeners in the `<protocol>:<port>` format
    ///
    /// @since 1.0.0
    listeners = map(object({
      /// Specify the default action that triggers for the incoming requests.
      ///
      /// @since 1.0.0
      default_action = object({
        /// Configure forward action to route requests to a target group.
        ///
        /// @since 1.0.0
        forward = object({
          /// The ARN of the target group to route traffic to
          ///
          /// @since 1.0.0
          target_group = string
        })
      })

      /// Configure the listener attributes
      ///
      /// @since 1.0.0
      attributes = optional(object({
        /// The number of seconds before the listener determines that the TCP connection is idle and closes it. Valid values: `"1 minutes" - "100 minutes"`. Only applicable if protocol is `TCP`
        ///
        /// @since 1.0.0
        tcp_idle_timeout = optional(string, "350 seconds")
      }), {})

      /// Additional tags for the listener
      ///
      /// @since 1.0.0
      additional_tags = optional(map(string), {})
      /// Specify the Application-Layer Protocol Negotiation (ALPN) policy. Only applicable if protocol is `TLS`.
      ///
      /// @enum HTTP1Only|HTTP2Only|HTTP2Optional|HTTP2Preferred|None
      /// @since 1.0.0
      alpn_policy = optional(string, null)
      /// Additional certificates for Server Name Indication (SNI). This enables the load balancer to support multiple domains on the same port and provide a different certificate for each domain.
      ///
      /// @since 1.0.0
      certificates_for_sni = optional(list(string), [])
      /// The certificate to use if a client connects without SNI protocol, or if there are no matching certificates. This is required if a `TLS` listener is specified.
      ///
      /// @since 1.0.0
      default_ssl_certificate_arn = optional(string, null)
      /// Name of the SSL Policy for the listener. This is required if a `TLS` listener is specified.
      ///
      /// @since 1.0.0
      security_policy = optional(string, "ELBSecurityPolicy-TLS13-1-2-Res-2021-06")
    }))

    /// Configure the load balancer attributes
    ///
    /// @since 1.0.0
    attributes = optional(object({
      /// How traffic is distributed among the load balancer Availability Zones. Applies only to internal requests for clients resolving the load balancer DNS name using Route 53 Resolver.
      ///
      /// @enum any_availability_zone|availability_zone_affinity|partial_availability_zone_affinity
      /// @since 1.0.0
      client_routing_policy = optional(string, "any_availability_zone")
      /// Controls whether Amazon Application Recovery Controller (ARC) zonal shift is available to the load balancer.
      ///
      /// @since 1.0.0
      enable_arc_zonal_shift_integration = optional(bool, false)
      /// If enabled. Each load balancer node load balances traffic among healthy targets in all its enabled Availability Zones
      ///
      /// @since 1.0.0
      enable_cross_zone_load_balancing = optional(bool, false)
    }), {})
  })
  description = <<EOT
    Setup a Network load balancer. Mutually exclusive to `application_load_balancer`, `gateway_load_balancer`.

    @example "Network Load Balancer" #network-load-balancer
    @since 1.0.0
  EOT
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the load balancer

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

variable "capacity_unit_reservation" {
  type        = number
  description = <<EOT
    Minimum capacity for the load balancer.

    @since 1.0.0
  EOT
  default     = null
}

variable "enable_deletion_protection" {
  type        = bool
  description = <<EOT
    If enabled, you must turn it off before you can delete the load balancer.

    @since 1.0.0
  EOT
  default     = false
}

variable "internet_facing" {
  type        = bool
  description = <<EOT
    Whether the load balancer is publicly accessible

    @since 1.0.0
  EOT
  default     = true
}

variable "ip_address_type" {
  type        = string
  description = <<EOT
    The front-end IP address type to assign to the load balancer. The subnets mapped to this load balancer must include the selected IP address types.

    | LB type     | Valid values
    |-------------|------------------------------------------------------------
    | application | `"ipv4"`, `"dualstack"`, `"dualstack-without-public-ipv4"`
    | gateway     | `"ipv4"`, `"dualstack"`
    | network     | `"ipv4"`, `"dualstack"`

    @enum ipv4|dualstack|dualstack-without-public-ipv4
    @since 1.0.0
  EOT
  default     = "ipv4"
}

variable "security_group_ids" {
  type        = list(string)
  description = <<EOT
    List of security group IDs to assign to the load balancer. Only valid for Load Balancers of type `application` or `network`.

    @since 1.0.0
  EOT
  default     = null
}
