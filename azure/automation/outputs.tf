output "automation_account_identity" {
  value = azurerm_automation_account.automation_account.identity
}

output "runbook_ids" {
  value = { for k, v in azurerm_automation_runbook.runbooks : k => v.id }
}

output "schedule_ids" {
  value = { for k, v in azurerm_automation_schedule.schedule : k => v.id }
}