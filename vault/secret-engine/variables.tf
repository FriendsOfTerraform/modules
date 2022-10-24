//
// Global
//

variable "secret_engine" {
  type        = string
  description = "The Vault secret engine to configure"
}

variable "mount_path" {
  type        = string
  description = "The mount path of the secret engine"
}

variable "description" {
  type        = string
  description = "Description of the secret engine"
  default     = "Managed by Terraform"
}

variable "default_ttl_seconds" {
  type        = number
  description = "Global default TTL for the secret engine"
  default     = null
}

variable "max_ttl_seconds" {
  type        = number
  description = "Global max TTL for the secret engine"
  default     = null
}

//
// AWS
//

variable "aws_config" {
  type = object({
    access_key_id       = string
    secret_access_key   = string
    region              = string
    default_ttl_seconds = optional(number)
    max_ttl_seconds     = optional(number)
  })

  description = "AWS secret engine configuration"
  default     = null
}

variable "aws_secret_backend_roles" {
  type = map(object({
    role_arns               = optional(list(string))
    iam_group_names         = optional(list(string))
    aws_managed_policy_arns = optional(list(string))
    inline_policy_document  = optional(string)
  }))

  description = "A map of AWS secret engine roles, in the {role_name = {config}} format"
  default     = {}
}

//
// Azure
//

variable "azure_config" {
  type = object({
    subscription_id     = string
    tenant_id           = string
    client_id           = optional(string)
    client_secret       = optional(string)
    default_ttl_seconds = optional(number)
    max_ttl_seconds     = optional(number)
  })

  description = "Azure secret engine configuration"
  default     = null
}

variable "azure_secret_backend_roles" {
  type = map(object({
    application_object_id = optional(string)

    azure_roles = optional(list(object({
      role_id   = optional(string)
      role_name = optional(string)
      scope     = string
    })))

    azure_groups = optional(list(object({
      group_name = optional(string)
      object_id  = optional(string)
    })))

    ttl_seconds     = optional(number)
    max_ttl_seconds = optional(number)
  }))

  description = "A map of Azure secret engine roles, in the {role_name = {config}} format"
  default     = {}
}

//
// Database
//

variable "database_config" {
  type = object({
    postgres = optional(map(object({
      allowed_roles                   = optional(list(string))
      connection_url                  = string
      max_open_connections            = optional(number)
      max_idle_connections            = optional(number)
      max_connection_lifetime_seconds = optional(number)
    })))
  })

  description = "Database secret engine configuration"
  default     = null
}

variable "database_static_backend_roles" {
  type = map(object({
    database_name           = string
    rotation_period_seconds = optional(number)
  }))

  description = "Map a Vault database role to a user in a database"
  default     = {}
}

//
// PKI
//

variable "pki_config" {
  type = object({
    cert_type = string
  })

  description = "PKI secret engine configuration"
  default     = null
}

variable "pki_root_cert" {
  type = object({
    common_name       = string
    alternative_names = optional(list(string))
    ttl_seconds       = optional(number)
    vault_address     = string
  })

  description = "Root CA cert configuration"
  default     = null
}

variable "pki_intermediate_ca" {
  type = object({
    signing_ca_mount_path = string
    common_name           = string
    alternative_names     = optional(list(string))
    ttl_seconds           = optional(number)
  })

  description = "Intermediate CA configuration"
  default     = null
}

variable "pki_secret_backend_roles" {
  type = map(object({
    ttl_seconds      = optional(number)
    max_ttl_seconds  = optional(number)
    allowed_domains  = optional(list(string))
    allowed_uri_sans = optional(list(string))
  }))

  description = "Map of PKI secret backend roles. In {role_name = {config}} format."
  default     = {}
}

//
// Terraform Cloud
//

variable "terraform_config" {
  type = object({
    token = string
  })

  description = "Terraform cloud secret engine configuration"
  default     = null
}

variable "terraform_secret_backend_roles" {
  type = map(object({
    token_identity  = string
    ttl_seconds     = optional(number)
    max_ttl_seconds = optional(number)
  }))

  description = "Map of Terraform cloud secret backend roles. In {role_name = {config}} format"
  default     = {}
}