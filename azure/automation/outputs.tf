output "automation_account_identity" {
  description = <<EOT
    List of identities attached to the automation account
    
    @type list(object)
    @since 0.0.1
  EOT
  value = azurerm_automation_account.automation_account.identity
}

output "runbook_ids" {
  description = <<EOT
    List of runbook IDs
    
    @type map(string)
    @since 0.0.1
  EOT
  value = { for k, v in azurerm_automation_runbook.runbooks : k => v.id }
}

output "schedule_ids" {
  description = <<EOT
    List of schedule IDs
    
    @type map(string)
    @since 0.0.1
  EOT
  value = { for k, v in azurerm_automation_schedule.schedule : k => v.id }
}