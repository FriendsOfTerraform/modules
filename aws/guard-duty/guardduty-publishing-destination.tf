resource "aws_guardduty_publishing_destination" "export_findings_configuration" {
  count = var.export_findings_configuration.s3_destination != null ? 1 : 0

  detector_id     = var.export_findings_configuration.detector_id
  destination_arn = var.export_findings_configuration.s3_destination.bucket_arn
  kms_key_arn     = var.export_findings_configuration.s3_destination.kms_key_arn
}