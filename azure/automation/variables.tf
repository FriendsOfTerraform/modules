variable "azure" {
  type = object({
    resource_group_name = string
    location            = optional(string)
  })

  description = "Where the resources will be deployed on"
}

variable "name" {
  type        = string
  description = "The name of the automation account. All associated resources' names will also be prefixed by this value"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the automation account"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "runbooks" {
  type = map(object({
    content         = string
    additional_tags = optional(map(string))
    description     = optional(string)
    log_progress    = optional(bool)
    log_verbose     = optional(bool)
    runbook_type    = optional(string)

    schedule = optional(object({
      description = optional(string)
      timezone    = optional(string)
      start_time  = optional(string)
      expiry_time = optional(string)
      parameters  = optional(map(string))

      hourly = optional(object({
        interval = optional(number)
      }))

      daily = optional(object({
        interval = optional(number)
      }))

      weekly = optional(object({
        interval = optional(number)
        every    = list(string)
      }))

      monthly = optional(object({
        interval = optional(number)
        every    = list(string)
      }))
    }))
  }))

  description = "Defines and manages a list of Runbooks"
  default     = {}
}

variable "user_assigned_managed_identity_ids" {
  type        = list(string)
  description = "List of managed identity IDs used by the automation account to manage azure resources"
  default     = []
}