output "route53_hosted_zone_arn" {
  description = <<EOT
    The ARN of the Route 53 hosted zone
    
    @type string
    @since 1.0.0
  EOT
  value = aws_route53_zone.hosted_zone.arn
}

output "route53_hosted_zone_id" {
  description = <<EOT
    The ID of the Route 53 hosted zone
    
    @type string
    @since 1.0.0
  EOT
  value = aws_route53_zone.hosted_zone.zone_id
}

output "route53_hosted_zone_name_servers" {
  description = <<EOT
    A list of name servers in associated (or default) delegation set
    
    @type list(string)
    @since 1.0.0
  EOT
  value = aws_route53_zone.hosted_zone.name_servers
}

output "route53_hosted_zone_primary_name_server" {
  description = <<EOT
    The Route 53 name server that created the SOA record
    
    @type string
    @since 1.1.0
  EOT
  value = aws_route53_zone.hosted_zone.primary_name_server
}
