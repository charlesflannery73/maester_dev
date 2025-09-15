# Deploys the Maester test framework and scheduler

```bash
# package the custom checks
cd modules/maester
./build.ps1
cd ../../

# deploy
terraform init
terraform plan
terraform apply 
```

## After deployment some manual steps are required

### 1. Assign the runbook to the created runtime environment
- Open Azure Portal
- Search for "runbook" and select the created one
- Click Edit
- In the "Runtime Environment" dropdown, select the custom created one
- Select Publish

### 2. Install packages to the custom runtime environment

- Open Azure Portal
- Search for "Automation Accounts" choose the created one
- Click "Process Automation", then "Runtime Environments" (may need to "Try Runtime Environment Experience" if option is not available )
- Select the custom created one
- Click add from Gallery
    - Search for the below packages, select them
    - Maester, Pester, Nuget, Microsoft.Graph.Authentication, PackageManagement
- Click Add File
    - at the Custom.zip file from this repository containing the custom checks
- Click save

### 3. Edit the schedule and the email sender and recipients
- Open Azure Portal
- Search for "Automation Accounts" choose the created one
- Click shared resources - Schedules - choose the created one
- edit as required

### 4. Edit the email sender and recipients
- Open Azure Portal
- Search for "Automation Accounts" choose the created one
- Click Process Automation - Runbooks - choose the created one - edit - edit in portal
- Edit the variable $MailRecipients
- Edit the variable $MailSenderEmail
- Save, Publish
- Optionally - Click "Start" to run it manually

### 5. Create a hybrid worker group (so the runbook can access the storage securely)
- UPDATE - there is issues where both hybrid worker and runbooks can't access private dns to then access the storage privately
- 1. Limitation - runbook Az moudle versions don't (yet) support the latest version on Az modules
- 2. Limitation - hybrid worker VM extension also have old versions that don't support private dns
- 
- For now the runbook need to access it publicy (storage needs public access enabled)
- Storage is still protected by identity, just not by networking rules.