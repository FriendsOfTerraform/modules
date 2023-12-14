resource "aws_efs_file_system_policy" "file_system_policy" {
  count = var.file_system_policy != null ? 1 : 0

  file_system_id = aws_efs_file_system.efs.id
  policy         = var.file_system_policy
}
