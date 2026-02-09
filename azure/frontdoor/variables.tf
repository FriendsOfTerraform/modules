variable "azure" {
  type = object({
    /// The name of an Azure resource group where the Front Door will be deployed
    ///
    /// @since 0.0.1
    resource_group_name = string
    /// The name of an Azure location where the Front Door will be deployed. If unspecified, the resource group's location will be used.
    ///
    /// @since 0.0.1
    location            = optional(string)
  })

  description = <<EOT
    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    @since 0.0.1
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the Azure Front Door profile. This will also be used as a prefix to all associated resources' names.

    @since 0.0.1
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the Azure Front Door

    @since 0.0.1
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 0.0.1
  EOT
  default     = {}
}

variable "endpoints" {
  type = map(object({
    /// Defines a map of routes, in `route_name = {configuration}` format
    ///
    /// @since 0.0.1
    routes = optional(map(object({
      /// The name of the Front Door Origin Group where this Front Door Route should be created. YOU MUST DEFINE AN ORIGIN GROUP CREATED BY THE SAME MODULE.
      ///
      /// @since 0.0.1
      origin_group_name = string
      /// Enables the route
      ///
      /// @since 0.0.1
      enabled           = optional(bool)
      # custom_domains = optional(list(string))
      /// The Protocol that will be use when forwarding traffic to backends.
      ///
      /// @enum HttpOnly|HttpsOnly|MatchRequest
      /// @since 0.0.1
      forwarding_protocol    = optional(string)
      /// The route patterns of the rule
      ///
      /// @since 0.0.1
      patterns_to_match      = optional(list(string))
      /// One or more Protocols supported by this Front Door Route.
      ///
      /// @enum Http|Https
      /// @since 0.0.1
      accepted_protocols     = optional(list(string))
      /// A directory path on the Front Door Origin that can be used to retrieve content
      ///
      /// @since 0.0.1
      origin_path            = optional(string)
      /// Automatically redirect HTTP traffic to HTTPS traffic
      ///
      /// @since 0.0.1
      https_redirect_enabled = optional(bool)
      /// Defines if this Front Door Route should be linked to the default endpoint
      ///
      /// @since 0.0.1
      link_to_default_domain = optional(bool)
    })))

    /// Enables the endpoint
    ///
    /// @since 0.0.1
    enabled         = optional(bool)
    /// Additional tags for the endpoint
    ///
    /// @since 0.0.1
    additional_tags = optional(map(string))
  }))

  description = <<EOT
    Defines Front Door endpoints with associating routes

    @since 0.0.1
  EOT
  default     = {}
}

variable "origin_groups" {
  type = map(object({
    /// Defines a map of origins, in `origin_name = {configuration}` format
    ///
    /// @since 0.0.1
    origins = optional(map(object({
      /// The IPv4 address, IPv6 address or Domain name of the Origin
      ///
      /// @since 0.0.1
      hostname                            = string
      /// Specifies whether certificate name checks are enabled for this origin
      ///
      /// @since 0.0.1
      certificate_subject_name_validation = optional(bool)
      /// The value of the HTTP port. Must be between `1` and `65535`
      ///
      /// @since 0.0.1
      http_port                           = optional(number)
      /// The value of the HTTPS port. Must be between `1` and `65535`
      ///
      /// @since 0.0.1
      https_port                          = optional(number)
      /// The host header value (an IPv4 address, IPv6 address or Domain name), which is sent to the origin with each request. If unspecified the hostname from the request will be used.
      ///
      /// @since 0.0.1
      origin_host_header                  = optional(string)
      /// Priority of origin in given origin group for load balancing. Higher priorities will not be used for load balancing if any lower priority origin is healthy. Must be between `1` and `5`
      ///
      /// @since 0.0.1
      priority                            = optional(number)
      /// The weight of the origin in a given origin group for load balancing. Must be between `1` and `1000`
      ///
      /// @since 0.0.1
      weight                              = optional(number)
      /// Enables the origin
      ///
      /// @since 0.0.1
      enabled                             = optional(bool)
    })))

    /// Specifies whether session affinity should be enabled on this host
    ///
    /// @since 0.0.1
    session_affinity_enabled = optional(bool)

    /// Configures the health probe of this origin group
    ///
    /// @since 0.0.1
    health_probe = optional(object({
      /// Specifies the protocol to use for health probe.
      ///
      /// @enum Http|Https
      /// @since 0.0.1
      protocol         = optional(string) # Http
      /// Specifies the number of seconds between health probes. Possible values are between `5` and `31536000` seconds
      ///
      /// @since 0.0.1
      interval_seconds = optional(number) # 100
      /// Specifies the type of health probe request that is made.
      ///
      /// @enum GET|HEAD
      /// @since 0.0.1
      probe_method     = optional(string) # HEAD
      /// Specifies the path relative to the origin that is used to determine the health of the origin.
      ///
      /// @since 0.0.1
      path             = optional(string) # /
    }))

    /// Configure the load balancing settings to define what sample set we need to use to call the backend as healthy or unhealthy
    ///
    /// @since 0.0.1
    load_balancing = optional(object({
      /// Latency sensitivity for identifying backends with least latency. Possible values are between `0` and `1000`
      ///
      /// @since 0.0.1
      latency_sensitivity_milliseconds = optional(number)
      /// Sample size to assess backend availability. Possible values are between `0` and `255`
      ///
      /// @since 0.0.1
      sample_size                      = optional(number)
      /// Successful samples required to declare the backend healthy. Possible values are between `0` and `255`
      ///
      /// @since 0.0.1
      successful_samples_required      = optional(number)
    }))
  }))

  description = <<EOT
    Defines Front Door origin groups with associating origins, in `origin_group_name = {config}` format

    @since 0.0.1
  EOT
  default     = {}
}

variable "response_timeout_seconds" {
  type        = number
  description = <<EOT
    Number of seconds before the send/received request times out. Valid values `16 - 240`

    @since 0.0.1
  EOT
  default     = 120
}

variable "tier" {
  type        = string
  description = <<EOT
    Define the tier of the Front Door service.

    @enum Standard|Premium
    @since 0.0.1
  EOT
  default     = "Standard"
}
