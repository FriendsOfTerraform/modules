# This key will be used as the key signing key for DNSSEC
resource "aws_kms_key" "dnssec_kms_key" {
  for_each = var.enables_dnssec != null ? var.enables_dnssec.key_signing_keys : {}

  description              = "Used as DNSSEC KSK for hosted zone ${aws_route53_zone.hosted_zone.name}"
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"

  # Use inline policy instead to avoid the dependency issue when deleting a hosted zone with DNSSEC enabled
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "dnssec-policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Route 53 DNSSEC Service"
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:Verify"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Sid    = "Allow Route 53 DNSSEC to CreateGrant"
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action   = "kms:CreateGrant"
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = true
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "dnssec_kms_key_alias" {
  for_each = var.enables_dnssec != null ? var.enables_dnssec.key_signing_keys : {}

  name          = "alias/${each.key}"
  target_key_id = aws_kms_key.dnssec_kms_key[each.key].key_id
}
