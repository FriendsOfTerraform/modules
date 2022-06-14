variable "authentication_method" {
  type        = string
  description = "The Vault authentication method to configure"
}

variable "mount_path" {
  type        = string
  description = "The mount path of the authentication method"
}

variable "description" {
  type        = string
  description = "Description of the authentication method"
  default     = "Managed by Terraform"
}

variable "method_options" {
  type = object({
    default_lease_ttl  = optional(string)
    max_lease_ttl      = optional(string)
    listing_visibility = optional(string)
  })

  description = "Common authentication method options"
  default     = null
}

//
// AppRole
//

variable "approle_auth_roles" {
  type = map(object({
    secret_id_bound_cidrs = optional(list(string))
    secret_id_num_uses    = optional(number)
    token_ttl_seconds     = optional(number)
    token_max_ttl_seconds = optional(number)
    token_policies        = list(string)
  }))

  description = "Configure an AppRole authenticate method role in RoleName = Configuration format"
  default     = {}
}

//
// AWS
//

variable "aws_backend_credential" {
  type = object({
    access_key_id     = string
    secret_access_key = string
  })

  description = "Credential Vault will use to make AWS API call."
  default     = null
}

variable "aws_auth_roles" {
  type = map(object({
    sts_role_arn             = string
    bound_iam_principal_arns = optional(list(string))
    token_ttl_seconds        = optional(number)
    token_max_ttl_seconds    = optional(number)
    token_policies           = list(string)
  }))

  description = "Configures an AWS authentication role in RoleName = {RoleConfig} format"
  default     = {}
}

//
// Github
//

variable "github_config" {
  type = object({
    organization = string
    teams        = optional(map(list(string)))
    users        = optional(map(list(string)))
  })

  description = "Configuration of Github auth method"
  default     = null
}

//
// Kubernetes
//

variable "kubernetes_config" {
  type = object({
    host               = string
    ca_certificate     = string
    token_reviewer_jwt = string
    issuer             = optional(string)
  })

  description = "Configuration of Kubernetes auth method"
  default     = null
}

variable "kubernetes_auth_roles" {
  type = map(object({
    bound_service_account_names      = optional(list(string))
    bound_service_account_namespaces = optional(list(string))
    token_ttl_seconds                = optional(number)
    token_max_ttl_seconds            = optional(number)
    token_policies                   = list(string)
  }))

  description = "Configure a Kubernetes authenticate method role in RoleName = Configuration format"
  default     = {}
}

//
// OIDC
//

variable "oidc_config" {
  type = object({
    default_role  = optional(string)
    discovery_url = string
    client_id     = string
    client_secret = string
  })

  description = "Configuration of OIDC auth method"
  default     = null
}

variable "oidc_auth_roles" {
  type = map(object({
    user_claim            = optional(string)
    bound_claims          = optional(map(string))
    groups_claim          = optional(string)
    oidc_scopes           = optional(list(string))
    allowed_redirect_uris = optional(list(string))
    token_ttl_seconds     = optional(number)
    token_max_ttl_seconds = optional(number)
    token_policies        = list(string)
  }))

  description = "Configure a OIDC authenticate method role in RoleName = Configuration format"
  default     = {}
}