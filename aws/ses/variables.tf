# Tenant is commented out for now until tenant support is added to all resources
# auto_validation_settings is commented out for now until SES provider supports it
variable "domains" {
  type = map(object({
    additional_tags           = optional(map(string), {})
    default_configuration_set = optional(string, null)
    # tenant                    = optional(string, null)

    dkim_settings = optional(object({
      dkim_signatures_enabled = optional(bool, true)

      easy_dkim = optional(object({
        signing_key_length = optional(string, "RSA_2048_BIT")
      }), null)

      provide_dkim_authentication_token = optional(object({
        private_key   = string
        selector_name = string
      }), null)
    }), null)

    email_addresses = optional(map(object({
      additional_tags           = optional(map(string), {})
      default_configuration_set = optional(string, null)
      # tenant                    = optional(string, null)
    })), {})

    use_custom_mail_from_domain = optional(object({
      behavior_on_mx_failure = optional(string, "USE_DEFAULT_VALUE")
      subdomain_name         = optional(string, null)
    }), null)
  }))
  description = "Manages SES Domains and Email Addresses"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "configuration_sets" {
  type = map(object({
    sending_ip_pool            = optional(string, null)
    additional_tags            = optional(map(string), {})
    require_tls                = optional(bool, false)
    maximum_delivery_duration  = optional(string, null)
    reputation_metrics_enabled = optional(bool, false)
    # tenant                     = optional(string, null)

    event_destinations = optional(map(object({
      event_types = list(string)
      enabled     = optional(bool, true)

      destination = object({
        cloudwatch = optional(object({
          dimensions = map(string) # e.g. { ValueSource/DimensionName = "DimensionValue" }
        }), null)

        kinesis_firehose = optional(object({
          delivery_stream_arn = string
          iam_role_arn        = string
        }), null)

        pinpoint = optional(object({
          application_arn = string
        }), null)

        sns = optional(object({
          topic_arn = string
        }), null)
      })
    })), {})

    override_account_level_settings = optional(object({
      # auto_validation_settings = optional(object({
      #   validation_threshold = optional(string, null)
      # }), null)

      suppression_list_settings = optional(object({
        suppression_reason = optional(list(string), ["BOUNCE", "COMPLAINT"])
      }), null)

      virtual_deliverability_manager_options = optional(object({
        engagement_tracking_enabled       = optional(bool, false)
        optimized_shared_delivery_enabled = optional(bool, false)
      }), null)
    }), null)

    use_a_custom_redirect_domain = optional(object({
      domain_name  = string
      https_policy = optional(string, "OPTIONAL")
    }), null)
  }))
  description = "Manages SES Configuration Sets"
  default     = {}
}

variable "dedicated_ip_pools" {
  type = map(object({
    additional_tags = optional(map(string), {})
    ip_addresses    = optional(list(string), [])
    scaling_mode    = optional(string, "MANAGED")
  }))
  description = "Manages SES Dedicated IP Pools"
  default     = {}
}

variable "tenants" {
  type = map(object({
    additional_tags = optional(map(string), {})
  }))
  description = "Manages SES Tenants"
  default     = {}
}