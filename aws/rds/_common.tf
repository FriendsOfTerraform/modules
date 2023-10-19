data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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
}
