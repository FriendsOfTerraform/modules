output "distribution_arn" {
  description = <<EOT
    ARN for the distribution
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_cloudfront_distribution.distribution.arn
}

output "distribution_domain_name" {
  description = <<EOT
    Domain name corresponding to the distribution.
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "distribution_hosted_zone_id" {
  description = <<EOT
    CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to.
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "distribution_id" {
  description = <<EOT
    Identifier for the distribution
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_cloudfront_distribution.distribution.id
}
