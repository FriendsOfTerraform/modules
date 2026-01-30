output "bucket_arn" {
  description = <<EOT
    ARN of the S3 bucket

    @type string
    @since 1.0.0
  EOT
  value = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  description = <<EOT
    Bucket domain name. Will be of format `bucketname.s3.amazonaws.com`

    @type string
    @since 1.0.0
  EOT
  value = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_name" {
  description = <<EOT
    Name of the S3 bucket

    @type string
    @since 1.0.0
  EOT
  value = aws_s3_bucket.bucket.id
}

output "bucket_region" {
  description = <<EOT
    AWS region this bucket resides in

    @type string
    @since 1.0.0
  EOT
  value = aws_s3_bucket.bucket.region
}

output "website_domain" {
  description = <<EOT
    Domain of the website endpoint. This is used to create Route 53 alias records.

    @type string
    @since 1.0.0
  EOT
  value = local.static_website_hosting_enabled ? aws_s3_bucket_website_configuration.bucket_website_configuration[0].website_domain : null
}

output "website_endpoint" {
  description = <<EOT
    Website endpoint.

    @type string
    @since 1.0.0
  EOT
  value = local.static_website_hosting_enabled ? aws_s3_bucket_website_configuration.bucket_website_configuration[0].website_endpoint : null
}
