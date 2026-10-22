resource "aws_backup_vault_notifications" "this" {
  count = var.notifications != null ? 1 : 0

  backup_vault_events = var.notifications.backup_vault_events
  backup_vault_name   = local.vault_name
  sns_topic_arn       = var.notifications.sns_topic_arn
}
