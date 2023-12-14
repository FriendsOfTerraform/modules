resource "aws_efs_replication_configuration" "replications" {
  for_each = var.replications

  source_file_system_id = aws_efs_file_system.efs.id

  destination {
    availability_zone_name = each.value.availability_zone
    kms_key_id             = each.value.kms_key_id
    region                 = each.key
  }
}
