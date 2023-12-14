resource "aws_efs_file_system" "efs" {
  availability_zone_name          = var.availability_zone
  creation_token                  = var.name
  encrypted                       = var.encryption.enabled
  kms_key_id                      = var.encryption.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy != null ? [1] : []

    content {
      transition_to_ia                    = var.lifecycle_policy.transition_to_infrequent_access
      transition_to_primary_storage_class = var.lifecycle_policy.transition_to_primary_storage_class
    }
  }

  tags = merge(
    { Name = var.name },
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
