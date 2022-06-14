output "virtual_network_id" {
  value = azurerm_virtual_network.virtual_network.id
}

output "subnet_ids" {
  value = {
    for k in keys(azurerm_subnet.subnets) : k => azurerm_subnet.subnets[k].id
  }
}
