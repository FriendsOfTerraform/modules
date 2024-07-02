variable "domain_name" {
  type        = string
  description = "The domain name of the hosted zone"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the kubernetes cluster"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "description" {
  type        = string
  description = "The description of the hosted zone"
  default     = null
}

variable "enables_dnssec" {
  type = object({
    key_signing_keys = map(object({
      kms_key_id = optional(string, null)
      status     = optional(string, "ACTIVE")
    }))

    status = optional(string, "SIGNING")
  })
  description = ""
  default     = null
}

variable "private_zone_vpc_associations" {
  type        = map(list(string))
  description = "one or more VPC IDs this private hosted zone is used to resolve DNS queries for"
  default     = {}
}

variable "records" {
  type = map(object({
    type            = string
    values          = list(string)
    alias_target    = optional(string, null) #TODO
    health_check_id = optional(string, null)
    ttl             = optional(number, 300)

    failover_routing_policy = optional(object({
      failover_record_type = string
    }), null)

    geolocation_routing_policy = optional(object({
      location = string
    }), null)

    geoproximity_routing_policy = optional(object({
      bias             = optional(number, 0)
      local_zone_group = optional(string, null)
      region           = optional(string, null)

      coordinates = optional(object({
        latitude  = string
        longitude = string
      }), null)
    }), null)

    health_check = optional(object({
      enabled                    = optional(bool, true)
      invert_health_check_status = optional(bool, false)

      calculated_check = optional(object({
        health_checks_to_monitor = list(string)
        healthy_threshold        = optional(number, null)
      }), null)

      cloudwatch_alarm_check = optional(object({
        alarm_name                      = string
        alarm_region                    = optional(string, null)
        insufficient_data_health_status = optional(string, "LastKnownStatus")
      }), null)

      cloudwatch_alarms = optional(map(object({
        metric_name            = string # HealthCheckPercentageHealthy, HealthCheckStatus, ChildHealthCheckHealthyCount
        expression             = string # statistic comparison_operator threshold
        evaluation_periods     = optional(number, 1)
        period                 = optional(number, 60)
        notification_sns_topic = optional(string, null)
      })), {})

      endpoint_check = optional(object({
        url                   = string
        enable_latency_graphs = optional(bool, false)
        failure_threshold     = optional(number, 3)
        hostname              = optional(string, null)
        regions               = optional(list(string), null)
        request_interval      = optional(number, 30)
        search_string         = optional(string, null)
      }), null)
    }), null)

    latency_routing_policy = optional(object({
      region = string
    }), null)

    multivalue_answer_routing_policy = optional(object({
      enabled = optional(bool, true)
    }), null)

    weighted_routing_policy = optional(object({
      weight = number
    }), null)
  }))
  description = ""
  default     = {}
}
