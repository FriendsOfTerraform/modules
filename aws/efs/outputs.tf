output "efs_arn" {
  value = aws_efs_file_system.efs.arn
}

output "efs_availability_zone_id" {
  value = var.availability_zone != null ? aws_efs_file_system.efs.availability_zone_id : null
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.efs.dns_name
}

output "efs_size_in_bytes" {
  value = aws_efs_file_system.efs.size_in_bytes
}

output "efs_mount_targets" {
  value = {
    for subnet, v in var.mount_targets :
    subnet => {
      availability_zone_id   = aws_efs_mount_target.mount_targets[subnet].availability_zone_id
      availability_zone_name = aws_efs_mount_target.mount_targets[subnet].availability_zone_name
      id                     = aws_efs_mount_target.mount_targets[subnet].id
      mount_target_dns_name  = aws_efs_mount_target.mount_targets[subnet].mount_target_dns_name
      network_interface_id   = aws_efs_mount_target.mount_targets[subnet].network_interface_id
    }
  }
}

output "efs_replications" {
  value = {
    for region, v in var.replications :
    region => {
      destination_file_system_id = aws_efs_replication_configuration.replications[region].destination[0].file_system_id
      replication_status         = aws_efs_replication_configuration.replications[region].destination[0].status
    }
  }
}
