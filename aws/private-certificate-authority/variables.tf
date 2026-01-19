variable "subject" {
  type = object({
    /// Specify the common name of the CA. For CA and end-entity certificates in a private PKI, the common name (CN) can be any string within the length limit
    /// 
    /// @since 1.0.0
    common_name       = string
    /// Two-digit code that specifies the country in which the certificate subject located. For example: `"US"`
    /// 
    /// @since 1.0.0
    country           = optional(string)
    /// The locality (such as a city or town) in which the certificate subject is located. For example: `"Los Angeles"`
    /// 
    /// @since 1.0.0
    locality          = optional(string)
    /// Legal name of the organization with which the certificate subject is affiliated.
    /// 
    /// @since 1.0.0
    organization      = optional(string)
    /// A subdivision or unit of the organization (such as `"sales"` or `"finance"`) with which the certificate subject is affiliated.
    /// 
    /// @since 1.0.0
    organization_unit = optional(string)
    /// State in which the subject of the certificate is located. For example: `"California"`
    /// 
    /// @since 1.0.0
    state             = optional(string)
  })
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    The X509 subject of the CA certificate
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for the private CA
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "authorize_acm_access_to_renew_certificates" {
  type        = bool
  description = <<EOT
    Additional tags for all resources deployed with this module
    
    @since 1.0.0
  EOT
  default     = true
}

variable "ca_type" {
  type        = string
  description = <<EOT
    Grant AWS Certificate Manager (ACM) permissions for automated renewal for this CA at any time. The change will take effect for all future renewal cycles for ACM certificates generated within this account for this CA.
    
    @since 1.0.0
  EOT
  default     = "ROOT"
}

variable "crl_configuration" {
  type = object({
    /// Create a new S3 bucket to use as the CRL Distribution Point (CDP). This bucket is publicly accessible with S3 Block Public Access disabled, as required by AWS Private CA. Alternatively, to leave BPA enabled (S3 best practice) do not use this setting to create the bucket but use [CloudFront with a private S3 bucket][crl-cloudfront]. Mutually exclusive to `s3_bucket_name`
    /// 
    /// @since 1.0.0
    create_s3_bucket = optional(object({
      /// The name of the S3 bucket. Must be globally unique.
      /// 
      /// @since 1.0.0
      bucket_name       = string
      /// Additional tags attached to the S3 bucket
      /// 
      /// @since 1.0.0
      additional_tags   = optional(map(string), {})
      /// Whether S3 bucket versioning is enabled
      /// 
      /// @since 1.0.0
      enable_versioning = optional(bool, false)
    }))
    /// Name inserted into the certificate CRL Distribution Points extension that enables the use of an alias for the CRL distribution point.
    /// 
    /// @since 1.0.0
    custom_crl_name  = optional(string)
    /// Specifies whether CRL is enabled
    /// 
    /// @since 1.0.0
    enabled          = optional(bool, true)
    /// The S3 bucket where the CRLs are distributed to. Mutually exclusive to `create_s3_bucket`
    /// 
    /// @since 1.0.0
    s3_bucket_name   = optional(string)
    /// Validity period of the distributed CRLs in days
    /// 
    /// @since 1.0.0
    validity_in_days = optional(number, 7)
  })
  description = <<EOT
    Specify the type of the CA. Valid values are: `"ROOT"`, `"SUBORDINATE"`
    
    @since 1.0.0
  EOT
  default     = null
}

variable "key_algorithm" {
  type        = string
  description = <<EOT
    Configuration of the [certificate revocation list (CRL)][certificate-revocation-list] maintained by your private CA. A CRL is typically updated approximately 30 minutes after a certificate is revoked. If for any reason a CRL update fails, AWS Private CA makes further attempts every 15 minutes. CRL is distributed to a S3 bucket.
    
    @since 1.0.0
  EOT
  default     = "RSA_2048"
}

variable "ocsp_configuration" {
  type = object({
    /// CNAME specifying a customized OCSP domain. Note: The value of the CNAME must not include a protocol prefix such as "http://" or "https://". Please review [the documentation][online-certificate-status-protocol] for additional requirements to use the custom endpoint.
    /// 
    /// @since 1.0.0
    custom_ocsp_endpoint = optional(string)
    /// Specifies whether OCSP is enabled
    /// 
    /// @since 1.0.0
    enabled              = optional(bool, true)
  })
  description = <<EOT
    Type of the public key algorithm and size, in bits, of the key pair that your CA creates when it issues a certificate. When you create a subordinate CA, you must use a key algorithm supported by the parent CA. Valid values: `"RSA_2048"`, `"RSA_4096"`, `"EC_prime256v1"`, `"EC_secp384r1"`
    
    @since 1.0.0
  EOT
  default     = null
}

variable "policy" {
  type        = string
  description = <<EOT
    Configuration of [Online Certificate Status Protocol (OCSP)][online-certificate-status-protocol] support maintained by your private CA. When you revoke a certificate, OCSP responses may take up to 60 minutes to reflect the new status.
    
    @since 1.0.0
  EOT
  default     = null
}

variable "signing_algorithm" {
  type        = string
  description = <<EOT
    Attaches a JSON-formatted resource-based IAM policy to this private CA
    
    @since 1.0.0
  EOT
  default     = "SHA256WITHRSA"
}

variable "subordinate_ca_configuration" {
  type = object({
    /// Import a subordinate CA certificate signed by an external CA. [See example](#deploy-subordinate-ca-signed-by-external-parent-ca). Mutually exclusive to `parent_ca_arn`
    /// 
    /// @since 1.0.0
    import_certificate = optional(object({
      /// Specify the PEM-encoded subordinate CA certificate
      /// 
      /// @since 1.0.0
      certificate       = string
      /// Specify the PEM-encoded subordinate CA certificate chain
      /// 
      /// @since 1.0.0
      certificate_chain = string
    }))
    /// Signs the subordinate CA certificate with an AWS private CA. [See example](#basic-usage). Mutually exclusive to `import_certificate`
    /// 
    /// @since 1.0.0
    parent_ca_arn = optional(string)
    /// Specify the [path length constraint][path-length-contraint] of the subordinate CA, which determines the maximum number of lower-level subordinate CAs that can exist in a valid chain of trust. AWS Private CA supports a maximum chain of up to 5 levels deep, therefore this values must be `<= 3`
    /// 
    /// @since 1.0.0
    path_length   = optional(number, 0)
  })
  description = <<EOT
    Name of the algorithm your private CA uses to sign certificate requests. Valid values: `"SHA256WITHECDSA"`, `"SHA384WITHECDSA"`, `"SHA512WITHECDSA"`, `"SHA256WITHRSA"`, `"SHA384WITHRSA"`, `"SHA512WITHRSA"`
    
    @since 1.0.0
  EOT
  default     = null
}

variable "usage_mode" {
  type        = string
  description = <<EOT
    Specify options to setup a subordinate CA. Required if `ca_type = "SUBORDINATE"`.
    
    @since 1.0.0
  EOT
  default     = "GENERAL_PURPOSE"
}

variable "validity" {
  type        = string
  description = <<EOT
    Specifies whether the CA issues general-purpose certificates that typically require a revocation mechanism, or short-lived certificates that may optionally omit revocation because they expire quickly. Short-lived certificate validity is limited to seven days. Please refer to [this documentation][ca-mode] for more detail.
    
    @since 1.0.0
  EOT
  default     = "10 years"
}
