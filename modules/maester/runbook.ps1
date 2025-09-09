param(
    [string]$StorageHost = "cdfcustomrulesdev.blob.core.windows.net",
    [string]$SubscriptionId = "8ff07d8a-7f17-4b87-a9d1-d25bb8e5d4c7",
    [string]$Container = "cdf-container-dev"
)


Connect-MgGraph -Identity


#Define mail recipient
$MailRecipients = "charles@p.malsec.com.au"
# $MailRecipients = "charles@p.malsec.com.au","james@p.malsec.com.au","ben@p.malsec.com.au"

# Define mail sender
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
#Run Maester report
cd $env:TEMP
md maester-tests
cd maester-tests
md tests

# uncomment to install the maester tests 
#Install-MaesterTests .\tests
#Remove-Item .\tests\Maester\Intune\Test-MtIntunePlatform.Tests.ps1

# add our custom tests 
$BlobName = "Custom.zip"
$BlobUrl = "https://$StorageHost/$Container/$BlobName"
$DestZip = "$env:TEMP\maester-tests\$BlobName"
$DestFolder = "$env:TEMP\maester-tests\tests\Custom"
try {
    Invoke-WebRequest -Uri $BlobUrl -OutFile $DestZip -ErrorAction Stop
    if (!(Test-Path $DestZip -PathType Leaf)) {
        throw "$BlobUrl was not downloaded."
    }
} catch {
    Write-Error "Failed to download $BlobUrl"
    exit 1
}
Expand-Archive -Path $DestZip -DestinationPath $DestFolder -Force
Invoke-Maester -MailUserId $MailSenderUUID -MailRecipient $MailRecipients -OutputFolder $TempOutputFolder -NonInteractive