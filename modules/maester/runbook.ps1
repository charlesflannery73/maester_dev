param(
    [string]$StorageHost = "cdfcustomrulesdev.blob.core.windows.net",
    [string]$SubscriptionId = "8ff07d8a-7f17-4b87-a9d1-d25bb8e5d4c7",
    [string]$Container = "cdf-container-dev"
)

Connect-MgGraph -Identity

$MailRecipients = "charles@p.malsec.com.au"
# $MailRecipients = "charles@p.malsec.com.au","james@p.malsec.com.au","ben@p.malsec.com.au"

$MailSenderEmail = "charles@p.malsec.com.au" # "553050a4-b699-4f8f-ad86-84fa3ecbcd19"

# Lookup the mail sender uuid directly
$AllUsers = Get-MtUser -Count 10000
$user = $AllUsers | Where-Object { $_.userPrincipalName -eq $MailSenderEmail }
$MailSenderUUID = $user.id

if (!$MailSenderUUID) {
    write-Error "Mail Sender UUID not found for $MailSenderEmail"
    exit
}

#create output folder
$date = (Get-Date).ToString("yyyyMMdd-HHmm")
$FileName = "MaesterReport" + $Date + ".zip"

$TempOutputFolder = $env:TEMP + $date
if (!(Test-Path $TempOutputFolder -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $TempOutputFolder
}

# set up temp folders for maester tests
cd $env:TEMP
md maester-tests
cd maester-tests
md tests

# #uncomment to install the maester tests 
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
Invoke-Maester -MailUserId $MailSenderUUID -MailRecipient $MailRecipients -OutputFolder $TempOutputFolder -NonInteractive