# Get current subscription for role assignment scope
data "azurerm_subscription" "current" {}
# Assign Reader role to Automation Account's managed identity
resource "azurerm_role_assignment" "automation_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"  # needed for some Azure cmdlets
  principal_id         = azurerm_automation_account.maester.identity[0].principal_id
  depends_on           = [azurerm_automation_account.maester]
}


# resource "azurerm_virtual_network" "maester" {
#   name                = "${var.prefix}-vnet-maester-${var.environment}"
#   address_space       = ["10.10.0.0/16"]
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg.name
#   tags                = local.common_tags
# }

# resource "azurerm_subnet" "maester_pe" {
#   name                 = "${var.prefix}-subnet-pe-${var.environment}"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.maester.name
#   address_prefixes     = ["10.10.1.0/24"]
#   service_endpoints    = ["Microsoft.Storage"]
# }

# resource "azurerm_private_dns_zone" "storage" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
#   name                  = "${var.prefix}-dns-vnet-link-${var.environment}"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.storage.name
#   virtual_network_id    = azurerm_virtual_network.maester.id
#   registration_enabled  = false
# }

locals {
  resource_group_name = "${var.prefix}-rg-maester-${var.environment}"
  automation_account_name = "${var.prefix}-aa-maester-${var.environment}"
  common_tags = merge({
    environment = var.environment
    workload    = "maester"
    provisioner = "terraform"
  }, var.tags)
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}


resource "azurerm_automation_account" "maester" {
  name                = local.automation_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = local.resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = false
  tags = local.common_tags
}


# RBAC assignment for the system-assigned identity
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

