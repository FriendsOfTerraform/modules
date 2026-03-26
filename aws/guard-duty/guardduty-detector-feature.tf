resource "aws_guardduty_detector_feature" "malware_protection_ec2" {
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = var.protection_plans.malware_protection.ec2.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_detector_feature" "eks_protection" {
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "EKS_AUDIT_LOGS"
  status      = var.protection_plans.eks_protection.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_detector_feature" "lambda_protection" {
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = var.protection_plans.lambda_protection.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_detector_feature" "rds_protection" {
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "RDS_LOGIN_EVENTS"
  status      = var.protection_plans.rds_protection.enabled ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "RUNTIME_MONITORING"
  status      = var.protection_plans.runtime_monitoring.enabled ? "ENABLED" : "DISABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = var.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_eks.enabled ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name   = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = var.protection_plans.runtime_monitoring.automated_agent_configuration.aws_fargate_ecs.enabled ? "ENABLED" : "DISABLED"
  }

  additional_configuration {
    name   = "EC2_AGENT_MANAGEMENT"
    status = var.protection_plans.runtime_monitoring.automated_agent_configuration.amazon_ec2.enabled ? "ENABLED" : "DISABLED"
  }
}

resource "aws_guardduty_detector_feature" "s3_protection" {
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "S3_DATA_EVENTS"
  status      = var.protection_plans.s3_protection.enabled ? "ENABLED" : "DISABLED"
}