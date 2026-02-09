output "efs_arn" {
  description = <<EOT
    The ARN of the EFS file system

    @type string
    @since 1.0.0
  EOT
  value       = aws_efs_file_system.efs.arn
}

output "efs_availability_zone_id" {
  description = <<EOT
    The identifier of the Availability Zone in which the file system's One Zone storage classes exist

    @type string
    @since 1.0.0
  EOT
  value       = var.availability_zone != null ? aws_efs_file_system.efs.availability_zone_id : null
}

output "efs_id" {
  description = <<EOT
    The ID that identifies the file system

    @type string
    @since 1.0.0
  EOT
  value       = aws_efs_file_system.efs.id
}

output "efs_dns_name" {
  description = <<EOT
    The DNS name for the filesystem

    @type string
    @since 1.0.0
  EOT
  value       = aws_efs_file_system.efs.dns_name
}

output "efs_size_in_bytes" {
  description = <<EOT
    The latest known metered size (in bytes) of data stored in the file system, the value is not the exact size that the file system was at any point in time

    @type number
    @since 1.0.0
  EOT
  value       = aws_efs_file_system.efs.size_in_bytes
}

output "efs_mount_targets" {
  description = <<EOT
    Attributes of all mount targets for the file system

    @type object({
      /// The unique and consistent identifier of the Availability Zone (AZ) that the mount target resides in
      ///
      /// @since 1.0.0
      availability_zone_id = string

      /// The name of the Availability Zone (AZ) that the mount target resides in
      ///
      /// @since 1.0.0
      availability_zone_name = string

      /// The ID of the mount target
      ///
      /// @since 1.0.0
      id = string

      /// The DNS name for the given subnet/AZ
      ///
      /// @since 1.0.0
      mount_target_dns_name = string

      /// The ID of the network interface that Amazon EFS created when it created the mount target
      ///
      /// @since 1.0.0
      network_interface_id = string
    })
    @since 1.0.0
  EOT
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
  description = <<EOT
    Attributes of all replications for the file system

    @type object({
      /// The file system ID of the replica
      ///
      /// @since 1.0.0
      destination_file_system_id = string

      /// The status of the replication
      ///
      /// @since 1.0.0
      replication_status = string
    })
    @since 1.0.0
  EOT
  value = {
    for region, v in var.replications :
    region => {
      destination_file_system_id = aws_efs_replication_configuration.replications[region].destination[0].file_system_id
      replication_status         = aws_efs_replication_configuration.replications[region].destination[0].status
    }
  }
}
