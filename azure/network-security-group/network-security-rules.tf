resource "azurerm_network_security_rule" "inbound_security_rules" {
  for_each = var.inbound_security_rules

  name                                       = each.key
  resource_group_name                        = data.azurerm_resource_group.current.name
  network_security_group_name                = azurerm_network_security_group.network_security_group.name
  description                                = each.value.description
  protocol                                   = each.value.protocol
  source_port_range                          = "*"
  destination_port_range                     = each.value.port_ranges != null ? null : "*" # allow all port ranges if not specified
  destination_port_ranges                    = each.value.port_ranges != null ? each.value.port_ranges : null
  source_address_prefixes                    = each.value.source_ip_addresses
  source_application_security_group_ids      = each.value.source_application_security_group_ids
  destination_address_prefixes               = each.value.destination_ip_addresses
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
  access                                     = each.value.action
  priority                                   = each.value.priority
  direction                                  = "Inbound"

  # if none of the destinations are specified, allow Any destinations
  destination_address_prefix = each.value.destination_service_tag == null ? (
    each.value.destination_ip_addresses == null ? (
      each.value.destination_application_security_group_ids == null ? "*" : null
    ) : null
  ) : each.value.destination_service_tag

  # if none of the sources are specified, allow Any sources
  source_address_prefix = each.value.source_service_tag == null ? (
    each.value.source_ip_addresses == null ? (
      each.value.source_application_security_group_ids == null ? "*" : null
    ) : null
  ) : each.value.source_service_tag
}

resource "azurerm_network_security_rule" "outbound_security_rules" {
  for_each = var.outbound_security_rules

  name                                       = each.key
  resource_group_name                        = data.azurerm_resource_group.current.name
  network_security_group_name                = azurerm_network_security_group.network_security_group.name
  description                                = each.value.description
  protocol                                   = each.value.protocol
  source_port_range                          = "*"
  destination_port_range                     = each.value.port_ranges != null ? null : "*" # allow all port ranges if not specified
  destination_port_ranges                    = each.value.port_ranges != null ? each.value.port_ranges : null
  source_address_prefixes                    = each.value.source_ip_addresses
  source_application_security_group_ids      = each.value.source_application_security_group_ids
  destination_address_prefixes               = each.value.destination_ip_addresses
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
  access                                     = each.value.action
  priority                                   = each.value.priority
  direction                                  = "Outbound"

  # if none of the destinations are specified, allow Any destinations
  destination_address_prefix = each.value.destination_service_tag == null ? (
    each.value.destination_ip_addresses == null ? (
      each.value.destination_application_security_group_ids == null ? "*" : null
    ) : null
  ) : each.value.destination_service_tag

  # if none of the sources are specified, allow Any sources
  source_address_prefix = each.value.source_service_tag == null ? (
    each.value.source_ip_addresses == null ? (
      each.value.source_application_security_group_ids == null ? "*" : null
    ) : null
  ) : each.value.source_service_tag
}
