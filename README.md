# Deploys the Maester test framework and scheduler

```bash
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
- Click save

