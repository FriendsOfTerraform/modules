variable "azure" {
  type = object({
    resource_group_name = string
    location            = optional(string, null)
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
    action                                     = optional(string, "Allow")
    description                                = optional(string, null)
    destination_application_security_group_ids = optional(list(string), null)
    destination_ip_addresses                   = optional(list(string), null)
    destination_service_tag                    = optional(string, null)
    port_ranges                                = optional(list(string), null)
    protocol                                   = optional(string, "Tcp")
    source_application_security_group_ids      = optional(list(string), null)
    source_ip_addresses                        = optional(list(string), null)
    source_service_tag                         = optional(string, null)
  }))

  description = "Manages multiple inbound security rules"
  default     = {}
}

variable "outbound_security_rules" {
  type = map(object({
    priority                                   = number
    action                                     = optional(string, "Allow")
    description                                = optional(string, null)
    destination_application_security_group_ids = optional(list(string), null)
    destination_ip_addresses                   = optional(list(string), null)
    destination_service_tag                    = optional(string, null)
    port_ranges                                = optional(list(string), null)
    protocol                                   = optional(string, "Tcp")
    source_application_security_group_ids      = optional(list(string), null)
    source_ip_addresses                        = optional(list(string), null)
    source_service_tag                         = optional(string, null)
  }))

  description = "Manages multiple outbound security rules"
  default     = {}
}
