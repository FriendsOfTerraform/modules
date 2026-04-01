output "virtual_network_id" {
  description = <<EOT
    The ID of the virtual network

    @type string
    @since 0.0.1
  EOT
  value       = azurerm_virtual_network.virtual_network.id
}

output "subnet_ids" {
  description = <<EOT
    Map of subnet names to their IDs

    @type map(string)
    @since 0.0.1
  EOT
  value = {
    for k in keys(azurerm_subnet.subnets) : k => azurerm_subnet.subnets[k].id
  }
}
