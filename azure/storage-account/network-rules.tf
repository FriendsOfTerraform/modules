resource "azurerm_storage_account_network_rules" "network_rule" {
  count = var.firewall != null ? 1 : 0

  storage_account_id         = azurerm_storage_account.storage_account.id
  default_action             = "Deny"
  bypass                     = var.firewall.exceptions != null ? var.firewall.exceptions : []
  ip_rules                   = var.firewall.allow_public_ips != null ? var.firewall.allow_public_ips : []
  virtual_network_subnet_ids = var.firewall.allow_vnet_subnets != null ? var.firewall.allow_vnet_subnets : []
}
