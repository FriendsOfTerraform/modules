resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  count = local.add_ons.monitoring_enabled ? 1 : 0

  name                = "${var.name}-log-analytics-workspace"
  resource_group_name = data.azurerm_resource_group.current.name
  location            = local.location
  retention_in_days   = var.add_ons.monitoring.retention_days != null ? var.add_ons.monitoring.retention_days : 60
}
