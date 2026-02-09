output "id" {
  description = <<EOT
    The ID of the network security group
    
    @type string
    @since 0.0.1
  EOT
  value = azurerm_network_security_group.network_security_group.id
}
