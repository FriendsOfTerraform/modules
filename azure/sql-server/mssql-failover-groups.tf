data "azurerm_mssql_database" "databases" {
  depends_on = [
    azurerm_mssql_database.dtu_models,
    azurerm_mssql_database.vcore_models
  ]

  for_each = var.databases

  name      = each.key
  server_id = azurerm_mssql_server.mssql_server.id
}

resource "azurerm_mssql_failover_group" "failover_groups" {
  depends_on = [
    azurerm_mssql_database.dtu_models,
    azurerm_mssql_database.vcore_models
  ]

  for_each = var.failover_groups

  name      = each.key
  server_id = azurerm_mssql_server.mssql_server.id

  partner_server {
    id = each.value.secondary_server_id
  }

  databases = [for db in each.value.databases : data.azurerm_mssql_database.databases[db].id]

  read_write_endpoint_failover_policy {
    mode          = each.value.read_write_failover_policy
    grace_minutes = each.value.read_write_grace_period_minutes
  }

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    each.value.additional_tags
  )
}