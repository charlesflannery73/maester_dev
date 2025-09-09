output "automation_account_id" {
	value       = azurerm_automation_account.maester.id
	description = "Resource ID of the Automation Account."
}

output "automation_account_principal_id" {
	value       = azurerm_automation_account.maester.identity[0].principal_id
	description = "System-assigned managed identity Principal ID."
}


