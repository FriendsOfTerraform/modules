resource "aws_guardduty_member_detector_feature" "malware_protection_ec2" {
  for_each = var.member_accounts

  account_id  = each.key
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "EBS_MALWARE_PROTECTION"
  status = each.value.protection_plans.malware_protection.ec2.enabled != null ? (
    each.value.protection_plans.malware_protection.ec2.enabled ? "ENABLED" : "DISABLED"
  ) : var.protection_plans.malware_protection.ec2.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_member_detector_feature" "eks_protection" {
  for_each = var.member_accounts

  account_id  = each.key
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "EKS_AUDIT_LOGS"
  status = each.value.protection_plans.eks_protection.enabled != null ? (
    each.value.protection_plans.eks_protection.enabled ? "ENABLED" : "DISABLED"
  ) : var.protection_plans.eks_protection.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_member_detector_feature" "lambda_protection" {
  for_each = var.member_accounts

  account_id  = each.key
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "LAMBDA_NETWORK_LOGS"
  status = each.value.protection_plans.lambda_protection.enabled != null ? (
    each.value.protection_plans.lambda_protection.enabled ? "ENABLED" : "DISABLED"
  ) : var.protection_plans.lambda_protection.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_member_detector_feature" "rds_protection" {
  for_each = var.member_accounts

  account_id  = each.key
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "RDS_LOGIN_EVENTS"
  status = each.value.protection_plans.rds_protection.enabled != null ? (
    each.value.protection_plans.rds_protection.enabled ? "ENABLED" : "DISABLED"
  ) : var.protection_plans.rds_protection.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_member_detector_feature" "runtime_monitoring" {
  for_each = var.member_accounts

  account_id  = each.key
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "RUNTIME_MONITORING"
  status = each.value.protection_plans.runtime_monitoring.enabled != null ? (
    each.value.protection_plans.runtime_monitoring.enabled ? "ENABLED" : "DISABLED"
  ) : var.protection_plans.runtime_monitoring.enabled ? "ENABLED" : "DISABLED"

  additional_configuration {
    name = "EKS_ADDON_MANAGEMENT"
    status = each.value.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_eks.enabled != null ? (
      each.value.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_eks.enabled ? "ENABLED" : "DISABLED"
    ) : var.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_eks.enabled ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = each.value.protection_plans.runtime_monitoring.automated_agent_configuration.aws_fargate_ecs.enabled != null ? (
      each.value.protection_plans.runtime_monitoring.automated_agent_configuration.aws_fargate_ecs.enabled ? "ENABLED" : "DISABLED"
    ) : var.protection_plans.runtime_monitoring.automated_agent_configuration.aws_fargate_ecs.enabled ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name = "EC2_AGENT_MANAGEMENT"
    status = each.value.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_ec2.enabled != null ? (
      each.value.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_ec2.enabled ? "ENABLED" : "DISABLED"
    ) : var.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_ec2.enabled ? "ENABLED" : "DISABLED"
  }
}

resource "aws_guardduty_member_detector_feature" "s3_protection" {
  for_each = var.member_accounts

  account_id  = each.key
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "S3_DATA_EVENTS"
  status = each.value.protection_plans.s3_protection.enabled != null ? (
    each.value.protection_plans.s3_protection.enabled ? "ENABLED" : "DISABLED"
  ) : var.protection_plans.s3_protection.enabled ? "ENABLED" : "DISABLED"
}