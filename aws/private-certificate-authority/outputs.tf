output "certificate_authority_arn" {
  value = aws_acmpca_certificate_authority.certificate_authority.arn
}

output "certificate_authority_certificate" {
  value = aws_acmpca_certificate_authority.certificate_authority.certificate
}

output "certificate_authority_csr" {
  value = aws_acmpca_certificate_authority.certificate_authority.certificate_signing_request
}

output "certificate_authority_certificate_chain" {
  value = aws_acmpca_certificate_authority.certificate_authority.certificate_chain
}

output "certificate_authority_id" {
  value = aws_acmpca_certificate_authority.certificate_authority.id
}
