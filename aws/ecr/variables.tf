variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "private_registry" {
  type = object({
    permissions = optional(string, null)

    pull_through_cache_rules = optional(map(object({
      upstream_registry_url = string
      credential_arn        = optional(string, null)
    })), {})

    replication_rules = optional(list(object({
      destinations = list(string)
      filters      = optional(list(string), [])
    })), [])

    repositories = optional(map(object({
      additional_tags         = optional(map(string), {})
      enable_tag_immutability = optional(bool, false)
      encrypt_with_kms = optional(object({
        kms_key_id = optional(string, null)
      }), null)
      force_delete = optional(bool, false)
      permissions  = optional(string, null)
      lifecycle_policy_rules = optional(list(object({
        match_criteria = object({
          days_since_image_pushed = optional(number, null)
          image_count_more_than   = optional(number, null)
        })
        priority    = number
        description = optional(string, null)
        tag_filters = optional(list(string), null)
      })), [])
    })), {})

    scanning_configuration = optional(object({
      scan_type = optional(string, "BASIC")
      continuous_scanning = optional(object({
        filters = optional(list(string), ["*"])
      }), null)
      scan_on_push = optional(object({
        filters = optional(list(string), ["*"])
      }), null)
    }), null)
  })

  description = "manages private registry"
  default     = null
}

variable "public_registry" {
  type = object({
    repositories = optional(map(object({
      about_text        = optional(string, null)
      additional_tags   = optional(map(string), {})
      architectures     = optional(list(string), null)
      description       = optional(string, null)
      logo_image_blob   = optional(string, null)
      operating_systems = optional(list(string), null)
      usage_text        = optional(string, null)
    })), {})
  })

  description = "manages public registry"
  default     = null
}
