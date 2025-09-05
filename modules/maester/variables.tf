# Variables for maester module
variable "subscription_id" {
	type        = string
	description = "Azure Subscription ID to deploy into."
}
variable "location" {
	type        = string
	description = "Azure region for all resources (e.g., eastus)."
}
variable "prefix" {
	type        = string
	description = "A short prefix used to name resources."
}
variable "environment" {
	type        = string
	description = "Environment name (e.g., dev, test, prod)."
}
variable "tags" {
	type        = map(string)
	default     = {}
	description = "Additional tags to apply to resources."
}
variable "vnet_address_space" {
	type        = list(string)
	default     = ["10.20.0.0/16"]
	description = "Address space for the VNet."
}
variable "subnet_pe_name" {
	type        = string
	default     = "snet-pe"
	description = "Subnet name for Private Endpoints."
}
variable "subnet_pe_prefix" {
	type        = string
	default     = "10.20.1.0/24"
	description = "Address prefix for the Private Endpoint subnet."
}
variable "automation_sku_name" {
	type        = string
	default     = "Basic"
	description = "Automation account SKU name (e.g., Basic)."
}
variable "log_analytics_workspace_id" {
	type        = string
	default     = null
	description = "Optional: Existing Log Analytics Workspace resource ID to link to Automation account. If null, no link is created."
}
variable "private_dns_zone_name" {
	type        = string
	default     = "privatelink.azure-automation.net"
	description = "Private DNS Zone name for Azure Automation Private Link."
}
variable "link_vnet_ids" {
	type        = list(string)
	default     = []
	description = "Optional list of additional VNet IDs to link to Private DNS zone. The primary VNet used for private endpoints is linked automatically."
}
variable "maester_rbac_role_definition_id" {
	type        = string
	default     = null
	description = "Optional: Role Definition ID for the managed identity assignment. If null, Owner isn't assigned. Prefer using built-in IDs (e.g., Contributor)."
}
variable "maester_rbac_scope" {
	type        = string
	default     = null
	description = "Optional: Scope at which to assign RBAC to the Automation Account's system-assigned identity (e.g., a resource group or subscription ID)."
}
