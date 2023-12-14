resource "aws_efs_backup_policy" "backup_policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = var.enable_automatic_backup ? "ENABLED" : "DISABLED"
  }
}
