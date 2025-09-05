output "automation_account_id" {
	value       = azurerm_automation_account.maester.id
	description = "Resource ID of the Automation Account."
}

output "automation_account_principal_id" {
	value       = azurerm_automation_account.maester.identity[0].principal_id
	description = "System-assigned managed identity Principal ID."
}

output "private_endpoint_ips" {
	value = {
		webhook            = azurerm_private_endpoint.pe_webhook.private_service_connection[0].private_ip_address
		dsc_and_hybridwork = azurerm_private_endpoint.pe_dsc_hw.private_service_connection[0].private_ip_address
	}
	description = "Private IPs assigned to the Automation private endpoints."
}
