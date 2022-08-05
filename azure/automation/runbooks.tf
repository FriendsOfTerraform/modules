resource "azurerm_automation_runbook" "runbooks" {
  for_each = var.runbooks

  name                    = each.key
  resource_group_name     = data.azurerm_resource_group.current.name
  location                = local.location
  automation_account_name = azurerm_automation_account.automation_account.name
  runbook_type            = each.value.runbook_type != null ? each.value.runbook_type : "PowerShell" # Default runbook type to Powershell
  log_progress            = each.value.log_progress != null ? each.value.log_progress : true         # Default log progress to true
  log_verbose             = each.value.log_verbose != null ? each.value.log_verbose : false          # Default log verbose to false
  description             = each.value.description
  content                 = substr(each.value.content, 0, 4) != "http" ? each.value.content : null

  dynamic "publish_content_link" {
    for_each = substr(each.value.content, 0, 4) == "http" ? [1] : []

    content {
      uri = each.value.content
    }
  }

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    each.value.additional_tags
  )
}