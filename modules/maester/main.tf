locals {
  resource_group_name = "${var.prefix}-rg-maester-${var.environment}"
  automation_account_name = "${var.prefix}-aa-maester-${var.environment}"
  common_tags = merge({
    environment = var.environment
    workload    = "maester"
    provisioner = "terraform"
  }, var.tags)
}
# Maester module main.tf
# Contains all resources for Automation Account, VNet, PE, DNS, RBAC, and Graph permissions

# All resources for Automation Account, VNet, PE, DNS, RBAC, and Graph permissions
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet-${var.environment}"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = local.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_subnet" "pe" {
  name                = var.subnet_pe_name
  resource_group_name = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = [var.subnet_pe_prefix]
}

resource "azurerm_private_dns_zone" "automation" {
  name                = var.private_dns_zone_name
  resource_group_name = local.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "automation_primary" {
  name                  = "${var.prefix}-pdnslink-${var.environment}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.automation.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "automation_additional" {
  for_each              = { for id in var.link_vnet_ids : id => id }
  name                  = "${var.prefix}-pdnslink-${replace(each.key, "/", "-")}-${var.environment}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.automation.name
  virtual_network_id    = each.value
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_automation_account" "maester" {
  name                = local.automation_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = local.resource_group_name
  sku_name            = var.automation_sku_name

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = false

  tags = local.common_tags
}


# Private Endpoint - Webhook sub-resource
resource "azurerm_private_endpoint" "pe_webhook" {
  name                = "${var.prefix}-pe-webhook-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "${var.prefix}-psc-webhook-${var.environment}"
    private_connection_resource_id = azurerm_automation_account.maester.id
    is_manual_connection           = false
    subresource_names              = ["Webhook"]
  }

  private_dns_zone_group {
    name                 = "${var.prefix}-pdz-webhook-${var.environment}"
    private_dns_zone_ids = [azurerm_private_dns_zone.automation.id]
  }
}

# Private Endpoint - DSCAndHybridWorker sub-resource
resource "azurerm_private_endpoint" "pe_dsc_hw" {
  name                = "${var.prefix}-pe-dschw-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "${var.prefix}-psc-dschw-${var.environment}"
    private_connection_resource_id = azurerm_automation_account.maester.id
    is_manual_connection           = false
    subresource_names              = ["DSCAndHybridWorker"]
  }

  private_dns_zone_group {
    name                 = "${var.prefix}-pdz-dschw-${var.environment}"
    private_dns_zone_ids = [azurerm_private_dns_zone.automation.id]
  }
}

# Optional RBAC assignment for the system-assigned identity
resource "azurerm_role_assignment" "maester" {
  count                = var.maester_rbac_role_definition_id != null && var.maester_rbac_scope != null ? 1 : 0
  scope                = var.maester_rbac_scope
  role_definition_id   = var.maester_rbac_role_definition_id
  principal_id         = azurerm_automation_account.maester.identity[0].principal_id
  principal_type       = "ServicePrincipal"
  depends_on           = [azurerm_automation_account.maester]
}

# Microsoft Graph permissions assignment

data "azuread_service_principal" "maester" {
  object_id = azurerm_automation_account.maester.identity[0].principal_id
}

data "azuread_service_principal" "msgraph" {
  display_name = "Microsoft Graph"
}

locals {
  maester_graph_app_role_values = [
    "DeviceManagementConfiguration.Read.All",
    "DeviceManagementManagedDevices.Read.All",
    "Directory.Read.All",
    "DirectoryRecommendations.Read.All",
    "IdentityRiskEvent.Read.All",
    "Policy.Read.All",
    "Policy.Read.ConditionalAccess",
    "PrivilegedAccess.Read.AzureAD",
    "Reports.Read.All",
    "RoleEligibilitySchedule.Read.Directory",
    "RoleManagement.Read.All",
    "SharePointTenantSettings.Read.All",
    "UserAuthenticationMethod.Read.All",
    "RoleEligibilitySchedule.ReadWrite.Directory",
    "Mail.Send"
  ]
  maester_graph_app_role_ids = [
    for role in data.azuread_service_principal.msgraph.app_roles :
    role.id if contains(local.maester_graph_app_role_values, role.value)
  ]
}

resource "azuread_app_role_assignment" "maester_graph" {
  for_each                      = toset(local.maester_graph_app_role_ids)
  principal_object_id           = data.azuread_service_principal.maester.object_id
  app_role_id                   = each.value
  resource_object_id            = data.azuread_service_principal.msgraph.object_id
}
