resource "aws_efs_mount_target" "mount_targets" {
  for_each = var.mount_targets

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.key
  ip_address      = each.value.ip_address
  security_groups = each.value.security_group_ids
}
