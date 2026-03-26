data "aws_iam_policy_document" "malware_protection_s3" {
  for_each = local.malware_protection_s3_roles

  statement {
    sid       = "AllowManagedRuleToSendS3EventsToGuardDuty"
    effect    = "Allow"
    actions   = ["events:PutRule"]
    resources = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
    condition {
      test     = "StringEquals"
      variable = "events:ManagedBy"
      values   = ["malware-protection-plan.guardduty.amazonaws.com"]
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "events:source"
      values   = ["aws.s3"]
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "events:detail-type"
      values   = ["Object Created", "AWS API Call via CloudTrail"]
    }
    condition {
      test     = "Null"
      variable = "events:source"
      values   = ["false"]
    }
    condition {
      test     = "Null"
      variable = "events:detail-type"
      values   = ["false"]
    }
  }

  statement {
    sid       = "AllowUpdateTargetAndDeleteManagedRule"
    effect    = "Allow"
    actions   = ["events:DeleteRule", "events:PutTargets", "events:RemoveTargets"]
    resources = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
    condition {
      test     = "StringEquals"
      variable = "events:ManagedBy"
      values   = ["malware-protection-plan.guardduty.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowGuardDutyToMonitorEventBridgeManagedRule"
    effect    = "Allow"
    actions   = ["events:DescribeRule", "events:ListTargetsByRule"]
    resources = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
  }

  statement {
    sid       = "AllowEnableS3EventBridgeEvents"
    effect    = "Allow"
    actions   = ["s3:PutBucketNotification", "s3:GetBucketNotification"]
    resources = "arn:aws:s3:::${each.key}"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "AllowPostScanTag"
    effect    = "Allow"
    actions   = ["s3:GetObjectTagging", "s3:GetObjectVersionTagging", "s3:PutObjectTagging", "s3:PutObjectVersionTagging"]
    resources = "arn:aws:s3:::${each.key}/*"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "AllowPutValidationObject"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = "arn:aws:s3:::${each.key}/malware-protection-resource-validation-object"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "AllowCheckBucketOwnership"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = "arn:aws:s3:::${each.key}"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "AllowMalwareScan"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = "arn:aws:s3:::${each.key}/*"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  dynamic "statement" {
    for_each = each.value.kms_key_arn != null ? [1] : []
    content {
      sid       = "AllowDecryptForMalwareScan"
      effect    = "Allow"
      actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
      resources = each.value.kms_key_arn
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = ["s3.${data.aws_region.current.region}.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_policy" "malware_protection_s3" {
  for_each = local.malware_protection_s3_roles

  name   = "guard-duty-malware-protection-s3-${each.key}"
  policy = data.aws_iam_policy_document.malware_protection_s3[each.key].json
  tags   = merge(local.common_tags, var.additional_tags_all)
}
