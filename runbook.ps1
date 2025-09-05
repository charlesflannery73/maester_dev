Connect-MgGraph -Identity

#Define mail recipient
$MailRecipients = "charles@p.malsec.com.au","james@p.malsec.com.au","ben@p.malsec.com.au"

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
Install-MaesterTests .\tests
Remove-Item .\tests\Maester\Intune\Test-MtIntunePlatform.Tests.ps1
Invoke-Maester -MailUserId $MailSenderUUID -MailRecipient $MailRecipients -OutputFolder $TempOutputFolder