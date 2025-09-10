if (-not (Get-AzContext)) {
    try {
        Connect-AzAccount -Identity -ErrorAction Stop
    } catch {
        Write-Host "No existing Az context and failed to connect with managed identity. Please login with Connect-AzAccount."
        throw $_
    }
}
Describe "ISM" -Tag "ISM", "0520", "ISM-0250", "StoragePublicAccess" {
    It "ISM-0520: Network access controls are implemented on networks to prevent the connection of unauthorised network devices and networked IT equipment." {

        $description = "Check all storage accounts for public access settings. Enabled from selected networks is considered a pass but should be verified"

        $result = $true
        $result_message = ""

        $storageAccounts = Get-AzStorageAccount

        # if no storage accounts, skip the test
        if ($storageAccounts.Count -eq 0) {
            Add-MtTestResultDetail -SkippedBecause Custom -SkippedCustomReason "No storage accounts found."
            return $null
        }

        foreach ($account in $storageAccounts) {
            # Check network rules for public access
            $networkRuleSet = Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $account.ResourceGroupName -Name $account.StorageAccountName
            $defaultAction = $networkRuleSet.DefaultAction
            $virtualNetworkRules = $networkRuleSet.VirtualNetworkRules
            $ipRules = $networkRuleSet.IpRules

            if ($defaultAction -eq "Allow") {
                $result = $false
                $result_message += "$($account.StorageAccountName) has public access enabled.`n`n"
            } elseif ($defaultAction -eq "Deny" -and ($virtualNetworkRules.Count -gt 0 -or $ipRules.Count -gt 0)) {
                $ipList = $ipRules | ForEach-Object { $_.IPAddressOrRange } | Where-Object { $_ } | Sort-Object | Out-String
                $result_message += "$($account.StorageAccountName) has public access enabled only for selected networks or IPs: $ipList`n`n"
            } else {
                $result_message += "$($account.StorageAccountName) has public access disabled.`n`n"
            }
        }

        # output the result
        if ($result) {
            Add-MtTestResultDetail -Description $description -Result "No storage accounts have public access enabled.`n`n$result_message"
        } else {
            Add-MtTestResultDetail -Description $description -Result "Some storage accounts have public access enabled.`n`n$result_message"
        }
        $result | Should -Be $true -Because "All storage accounts should have public access disabled."
    }
}