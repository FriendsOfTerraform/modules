variable "azure" {
  type = object({
    resource_group_name = string
    location            = optional(string)
  })

  description = "Where the resources will be deployed on"
}

variable "cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for the virtual network"
}

variable "ddos_protection_plan_id" {
  type        = string
  description = "Enables DDOS protection"
  default     = null
}

variable "name" {
  type        = string
  description = "The name of the virtual network and all of its associated resources"
}

variable "additional_dns_server_addresses" {
  type        = list(string)
  description = "Additional DNS server addresses on top of Azure's default DNS server"
  default     = []
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the virtual network"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "nat_gateway" {
  type = object({
    enabled                 = bool
    public_ip_prefix_length = optional(string)
    additional_tags         = optional(map(string))
  })

  description = "Enable and configure NAT gateway"

  default = {
    enabled = false
  }
}

variable "service_endpoints" {
  type        = list(string)
  description = "A list of service endpoints to be enabled in all subnets"
  default     = []
}

variable "subnets" {
  type = map(object(
    {
      cidr_block                  = string
      network_security_group_name = optional(string)
      route_table_name            = optional(string)
      service_endpoints           = optional(list(string))
    }
  ))

  description = "A map of subnets to be created, in the {name = {configurations}} format"
  default     = {}
}
