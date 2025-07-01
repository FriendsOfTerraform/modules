data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_kms_key" "by_alias" {
  count  = var.enable_encryption != null ? 1 : 0
  key_id = "alias/${var.enable_encryption.kms_key_alias}"
}

locals {
  common_tags = {
    managed-by = "Terraform"
  }

  is_aurora = strcontains(var.engine.type, "aurora")

  is_performance_insight_enabled = var.monitoring_config != null ? (
    var.monitoring_config.enable_performance_insight != null ? true : false
  ) : false

  is_enhanced_monitoring_enabled = var.monitoring_config != null ? (
    var.monitoring_config.enable_enhanced_monitoring != null ? true : false
  ) : false

  is_enhanced_monitoring_enabled_on_cluster_instances = { for k, v in var.cluster_instances : k => v if v.monitoring_config.enable_enhanced_monitoring != null }
}
