output "public_certificates" {
  description = <<EOT
    Information of all the public certificates managed by this module

    @type map(object({
      /// ARN of the certificate
      ///
      /// @since 1.0.0
      arn = string

      /// Set of domain validation objects which can be used to complete certificate validation.
      ///
      /// @since 1.0.0
      domain_validation_options = list(object)

      /// ARN of the certificate
      ///
      /// @since 1.0.0
      id = string

      /// Expiration date and time of the certificate
      ///
      /// @since 1.0.0
      not_after = string

      /// Start of the validity period of the certificate.
      ///
      /// @since 1.0.0
      not_before = string

      /// Whether the certificate is eligible for managed renewal.
      ///
      /// @since 1.0.0
      renewal_eligibility = string

      /// Contains information about the status of ACM's managed renewal for the certificate.
      ///
      /// @since 1.0.0
      renewal_summary = list(string)

      /// Status of the certificate.
      ///
      /// @since 1.0.0
      status = string

      /// List of addresses that received a validation email. Only set if EMAIL validation was used.
      ///
      /// @since 1.0.0
      validation_emails = list(string)
    }))
    @since 1.0.0
  EOT
  value = { for k, v in aws_acm_certificate.public_certificates : k => {
    arn                       = v.arn
    domain_validation_options = v.domain_validation_options
    id                        = v.id
    not_after                 = v.not_after
    not_before                = v.not_before
    renewal_eligibility       = v.renewal_eligibility
    renewal_summary           = v.renewal_summary
    status                    = v.status
    validation_emails         = v.validation_emails
  } }
}
