variable "azure" {
  type = object({
    resource_group_name = string
    location            = optional(string)
  })

  description = "Where the resources will be deployed on"
}

variable "name" {
  type        = string
  description = "The name of the Front Door profile. All associated resources' names will also be prefixed by this value"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the Front Door profile"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "endpoints" {
  type = map(object({
    routes = optional(map(object({
      origin_group_name = string
      enabled           = optional(bool)
      # custom_domains = optional(list(string))
      forwarding_protocol    = optional(string)
      patterns_to_match      = optional(list(string))
      accepted_protocols     = optional(list(string))
      origin_path            = optional(string)
      https_redirect_enabled = optional(bool)
      link_to_default_domain = optional(bool)
    })))

    enabled         = optional(bool)
    additional_tags = optional(map(string))
  }))

  description = "Defines a Front Door endpoint"
  default     = {}
}

variable "origin_groups" {
  type = map(object({
    origins = optional(map(object({
      hostname                            = string
      certificate_subject_name_validation = optional(bool)
      http_port                           = optional(number)
      https_port                          = optional(number)
      origin_host_header                  = optional(string)
      priority                            = optional(number)
      weight                              = optional(number)
      enabled                             = optional(bool)
    })))

    session_affinity_enabled = optional(bool)

    health_probe = optional(object({
      protocol         = optional(string) # Http
      interval_seconds = optional(number) # 100
      probe_method     = optional(string) # HEAD
      path             = optional(string) # /
    }))

    load_balancing = optional(object({
      latency_sensitivity_milliseconds = optional(number)
      sample_size                      = optional(number)
      successful_samples_required      = optional(number)
    }))
  }))

  description = "Defines origin groups for this profile"
  default     = {}
}

variable "response_timeout_seconds" {
  type        = number
  description = "Number of seconds before the send/received request times out. Valid values 16 - 240"
  default     = 120
}

variable "tier" {
  type        = string
  description = "Define the tier of the Front Door service. Standard or Premium"
  default     = "Standard"
}