param(
    [string]$storageaccountname = "",
    [string]$containername = "",
    [string]$sastokenwrite = "",
    [string]$sastokenread =  ""
)

Connect-MgGraph -Identity

$MailRecipients = "charles@p.malsec.com.au"
# $MailRecipients = "charles@p.malsec.com.au","james@p.malsec.com.au","ben@p.malsec.com.au"

$MailSenderEmail = "charles@p.malsec.com.au" # "553050a4-b699-4f8f-ad86-84fa3ecbcd19"

# Lookup the mail sender uuid directly
$user = Get-MtUser -Count 100000 | Where-Object { $_.userPrincipalName -eq $MailSenderEmail }
$MailSenderUUID = $user.id

if (!$MailSenderUUID) {
    write-Error "Mail Sender UUID not found for $MailSenderEmail"
    exit
}

# set up temp folders for maester tests
cd $env:TEMP
md maester-tests/tests
cd maester-tests


# #uncomment to install all the maester tests 
# Install-MaesterTests .\tests
# #This test is buggy and causes an error
# Remove-Item .\tests\Maester\Intune\Test-MtIntunePlatform.Tests.ps1

# Copy our custom tests from shared modules path
try {
    Import-Module Custom -ErrorAction Stop   # C:\usr\src\PSModules\Custom
        
    $ModulePath = (Get-Module Custom).ModuleBase
    $DestFolder = "$env:TEMP\maester-tests\tests\Custom"
    
    # remove previous contents of the folder if it exists
    if (Test-Path $DestFolder -PathType Container) {
        Get-ChildItem -Path $DestFolder -Recurse | Remove-Item -Force -Recurse
    } else {
        New-Item -ItemType Directory -Force -Path $DestFolder
    }

    # copy custom measter tests to the test test custom folder
    Get-ChildItem -Path $ModulePath | ForEach-Object {
        Copy-Item $_.FullName -Destination $DestFolder -Force
    }
} catch {
    Write-Output "Error details: $($_.Exception.Message)"
    exit 1
}

# create Maester detailed result file name with date and time
$OutputHtmlFile = "MaesterDetailedReport_$((Get-Date).ToString('yyyyMMdd-HHmm')).html"

# create shareable SAS URL for the output file
$sasUrl = "https://$storageaccountname.blob.core.windows.net/$containername/$OutputHtmlFile$sastokenread"
Write-Output "Shareable SAS URL: $sasUrl"

Invoke-Maester -MailUserId $MailSenderUUID -MailRecipient $MailRecipients -OutputHtmlFile $OutputHtmlFile -MailTestResultsUri $sasUrl -NonInteractive
$context = New-AzStorageContext -StorageAccountName $storageaccountname -SasToken $sastokenwrite
Set-AzStorageBlobContent -File "$OutputHtmlFile" -Container $containername -Blob $OutputHtmlFile -Context $context -Force
