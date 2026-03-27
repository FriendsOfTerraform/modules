output "mount_path" {
  description = <<EOT
    The mount path of the secret engine
    
    @type string
    @since 0.0.1
  EOT
  value       = var.mount_path
}