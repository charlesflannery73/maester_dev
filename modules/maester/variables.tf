variable "allow_list_ip" {
	type        = list(string)
	description = "List of public IPs allowed to access the storage account."
}
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
