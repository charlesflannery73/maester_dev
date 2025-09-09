

# Get current subscription for role assignment scope
data "azurerm_subscription" "current" {}
# Assign Reader role to Automation Account's managed identity
resource "azurerm_role_assignment" "automation_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"  # needed for some Azure cmdlets
  principal_id         = azurerm_automation_account.maester.identity[0].principal_id
  depends_on           = [azurerm_automation_account.maester]
}

# Output the storage account host for use in automation scripts
output "custom_storage_host" {
  value = "${azurerm_storage_account.custom.name}.blob.core.windows.net"
  description = "The hostname for the custom rules storage account."
}

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

# Storage Account for Custom module
resource "azurerm_storage_account" "custom" {
  name                     = "${var.prefix}customrules${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_storage_container" "custom" {
  name                  = "${var.prefix}-container-${var.environment}"
  storage_account_name  = azurerm_storage_account.custom.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "custom_module" {
  name                   = "Custom.zip"
  storage_account_name   = azurerm_storage_account.custom.name
  storage_container_name = azurerm_storage_container.custom.name
  type                   = "Block"
  source                 = "${path.module}/Custom.zip"
}

resource "azurerm_automation_module" "custom" {
  name                    = "Custom"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = azurerm_storage_blob.custom_module.url
  }
  depends_on = [azurerm_automation_account.maester]
}