###
# S3 bucket replication
###

locals {
  assume_role_policy        = "${path.module}/iam-policies/service-assume-role-policy.json"
  bucket_replication_policy = "${path.module}/iam-policies/bucket-replication-policy.json"
}

resource "aws_iam_policy" "bucket_replication_policy" {
  count = var.replication_config != null ? (
    var.replication_config.iam_role_arn != null ? 0 : 1
  ) : 0

  name        = "${aws_s3_bucket.bucket.id}-bucket-replication-policy"
  description = "Minimum permissions required for ${aws_s3_bucket.bucket.id} S3 bucket replication"

  policy = templatefile(
    local.bucket_replication_policy,
    {
      source_bucket_arn = aws_s3_bucket.bucket.arn,
      destination_bucket_arns = jsonencode(distinct([
        for k, v in var.replication_config.rules :
        "${v.destination_bucket_arn}/*"
      ]))
    }
  )

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_role" "bucket_replication_role" {
  count = var.replication_config != null ? (
    var.replication_config.iam_role_arn != null ? 0 : 1
  ) : 0

  name               = "${aws_s3_bucket.bucket.id}-bucket-replication-role"
  description        = "Used by the ${aws_s3_bucket.bucket.id} bucket for replication"
  assume_role_policy = templatefile(local.assume_role_policy, { aws_service = jsonencode(["s3.amazonaws.com", "batchoperations.s3.amazonaws.com"]) })

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_role_policy_attachment" "bucket_replication_role_attached_policy" {
  count = var.replication_config != null ? (
    var.replication_config.iam_role_arn != null ? 0 : 1
  ) : 0

  role       = aws_iam_role.bucket_replication_role[0].name
  policy_arn = aws_iam_policy.bucket_replication_policy[0].arn
}