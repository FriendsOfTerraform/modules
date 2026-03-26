locals {
  malware_protection_s3_roles = {
    for bucket_name, config in var.protection_plans.malware_protection.s3 : bucket_name => config if config.iam_role_arn == null
  }
}

data "aws_iam_policy_document" "malware_protection_s3_assume_role" {
  count = length(local.malware_protection_s3_roles) > 0 ? 1 : 0

  statement {
    sid    = "GuardDutyMalwareProtectionForS3"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["malware-protection-plan.guardduty.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:guardduty:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:malware-protection-plan/*"]
    }
  }
}

resource "aws_iam_role" "malware_protection_s3_roles" {
  for_each = local.malware_protection_s3_roles

  name               = "guard-duty-malware-protection-s3-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.malware_protection_s3_assume_role[0].json
  tags               = merge(local.common_tags, var.additional_tags_all)
}

resource "aws_iam_role_policy_attachment" "malware_protection_s3" {
  for_each = local.malware_protection_s3_roles

  role       = aws_iam_role.malware_protection_s3_roles[each.key].name
  policy_arn = aws_iam_policy.malware_protection_s3[each.key].arn
}