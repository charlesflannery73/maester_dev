# Add a PowerShell 7.4 runtime environment to the Automation Account using azapi_resource
resource "azapi_resource" "ps74_runtime" {
  type      = "Microsoft.Automation/automationAccounts/runtimeEnvironments@2024-10-23"
  name      = "${var.prefix}-maester-runtime-env-${var.environment}"
  parent_id = azurerm_automation_account.maester.id
  body = {
    properties = {
      runtime = {
        language = "PowerShell"
        version  = "7.4"
      }
      description     = "PowerShell 7.4 runtime for Maester"
      defaultPackages = {
        Az           = "12.3.0"
        "Azure CLI"  = "2.64.0"
      }
    }
  }
  depends_on = [azurerm_automation_account.maester]
}

# Manual install of packages is required as of now, as azurerm_automation_module doesn't support linking to a specific runtime environment yet.
