
Describe "ISM" -Tag "ISM", "ISM-0414", "0414" {
    It "ISM-0414: Personnel granted access to a system and its resources are uniquely identifiable." {
        $description = "ISM-0414: Personnel granted access to a system and its resources are uniquely identifiable. Check all users have MFA enabled"

        # Get all users
        $users = Get-MtUser -Count 100000

        # if no users, skip the test
        if ($users.count -eq 0) {
            Add-MtTestResultDetail -SkippedBecause Custom -SkippedCustomReason "No users found."
            return $null
        }

        # Prepare results
        $result = $true
        $result_message = ""
        foreach ($user in $users) {
            $methods = Get-MtUserAuthenticationMethod -UserId $user.Id -ErrorAction SilentlyContinue
            if (!$methods.IsMFA) {
                $result = $false
                $result_message += "User $($user.UserPrincipalName) is missing MFA.`n`n"
            } else {
                $result_message += "User $($user.UserPrincipalName) has MFA enabled.`n`n"
            }
        }

        # output the result
        if ($result) {
            Add-MtTestResultDetail -Description $description -Result "All Users have MFA enabled.`n`n$result_message"
        } else {
            Add-MtTestResultDetail -Description $description -Result "Some Users are missing MFA.`n`n$result_message"
        }
        $result | Should -Be $true -Because "All Users should have MFA enabled."
    }
}