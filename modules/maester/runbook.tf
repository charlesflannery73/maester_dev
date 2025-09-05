resource "azurerm_automation_runbook" "maester_runbook" {
  name                    = "${var.prefix}-maester-runbook-${var.environment}"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  log_verbose             = true
  log_progress            = true
  description             = "Runbook to execute Maester report and email results."
  runbook_type            = "PowerShell"
  content                 = file("${path.module}/runbook.ps1")
  job_schedule {
    schedule_name = azurerm_automation_schedule.maester_runbook_schedule.name
  }

  depends_on = [azurerm_automation_account.maester, azapi_resource.ps74_runtime]
}

resource "azurerm_automation_schedule" "maester_runbook_schedule" {
  name                    = "${var.prefix}-maester-runbook-schedule-${var.environment}"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.maester.name
  frequency               = "Week"
  timezone                = "Australia/Sydney"
  description             = "Maester Weekly Schedule"
  week_days               = ["Friday"]
}
