variable "trust_anchors" {
  type = map(object({
    certificate_authority_source = object({
      aws_private_certificate_authority_arn = optional(string)
      external_certificate_bundle           = optional(string)
    })

    additional_tags = optional(map(string), {})
  }))

  description = "Manages multiple trust anchors, which refers to the trust relationship between Roles Anywhere and your Certificate Authority (CA)."
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "profiles" {
  type = map(object({
    roles = map(object({
      attached_policy_arns = list(string)
      trust_anchor_name    = string
      conditions           = optional(map(string))
      permissions_boundary = optional(string)
    }))

    additional_tags             = optional(map(string), {})
    require_instance_properties = optional(bool)
    session_duration_seconds    = optional(number)

    session_policy = optional(object({
      inline_policy       = optional(string)
      managed_policy_arns = optional(list(string))
    }))
  }))

  description = "Manages multiple profiles, which are predefined sets of permissions that are applied after successfully authenticating with Roles Anywhere."
  default     = {}
}
