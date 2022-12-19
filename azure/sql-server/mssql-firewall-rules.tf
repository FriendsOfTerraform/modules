resource "azurerm_mssql_firewall_rule" "firewall_rules" {
  for_each = var.firewall != null ? var.firewall.rules : {}

  name             = each.key
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = trimspace(split("-", each.value)[0])
  end_ip_address   = length(split("-", each.value)) > 1 ? "${trimspace(split("-", each.value)[1])}" : "${trimspace(split("-", each.value)[0])}"
}

resource "azurerm_mssql_firewall_rule" "allow_access_to_azure_services" {
  count = var.firewall != null ? (
    var.firewall.allow_access_to_azure_services != null ? (
      var.firewall.allow_access_to_azure_services ? 1 : 0
    ) : 0
  ) : 0

  name             = "Allow Access To Azure Services"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}