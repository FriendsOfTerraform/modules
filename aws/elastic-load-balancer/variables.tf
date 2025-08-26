variable "name" {
  type        = string
  description = "The name of the load balancer. All associated resources' names will also be prefixed by this value"
}

variable "network_mapping" {
  type = object({
    subnets = map(object({
      elastic_ip_allocation_id = optional(string, null)
      ipv6_address             = optional(string, null)
      private_ipv4_address     = optional(string, null)
    }))

    # This option is not yet available in the latest provider 6.10.0
    # enable_prefix_for_ipv6_source_nat = optional(bool, false)
    ipam_pool_id = optional(string, null)
  })
  description = "Networking configuration of the load balancer"
}

variable "application_load_balancer" {
  type = object({
    listeners = map(object({
      default_action = object({
        authenticate_users = optional(object({
          action_on_unauthenticatedd_request = optional(string, "authenticate")
          extra_request_parameters           = optional(map(string), {})
          scope                              = optional(string, "openid")
          session_cookie_name                = optional(string, "AWSELBAuthSessionCookie")
          session_timeout                    = optional(string, "7 days")

          amazon_cognito = optional(object({
            app_client       = string
            user_pool        = string
            user_pool_domain = string
          }), null)

          oidc = optional(object({
            authorization_endpoint = string
            client_id              = string
            client_secret          = string
            issuer                 = string
            token_endpoint         = string
            user_info_endpoint     = string
          }), null)
        }), null)

        fixed_response = optional(object({
          content_type  = optional(string, "text/plain")
          response_body = optional(string, null)
          response_code = optional(number, 503)
        }), null)

        forward = optional(object({
          target_groups = map(object({
            weight = optional(number, null)
          }))
          turn_on_target_group_stickiness = optional(object({
            duration = optional(string, "1 hour")
          }), null)
        }), null)

        redirect = optional(object({
          url         = string
          status_code = optional(number, 301)
        }), null)
      })

      attributes = optional(object({
        add_alb_server_response_header = optional(bool, true)

        add_response_headers = optional(object({
          access_control_allow_credentials = optional(string, null)
          access_control_allow_headers     = optional(string, null)
          access_control_allow_methods     = optional(string, null)
          access_control_allow_origin      = optional(string, null)
          access_control_expose_headers    = optional(string, null)
          access_control_max_age           = optional(string, null)
          content_security_policy          = optional(string, null)
          http_strict_transport_security   = optional(string, null)
          x_content_type_options           = optional(string, null)
          x_frame_options                  = optional(string, null)
        }), {})

        modify_mtls_header_names = optional(object({
          x_amzn_mtls_clientcert               = optional(string, null)
          x_amzn_mtls_clientcert_issuer        = optional(string, null)
          x_amzn_mtls_clientcert_leaf          = optional(string, null)
          x_amzn_mtls_clientcert_serial_number = optional(string, null)
          x_amzn_mtls_clientcert_subject       = optional(string, null)
          x_amzn_mtls_clientcert_validity      = optional(string, null)
          x_amzn_tls_cipher_suite              = optional(string, null)
          x_amzn_tls_version                   = optional(string, null)
        }), {})
      }), {})

      enable_mutual_authentication = optional(object({
        verify_with_trust_store = optional(object({
          advertise_trust_store_ca_subject_name = optional(bool, false)
          allow_expired_client_certificates     = optional(bool, false)
          trust_store_arn                       = optional(string, null)

          new_trust_store = optional(object({
            certificate_authority_bundle = object({
              s3_uri  = string
              version = optional(string, null)
            })

            additional_tags = optional(map(string), {})

            certificate_revocation_lists = optional(map(object({
              version = optional(string, null)
            })), {})
          }), null)
        }), null)
      }), null)

      rules = optional(map(object({
        priority        = number
        additional_tags = optional(map(string), {})

        action = object({
          authenticate_users = optional(object({
            action_on_unauthenticatedd_request = optional(string, "authenticate")
            extra_request_parameters           = optional(map(string), {})
            scope                              = optional(string, "openid")
            session_cookie_name                = optional(string, "AWSELBAuthSessionCookie")
            session_timeout                    = optional(string, "7 days")

            amazon_cognito = optional(object({
              app_client       = string
              user_pool        = string
              user_pool_domain = string
            }), null)

            oidc = optional(object({
              authorization_endpoint = string
              client_id              = string
              client_secret          = string
              issuer                 = string
              token_endpoint         = string
              user_info_endpoint     = string
            }), null)
          }), null)

          fixed_response = optional(object({
            content_type  = optional(string, "text/plain")
            response_body = optional(string, null)
            response_code = optional(number, 503)
          }), null)

          forward = optional(object({
            target_groups = map(object({
              weight = optional(number, null)
            }))
            turn_on_target_group_stickiness = optional(object({
              duration = optional(string, "1 hour")
            }), null)
          }), null)

          redirect = optional(object({
            url         = string
            status_code = optional(number, 301)
          }), null)
        })

        conditions = list(object({
          host_headers         = optional(list(string), null)
          paths                = optional(list(string), null)
          query_strings        = optional(map(string), {})
          http_request_methods = optional(list(string), null)
          http_headers         = optional(map(list(string)), {})
          source_ips           = optional(list(string), null)
        }))
      })), {})

      additional_tags             = optional(map(string), {})
      certificates_for_sni        = optional(list(string), [])
      default_ssl_certificate_arn = optional(string, null)
      security_policy             = optional(string, "ELBSecurityPolicy-TLS13-1-2-Res-2021-06")
    }))

    attributes = optional(object({
      connection_idle_timeout                         = optional(string, "1 minute")
      desync_mitigation_mode                          = optional(string, "defensive")
      drop_invalid_header_fields                      = optional(bool, false)
      enable_arc_zonal_shift_integration              = optional(bool, false)
      enable_http2                                    = optional(bool, true)
      enable_tls_version_and_cipher_headers           = optional(bool, false)
      enable_x_forwarded_for_client_port_preservation = optional(bool, false)
      enable_waf_fail_open                            = optional(bool, false)
      http_client_keepalive_duration                  = optional(string, "1 hour")
      preserve_host_header                            = optional(bool, false)
      x_forwarded_for_header_processing_mode          = optional(string, "append")
    }), {})
  })
  description = ""
  default     = null
}

variable "gateway_load_balancer" {
  type = object({
    listener = object({
      default_action = object({
        forward = object({
          target_group = string
        })
      })

      additional_tags = optional(map(string), {})
    })

    attributes = optional(object({
      enable_cross_zone_load_balancing = optional(bool, false)
    }), {})
  })
  description = ""
  default     = null
}

variable "network_load_balancer" {
  type = object({
    listeners = map(object({
      default_action = object({
        forward = object({
          target_group = string
        })
      })

      attributes = optional(object({
        tcp_idle_timeout = optional(string, "350 seconds")
      }), {})

      additional_tags             = optional(map(string), {})
      alpn_policy                 = optional(string, null)
      certificates_for_sni        = optional(list(string), [])
      default_ssl_certificate_arn = optional(string, null)
      security_policy             = optional(string, "ELBSecurityPolicy-TLS13-1-2-Res-2021-06")
    }))

    attributes = optional(object({
      client_routing_policy              = optional(string, "any_availability_zone")
      enable_arc_zonal_shift_integration = optional(bool, false)
      enable_cross_zone_load_balancing   = optional(bool, false)
    }), {})
  })
  description = ""
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the share"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "capacity_unit_reservation" {
  type        = number
  description = ""
  default     = null
}

variable "enable_deletion_protection" {
  type        = bool
  description = ""
  default     = false
}

variable "internet_facing" {
  type        = bool
  description = ""
  default     = true
}

variable "ip_address_type" {
  type        = string
  description = ""
  default     = "ipv4"
}

variable "security_group_ids" {
  type        = list(string)
  description = ""
  default     = null
}
