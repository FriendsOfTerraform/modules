output "public_certificates" {
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
