variable "name" {
  type        = string
  description = "The name of the security group. All associated resources' names will also be prefixed by this value"
}

variable "vpc_id" {
  type        = string
  description = ""
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the security group"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "description" {
  type        = string
  description = "Description of the security group"
  default     = null
}

variable "egress_rules" {
  type = map(object({
    destinations    = list(string)
    additional_tags = optional(map(string), {})
    description     = optional(string)
  }))
  description = ""
  default     = {}
}

variable "ingress_rules" {
  type = map(object({
    sources         = list(string)
    additional_tags = optional(map(string), {})
    description     = optional(string)
  }))
  description = ""
  default     = {}
}
