resource "aws_guardduty_ipset" "trusted_ip_lists" {
  for_each = var.trusted_ip_lists

  activate    = true
  detector_id = aws_guardduty_detector.guardduty_detector.id
  format      = each.value.list_format
  location    = each.value.location
  name        = each.key
  tags        = merge(local.common_tags, var.additional_tags_all, each.value.additional_tags)
}