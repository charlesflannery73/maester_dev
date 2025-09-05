variable "subscription_id" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }
variable "environment" { type = string }
variable "vnet_address_space" { type = list(string) }
variable "subnet_pe_name" { type = string }
variable "subnet_pe_prefix" { type = string }
variable "automation_sku_name" {
  type    = string
  default = "Basic"
}
variable "log_analytics_workspace_id" {
  type    = string
  default = null
}
variable "private_dns_zone_name" { type = string }
variable "link_vnet_ids" {
  type    = list(string)
  default = []
}
variable "maester_rbac_role_definition_id" {
  type    = string
  default = null
}
variable "maester_rbac_scope" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(string)
  default = {}
}

module "maester" {
  source = "./modules/maester"
  subscription_id                 = var.subscription_id
  location                        = var.location
  prefix                          = var.prefix
  environment                     = var.environment
  tags                            = var.tags
  vnet_address_space              = var.vnet_address_space
  subnet_pe_name                  = var.subnet_pe_name
  subnet_pe_prefix                = var.subnet_pe_prefix
  automation_sku_name             = var.automation_sku_name
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  private_dns_zone_name           = var.private_dns_zone_name
  link_vnet_ids                   = var.link_vnet_ids
  maester_rbac_role_definition_id = var.maester_rbac_role_definition_id
  maester_rbac_scope              = var.maester_rbac_scope
}
