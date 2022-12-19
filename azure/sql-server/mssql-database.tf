locals {
  create_mode_table = {
    "Create"      = ["Copy", "OnlineSecondary", "RestoreExternalBackup", "RestoreExternalBackupSecondary", "RestoreLongTermRetentionBackup", "Secondary"]
    "PointInTime" = ["PointInTimeRestore"]
    "Recovery"    = ["Recovery"]
    "Restore"     = ["Restore"]
  }

  dtu_table = {
    "Standard" = {
      "10"   = "0"
      "20"   = "1"
      "50"   = "2"
      "100"  = "3"
      "200"  = "4"
      "400"  = "6"
      "800"  = "7"
      "1600" = "9"
      "3000" = "12"
    }
    "Premium" = {
      "125"  = "1"
      "250"  = "2"
      "500"  = "4"
      "1000" = "6"
      "1750" = "11"
      "4000" = "15"
    }
  }

  vcore_tier_table = {
    "GeneralPurpose"   = "GP"
    "Hyperscale"       = "HS"
    "BusinessCritical" = "BC"
    "Serverless"       = "GP"
  }

  dtu_models = {
    for db_name, db_value in var.databases :
    db_name => {
      collation   = db_value.collation
      create_mode = db_value.create_mode

      creation_source_database_id = db_value.create_mode != null ? (
        contains(local.create_mode_table["Create"], db_value.create_mode) ? db_value.source_database_id : null
      ) : db_value.source_database_id

      tags           = db_value.additional_tags
      ledger_enabled = db_value.ledger_enabled

      license_type = db_value.bring_your_own_license != null ? (
        db_value.bring_your_own_license ? "LicenseIncluded" : "BasePrice"
      ) : "BasePrice"

      max_size_gb = db_value.data_max_size

      recover_database_id = db_value.create_mode != null ? (
        contains(local.create_mode_table["Recovery"], db_value.create_mode) ? db_value.source_database_id : null
      ) : null

      restore_dropped_database_id = db_value.create_mode != null ? (
        contains(local.create_mode_table["Restore"], db_value.create_mode) ? db_value.source_database_id : null
      ) : null

      restore_point_in_time = db_value.restore_point_in_time
      sku_name              = "${db_value.dtu_model.tier == "Basic" ? "Basic" : substr(db_value.dtu_model.tier, 0, 1)}${db_value.dtu_model.tier == "Basic" ? "" : local.dtu_table[db_value.dtu_model.tier][db_value.dtu_model.dtu]}"
      storage_account_type  = db_value.backup_storage_redundancy
      read_scale            = db_value.read_scale_out_enabled
      zone_redundant        = db_value.zone_redundant
    } if db_value.dtu_model != null
  }

  vcore_models = {
    for db_name, db_value in var.databases :
    db_name => {
      collation   = db_value.collation
      create_mode = db_value.create_mode

      creation_source_database_id = db_value.create_mode != null ? (
        contains(local.create_mode_table["Create"], db_value.create_mode) ? db_value.source_database_id : null
      ) : db_value.source_database_id

      tags           = db_value.additional_tags
      ledger_enabled = db_value.ledger_enabled

      license_type = db_value.bring_your_own_license != null ? (
        db_value.bring_your_own_license ? "LicenseIncluded" : "BasePrice"
      ) : "BasePrice"

      max_size_gb = db_value.data_max_size

      recover_database_id = db_value.create_mode != null ? (
        contains(local.create_mode_table["Recovery"], db_value.create_mode) ? db_value.source_database_id : null
      ) : null

      restore_dropped_database_id = db_value.create_mode != null ? (
        contains(local.create_mode_table["Restore"], db_value.create_mode) ? db_value.source_database_id : null
      ) : null

      restore_point_in_time = db_value.restore_point_in_time

      # For example: GP_S_Gen5_1
      sku_name             = "${local.vcore_tier_table[db_value.vcore_model.tier]}${db_value.vcore_model.tier == "Serverless" ? "_S" : ""}_${db_value.vcore_model.compute != null ? db_value.vcore_model.compute : "Gen5"}_${db_value.vcore_model.vcores}"
      storage_account_type = db_value.backup_storage_redundancy
      read_scale           = db_value.read_scale_out_enabled
      zone_redundant       = db_value.zone_redundant
    } if db_value.dtu_model == null && db_value.vcore_model != null
  }
}

resource "azurerm_mssql_database" "dtu_models" {
  for_each = local.dtu_models

  name           = each.key
  server_id      = azurerm_mssql_server.mssql_server.id
  create_mode    = each.value.create_mode
  license_type   = each.value.license_type
  max_size_gb    = each.value.max_size_gb
  read_scale     = each.value.read_scale
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    each.value.tags
  )
}

resource "azurerm_mssql_database" "vcore_models" {
  for_each = local.vcore_models

  name           = each.key
  server_id      = azurerm_mssql_server.mssql_server.id
  create_mode    = each.value.create_mode
  license_type   = each.value.license_type
  max_size_gb    = each.value.max_size_gb
  read_scale     = each.value.read_scale
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    each.value.tags
  )
}