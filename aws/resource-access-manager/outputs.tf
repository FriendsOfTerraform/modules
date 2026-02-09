output "resource_share_id" {
  description = <<EOT
    The ID of the resource share
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_ram_resource_share.resource_share.id
}
