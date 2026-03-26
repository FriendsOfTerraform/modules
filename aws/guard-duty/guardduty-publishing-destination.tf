resource "aws_guardduty_publishing_destination" "findings_export_options" {
  count = var.findings_export_options.s3_destination != null ? 1 : 0

  detector_id     = aws_guardduty_detector.guardduty_detector.id
  destination_arn = var.findings_export_options.s3_destination.bucket_arn
  kms_key_arn     = var.findings_export_options.s3_destination.kms_key_arn
}
