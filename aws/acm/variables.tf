variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "public_certificates" {
  type = map(object({
    /// Additional tags associated with the certificate
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// If enabled, you can export your ACM public certificate's private key.
    /// You can use the certificate for different workloads like in the AWS Cloud,
    /// on-premises, and hybrid.
    ///
    /// @since 1.0.0
    allow_export = optional(bool, false)

    /// The encryption algorithm. Some algorithms may not be supported by all
    /// AWS services.
    ///
    /// @enum RSA_2048|EC_prime256v1|EC_secp384r1
    /// @since 1.0.0
    key_algorithm = optional(string, "RSA_2048")

    /// List of additional names for this certificate
    ///
    /// @since 1.0.0
    subject_alternative_names = optional(list(string), null)

    /// Method for validating domain ownership.
    ///
    /// @enum DNS|EMAIL
    /// @link "Domain Ownership Validation" https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html
    /// @since 1.0.0
    validation_method = optional(string, "DNS")
  }))
  description = <<EOT
    Manage multiple public SSL/TLS certificates from Amazon. By default, public
    certificates are trusted by browsers and operating systems.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
  default     = {}
}
