variable "allow_list_ip" {
  type = list(string)
  description = "List of public IPs allowed to access the storage account."
}
variable "subscription_id" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }
variable "environment" { type = string }
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
  source                        = "./modules/maester"
  subscription_id               = var.subscription_id
  location                      = var.location
  prefix                        = var.prefix
  environment                   = var.environment
  tags                          = var.tags
  maester_rbac_role_definition_id = var.maester_rbac_role_definition_id
  maester_rbac_scope            = var.maester_rbac_scope
  allow_list_ip                 = var.allow_list_ip
}