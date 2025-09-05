
Describe "ISM" -Tag "ISM", "ISM-0582", "0582" {
    It "ISM-0582: Security-relevant events for Microsoft Windows operating systems are centrally logged." {

        $extension = "AzureMonitorWindowsAgent"
        $description = "ISM-0582: Security-relevant events for Microsoft Windows operating systems are centrally logged. The $extension extension should be installed for all Windows VMs"

        # get list of windows vms
        $vms = az vm list --query "[?storageProfile.osDisk.osType=='Windows'].{Name:name, Resources:resources}" -o json | ConvertFrom-Json

        # if no windows vms, skip the test
        if ($vms.count -eq 0) {
            Add-MtTestResultDetail -SkippedBecause Custom -SkippedCustomReason "No Windows VMs found."
            return $null
        }

        $result = @()
        # for each windows vm found, check if there is an extension contains "AzureMonitorWindowsAgent"
        $vms_with_extension = $vms | Where-Object { $_.resources -like "*$extension*" }
        write-host $vms_with_extension

        if ($vms.Count -eq @($vms_with_extension).Count) {
            $vmNames = $vms_with_extension | ForEach-Object { $_.Name }
            Add-MtTestResultDetail -Description $description -Result "All VMs have $extension extension installed: $($vmNames -join ', ')"
            $result = $true
        } else {
            # add the list of vm names to the result
            $missingVms = $vms | Where-Object { $vms_with_extension.Name -notcontains $_.Name }
            $missingVmNames = $missingVms | ForEach-Object { $_.Name }
            Add-MtTestResultDetail -Description $description -Result "The following VMs are missing the $extension extension: $($missingVmNames -join ', ')"
            $result = $false
        }

        $result | Should -Be $true -Because "All Windows VMs should have $extension extension installed."

    }
}

