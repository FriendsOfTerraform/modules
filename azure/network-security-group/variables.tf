variable "azure" {
  type = object({
    /// The name of an Azure resource group where the virtual network will be deployed
    ///
    /// @since 0.0.1
    resource_group_name = string
    /// The name of an Azure location where the virtual network will be deployed. If unspecified, the resource group's location will be used.
    ///
    /// @since 0.0.1
    location            = optional(string, null)
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
    The name of the network security group. This will also be used as a prefix to all associating resources' names.

    @since 0.0.1
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the network security group

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

variable "inbound_security_rules" {
  type = map(object({
    /// The priority of the rule. Lower number has higher priority
    ///
    /// @since 0.0.1
    priority                                   = number
    /// Defines if the matching rule should be allowed or denied.
    ///
    /// @enum Allow|Deny
    /// @since 0.0.1
    action                                     = optional(string, "Allow")
    /// Description of the security rule
    ///
    /// @since 0.0.1
    description                                = optional(string, null)
    /// Defines a list of destination application security group IDs that match this rule. This option is mutually exclusive to `destination_ip_addresses` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.
    ///
    /// @since 0.0.1
    destination_application_security_group_ids = optional(list(string), null)
    /// Defines a list of destination ip addresses or CIDR that match this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.
    ///
    /// @since 0.0.1
    destination_ip_addresses                   = optional(list(string), null)
    /// Defines a destination [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_ip_addresses`. If none of the destinations are specified, all destinations (`Any`) will be used.
    ///
    /// @link {service-tag} https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview#available-service-tags
    /// @since 0.0.1
    destination_service_tag                    = optional(string, null)
    /// Defines a list of port ranges that match this rule. Input can either be a range eg. `"0-1024"` or a port number eg. `"8080"`
    ///
    /// @since 0.0.1
    port_ranges                                = optional(list(string), null)
    /// The protocol of the connection that matches this rule.
    ///
    /// @enum Tcp|Udp|Icmp|Esp|Ah|*
    /// @since 0.0.1
    protocol                                   = optional(string, "Tcp")
    /// Defines a list of source application security group IDs that match this rule. This option is mutually exclusive to `source_ip_addresses` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.
    ///
    /// @since 0.0.1
    source_application_security_group_ids      = optional(list(string), null)
    /// Defines a list of source ip addresses or CIDR that match this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.
    ///
    /// @since 0.0.1
    source_ip_addresses                        = optional(list(string), null)
    /// Defines a source [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_ip_addresses`. If none of the sources are specified, all sources (`Any`) will be used.
    ///
    /// @link {service-tag} https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview#available-service-tags
    /// @since 0.0.1
    source_service_tag                         = optional(string, null)
  }))

  description = <<EOT
    Manages multiple inbound security rules, in `{rule_name = {configuration}}` format.

    ```terraform
    inbound_security_rules = {
      rdp = {
        priority            = 100
        description         = "Allows RDP from a particular CIDR"
        source_ip_addresses = ["10.0.0.0/24"]
        port_ranges         = ["3389"]
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = {}
}

variable "outbound_security_rules" {
  type = map(object({
    /// The priority of the rule. Lower number has higher priority
    ///
    /// @since 0.0.1
    priority                                   = number
    /// Defines if the matching rule should be allowed or denied.
    ///
    /// @enum Allow|Deny
    /// @since 0.0.1
    action                                     = optional(string, "Allow")
    /// Description of the security rule
    ///
    /// @since 0.0.1
    description                                = optional(string, null)
    /// Defines a list of destination application security group IDs that match this rule. This option is mutually exclusive to `destination_ip_addresses` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.
    ///
    /// @since 0.0.1
    destination_application_security_group_ids = optional(list(string), null)
    /// Defines a list of destination ip addresses or CIDR that match this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.
    ///
    /// @since 0.0.1
    destination_ip_addresses                   = optional(list(string), null)
    /// Defines a destination [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_ip_addresses`. If none of the destinations are specified, all destinations (`Any`) will be used.
    ///
    /// @link {service-tag} https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview#available-service-tags
    /// @since 0.0.1
    destination_service_tag                    = optional(string, null)
    /// Defines a list of port ranges that match this rule. Input can either be a range eg. `"0-1024"` or a port number eg. `"8080"`
    ///
    /// @since 0.0.1
    port_ranges                                = optional(list(string), null)
    /// The protocol of the connection that matches this rule.
    ///
    /// @enum Tcp|Udp|Icmp|Esp|Ah|*
    /// @since 0.0.1
    protocol                                   = optional(string, "Tcp")
    /// Defines a list of source application security group IDs that match this rule. This option is mutually exclusive to `source_ip_addresses` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.
    ///
    /// @since 0.0.1
    source_application_security_group_ids      = optional(list(string), null)
    /// Defines a list of source ip addresses or CIDR that match this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.
    ///
    /// @since 0.0.1
    source_ip_addresses                        = optional(list(string), null)
    /// Defines a source [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_ip_addresses`. If none of the sources are specified, all sources (`Any`) will be used.
    ///
    /// @link {service-tag} https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview#available-service-tags
    /// @since 0.0.1
    source_service_tag                         = optional(string, null)
  }))

  description = <<EOT
    Manages multiple outbound security rules, in `{rule_name = {configuration}}` format.

    ```terraform
    outbound_security_rules = {
      dns = {
        priority    = 100
        description = "Allow all outbound DNS call"
        port_ranges = ["53"]
        protocol    = "Udp"
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = {}
}
