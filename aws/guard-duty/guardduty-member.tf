resource "aws_guardduty_member" "members" {
  for_each = var.member_accounts

  account_id         = each.key
  detector_id        = aws_guardduty_detector.guardduty_detector.id
  email              = each.value.email_address
  invite             = each.value.invite
  invitation_message = each.value.invitation_message
}