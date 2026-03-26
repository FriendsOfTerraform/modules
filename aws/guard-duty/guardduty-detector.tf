resource "aws_guardduty_detector" "guardduty_detector" {
  enable                       = var.enabled
  finding_publishing_frequency = var.findings_export_options.frequency
  tags                         = merge(local.common_tags, var.additional_tags, var.additional_tags_all)
}