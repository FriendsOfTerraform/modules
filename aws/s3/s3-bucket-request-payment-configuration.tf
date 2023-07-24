resource "aws_s3_bucket_request_payment_configuration" "requester_pays" {
  count = var.requester_pays_enabled ? 1 : 0

  bucket                = aws_s3_bucket.bucket.id
  expected_bucket_owner = var.bucket_owner_account_id
  payer                 = "Requester"
}
