resource "aws_backup_vault_policy" "this" {
  count = var.access_policy != null ? 1 : 0

  backup_vault_name = local.vault_name
  policy            = var.access_policy
}
