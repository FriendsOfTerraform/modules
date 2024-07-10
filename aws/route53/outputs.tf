output "route53_hosted_zone_arn" {
  value = aws_route53_zone.hosted_zone.arn
}

output "route53_hosted_zone_id" {
  value = aws_route53_zone.hosted_zone.zone_id
}

output "route53_hosted_zone_name_servers" {
  value = aws_route53_zone.hosted_zone.name_servers
}

output "route53_hosted_zone_primary_name_server" {
  value = aws_route53_zone.hosted_zone.primary_name_server
}
