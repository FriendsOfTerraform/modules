output "name" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_web_url" {
  value = aws_s3_bucket.bucket.website_endpoint
}
