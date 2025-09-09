
# first test if we already have an identity (for running with a user identity),
# if not then try to connect with managed identity
if (-not (Get-AzContext)) {
    try {
        Connect-AzAccount -Identity -ErrorAction Stop
    } catch {
        Write-Host "No existing Az context and failed to connect with managed identity. Please login with Connect-AzAccount."
        throw $_
    }
}

Describe "ISM" -Tag "ISM", "ISM-0582", "0582" {
    It "ISM-0582: Security-relevant events for Microsoft Windows operating systems are centrally logged." {

        $extension = "AzureMonitorWindowsAgent"
        $description = "ISM-0582: Security-relevant events for Microsoft Windows operating systems are centrally logged. The $extension extension should be installed for all Windows VMs"

        $vms = Get-AzVM | Where-Object { $_.StorageProfile.OsDisk.OsType -eq "Windows" }

        # if no windows vms, skip the test
        if ($vms.count -eq 0) {
            Add-MtTestResultDetail -SkippedBecause Custom -SkippedCustomReason "No Windows VMs found."
            return $null
        }

        # check if the extension is installed on all windows vms
        $result = $true
        $result_message = ""
        foreach ($vm in $vms) {
            $extensions = Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name
            if ($extensions.name -notcontains $extension) {
                $result = $false
                $result_message += "VM $($vm.Name) is missing the $extension extension.`n`n"
            } else {
                $result_message += "VM $($vm.Name) has the $extension extension installed.`n`n"
            }
        }

        # output the result
        if ($result) {
            Add-MtTestResultDetail -Description $description -Result "All Windows VMs have $extension extension installed.`n`n$result_message"
        } else {
            Add-MtTestResultDetail -Description $description -Result "Some Windows VMs are missing the $extension extension.`n`n$result_message"
        }
        $result | Should -Be $true -Because "All Windows VMs should have $extension extension installed."
    }
}

