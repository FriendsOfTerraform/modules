variable "trust_anchors" {
  type = map(object({
    /// Specify the source of trust (Certificate authority source)
    /// 
    /// @since 1.0.0
    certificate_authority_source = object({
      /// The ARN of the Certificate authorities (CA) from AWS Certificate Manager in your account for this region. Mutually exclusive to `external_certificate_bundle`
      /// 
      /// @since 1.0.0
      aws_private_certificate_authority_arn = optional(string)
      /// Specify the PEM-encoded private CA certificate bundle. Mutually exclusive to `aws_private_certificate_authority_arn`. The certificate must meet the following constrains:
      /// 
      /// @since 1.0.0
      external_certificate_bundle           = optional(string)
    })

    /// Additional tags for the trust anchor
    /// 
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
  }))

  description = <<EOT
    Manages multiple [trust anchors][iam-roles-anywhere-trust-anchor]. A trust anchor refers to the trust relationship between Roles Anywhere and your Certificate Authority (CA). Certificates are used to authenticate against the trust anchor to obtain credentials for an IAM role.
    
    @since 1.0.0
  EOT
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "profiles" {
  type = map(object({
    /// Manages multiple IAM roles that are attached to this profile
    /// 
    /// @since 1.0.0
    roles = map(object({
      /// A list of IAM policy ARNs to be attached to the individual role
      /// 
      /// @since 1.0.0
      attached_policy_arns = list(string)
      /// Specify the name of the trust anchor this role constraints to. Valid values include only the trust anchors created by this module.
      /// 
      /// @since 1.0.0
      trust_anchor_name    = string
      /// Specify conditions that further restrict which workloads may assume this role. Please see below for valid values:
      /// 
      /// @since 1.0.0
      conditions           = optional(map(string))
      /// Specify the ARN of the policy that is used to set the permissions boundary for the role.
      /// 
      /// @since 1.0.1
      permissions_boundary = optional(string)
    }))

    /// Additional tags for the profile
    /// 
    /// @since 1.0.0
    additional_tags             = optional(map(string), {})
    /// Specifies whether instance properties are required in CreateSession requests with this profile.
    /// 
    /// @since 1.0.0
    require_instance_properties = optional(bool)
    /// The number of seconds the vended session credentials are valid for. Defaults to `3600`.
    /// 
    /// @since 1.0.0
    session_duration_seconds    = optional(number)

    /// Specify [IAM session policies][iam-session-policy] that apply to the vended session credentials
    /// 
    /// @since 1.0.0
    session_policy = optional(object({
      /// An inline JSON session policy document
      /// 
      /// @since 1.0.0
      inline_policy       = optional(string)
      /// A list of `up to 10` managed policy ARNs that apply to the vended session credentials.
      /// 
      /// @since 1.0.0
      managed_policy_arns = optional(list(string))
    }))
  }))

  description = <<EOT
    Manages multiple [profiles][iam-roles-anywhere-profile]. Profiles are predefined sets of permissions that you can apply to roles that are used by workloads that authenticate with Roles Anywhere.
    
    @since 1.0.0
  EOT
  default     = {}
}
