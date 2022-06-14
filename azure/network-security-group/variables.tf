variable "azure" {
  type = object({
    resource_group_name = string
    location            = optional(string)
  })

  description = "Where the resources will be deployed on"
}

variable "name" {
  type        = string
  description = "The name of the network security group"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the network security group"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "inbound_security_rules" {
  type = map(object({
    priority                                   = number
    action                                     = optional(string)
    description                                = optional(string)
    destination_application_security_group_ids = optional(list(string))
    destination_ip_addresses                   = optional(list(string))
    destination_service_tag                    = optional(string)
    port_ranges                                = optional(list(string))
    protocol                                   = optional(string)
    source_application_security_group_ids      = optional(list(string))
    source_ip_addresses                        = optional(list(string))
    source_service_tag                         = optional(string)
  }))

  description = "Manages multiple inbound security rules"
  default     = {}
}

variable "outbound_security_rules" {
  type = map(object({
    priority                                   = number
    action                                     = optional(string)
    description                                = optional(string)
    destination_application_security_group_ids = optional(list(string))
    destination_ip_addresses                   = optional(list(string))
    destination_service_tag                    = optional(string)
    port_ranges                                = optional(list(string))
    protocol                                   = optional(string)
    source_application_security_group_ids      = optional(list(string))
    source_ip_addresses                        = optional(list(string))
    source_service_tag                         = optional(string)
  }))

  description = "Manages multiple outbound security rules"
  default     = {}
}
