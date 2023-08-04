output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_region" {
  value = aws_s3_bucket.bucket.region
}

output "website_domain" {
  value = local.static_website_hosting_enabled ? aws_s3_bucket_website_configuration.bucket_website_configuration[0].website_domain : null
}

output "website_endpoint" {
  value = local.static_website_hosting_enabled ? aws_s3_bucket_website_configuration.bucket_website_configuration[0].website_endpoint : null
}
