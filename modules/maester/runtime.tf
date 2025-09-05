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


/*
# Add required PowerShell modules to the Automation Account (PowerShell 7.4)
resource "azurerm_automation_module" "maester" {
  name                    = "Maester"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://github.com/maester365/maester/releases/download/1.3.0/maester.zip"
  }
  depends_on = [azurerm_automation_account.maester]
}

resource "azurerm_automation_module" "microsoft_graph_automation" {
  name                    = "Microsoft.Graph.Automation"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Automation"
  }
  depends_on = [azurerm_automation_account.maester]
}

resource "azurerm_automation_module" "pester" {
  name                    = "Pester"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://github.com/pester/Pester/archive/refs/tags/5.7.1.zip"
  }
  depends_on = [azurerm_automation_account.maester]
}

# Example: Install Pester package and link to PowerShell 7.4 runtime environment
resource "azurerm_automation_module" "maester" {
  name                    = "Maester"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://github.com/maester365/maester/releases/download/1.3.0/maester.zip"
  }
  depends_on = [azurerm_automation_account.maester]
}

resource "azurerm_automation_module" "microsoft_graph_automation" {
  name                    = "Microsoft.Graph.Automation"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Automation"
  }
  depends_on = [azurerm_automation_account.maester]
}

resource "azurerm_automation_module" "pester" {
  name                    = "Pester"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://github.com/pester/Pester/archive/refs/tags/5.7.1.zip"
  }
  depends_on = [azurerm_automation_account.maester]
}

resource "azurerm_automation_module" "nuget" {
  name                    = "Nuget"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Nuget"
  }
  depends_on = [azurerm_automation_account.maester]
}

resource "azurerm_automation_module" "packagemanagement" {
  name                    = "PackageManagement"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/PackageManagement"
  }
  depends_on = [azurerm_automation_account.maester]
}


resource "azurerm_automation_module" "nuget" {
  name                    = "Nuget"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Nuget"
  }
  depends_on = [azurerm_automation_account.maester]
}

resource "azurerm_automation_module" "packagemanagement" {
  name                    = "PackageManagement"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/PackageManagement"
  }
  depends_on = [azurerm_automation_account.maester]
}
*/