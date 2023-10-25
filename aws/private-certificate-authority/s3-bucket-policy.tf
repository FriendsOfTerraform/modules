resource "aws_s3_bucket_policy" "allow_access_from_private_ca" {
  count = var.crl_configuration != null ? (
    var.crl_configuration.create_s3_bucket != null ? 1 : 0
  ) : 0

  bucket = aws_s3_bucket.crl_bucket[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "acm-pca.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.crl_bucket[0].id}/*",
          "arn:aws:s3:::${aws_s3_bucket.crl_bucket[0].id}"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = aws_acmpca_certificate_authority.certificate_authority.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.crl_bucket[0].id}/*"
      }
    ]
  })
}
