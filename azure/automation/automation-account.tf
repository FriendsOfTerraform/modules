resource "azurerm_automation_account" "automation_account" {
  name                          = var.name
  public_network_access_enabled = true
  resource_group_name           = data.azurerm_resource_group.current.name
  location                      = local.location
  sku_name                      = "Basic"

  identity {
    type         = length(var.user_assigned_managed_identity_ids) > 0 ? "UserAssigned" : "SystemAssigned"
    identity_ids = length(var.user_assigned_managed_identity_ids) > 0 ? var.user_assigned_managed_identity_ids : null
  }

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.additional_tags
  )
}