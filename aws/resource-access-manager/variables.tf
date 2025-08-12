variable "name" {
  type        = string
  description = "The name of the share. All associated resources' names will also be prefixed by this value"
}

variable "accept_sharings" {
  type        = list(string)
  description = "ARNs of the share to accept"
  default     = []
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

variable "allow_external_principals" {
  type        = bool
  description = "whether principals outside your organization can be associated with a resource share"
  default     = false
}

variable "principals" {
  type        = list(string)
  description = "List of principals to grant access of the resources"
  default     = []
}

variable "resources" {
  type        = list(string)
  description = "List of ARNs of the resources to share"
  default     = []
}
