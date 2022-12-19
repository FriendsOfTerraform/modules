resource "azurerm_mssql_server" "mssql_server" {
  name                         = var.name
  resource_group_name          = data.azurerm_resource_group.current.name
  location                     = local.location
  version                      = var.server_version
  administrator_login          = var.sql_authentication != null ? var.sql_authentication.admin_username : null
  administrator_login_password = var.sql_authentication != null ? var.sql_authentication.admin_password : null

  dynamic "azuread_administrator" {
    for_each = var.azure_ad_authentication != null ? [1] : []

    content {
      login_username              = "AzureAD Admin"
      object_id                   = var.azure_ad_authentication.object_id
      tenant_id                   = var.azure_ad_authentication.tenant_id
      azuread_authentication_only = var.sql_authentication != null ? false : true
    }
  }

  connection_policy = var.connection_policy

  identity {
    type         = length(var.user_assigned_managed_identity_ids) > 0 ? "UserAssigned" : "SystemAssigned"
    identity_ids = length(var.user_assigned_managed_identity_ids) > 0 ? var.user_assigned_managed_identity_ids : null
  }

  minimum_tls_version                  = var.minimum_tls_version
  public_network_access_enabled        = var.public_network_access_enabled
  outbound_network_restriction_enabled = var.outbound_network_restriction_enabled
  primary_user_assigned_identity_id    = length(var.user_assigned_managed_identity_ids) > 0 ? var.user_assigned_managed_identity_ids[0] : null

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.additional_tags
  )
}