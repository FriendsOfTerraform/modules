resource "aws_sesv2_account_vdm_attributes" "virtual_deliverability_manager" {
  count = var.virtual_deliverability_manager != null ? 1 : 0

  vdm_enabled = "ENABLED"
  dashboard_attributes { engagement_metrics = var.virtual_deliverability_manager.engagement_tracking_enabled ? "ENABLED" : "DISABLED" }
  guardian_attributes { optimized_shared_delivery = var.virtual_deliverability_manager.optimized_shared_delivery_enabled ? "ENABLED" : "DISABLED" }
}