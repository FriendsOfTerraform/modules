output "certificate_authority_arn" {
  description = <<EOT
    The ARN of the certificate authority
    
    @type string
    @since 1.0.0
  EOT
  value = aws_acmpca_certificate_authority.certificate_authority.arn
}

output "certificate_authority_certificate" {
  description = <<EOT
    Base64-encoded certificate authority (CA) certificate. Only available after the certificate authority certificate has been imported.
    
    @type string
    @since 1.0.0
  EOT
  value = aws_acmpca_certificate_authority.certificate_authority.certificate
}

output "certificate_authority_csr" {
  description = <<EOT
    The base64 PEM-encoded certificate signing request (CSR) for the private CA certificate.
    
    @type string
    @since 1.0.0
  EOT
  value = aws_acmpca_certificate_authority.certificate_authority.certificate_signing_request
}

output "certificate_authority_certificate_chain" {
  description = <<EOT
    Base64-encoded certificate chain that includes any intermediate certificates and chains up to root on-premises certificate that you used to sign your private CA certificate. The chain does not include your private CA certificate. Only available after the certificate authority certificate has been imported.
    
    @type string
    @since 1.0.0
  EOT
  value = aws_acmpca_certificate_authority.certificate_authority.certificate_chain
}

output "certificate_authority_id" {
  description = <<EOT
    The ID of the certificate authority
    
    @type string
    @since 1.0.0
  EOT
  value = aws_acmpca_certificate_authority.certificate_authority.id
}
