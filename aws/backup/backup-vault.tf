resource "aws_backup_vault" "this" {
  count = var.vault_type == "standard" ? 1 : 0

  name = var.name

  kms_key_arn = var.encryption_key_arn
  tags        = merge(local.common_tags, var.additional_tags_all, var.additional_tags)
}
