# Maester Automation on Azure (Terraform)

This Terraform project deploys an Azure Automation Account to run Maester with network isolation via Azure Private Link, a dedicated resource group, a virtual network and private endpoint subnet, private DNS for Automation, and optional RBAC for the system-assigned managed identity.

Highlights:
- Dedicated resource group for the deployment
- Azure Automation Account with system-assigned identity and public network access disabled
- VNet and subnet for Private Endpoints (network policies enabled)
- Two Private Endpoints to Azure Automation: Webhook and DSCAndHybridWorker
- Private DNS zone `privatelink.azure-automation.net` with VNet link(s)
- Optional: link to an existing Log Analytics workspace
- Optional: RBAC role assignment(s) for Maester’s managed identity

Important limitations: Azure Automation Private Link does not support cloud jobs accessing other Private Link–secured services. For such scenarios, use Hybrid Runbook Workers.

## Inputs

Configure values in `terraform.tfvars` (see `terraform.tfvars.example`). Key variables:
- subscription_id, location, prefix, environment, resource_group_name, automation_account_name
- vnet_address_space, subnet_pe_name, subnet_pe_prefix
- private_dns_zone_name (defaults to privatelink.azure-automation.net)
- log_analytics_workspace_id (optional)
- maester_rbac_role_definition_id, maester_rbac_scope (optional)

## What gets created

- Resource Group: holds all assets
- VNet and Private Endpoint Subnet: for PE NICs
- Azure Automation Account: system-assigned identity, public network disabled
- Private Endpoints: Webhook and DSCAndHybridWorker subresources
- Private DNS zone and VNet link(s)
- Optional role assignment for the Automation managed identity

## How to run (Windows PowerShell)

1. Install Terraform and Azure CLI.
2. Copy the example tfvars:
	- Copy `terraform.tfvars.example` to `terraform.tfvars` and update values.
3. Login and set subscription:
```
az login
az account set --subscription <subscription_id>
```
4. Initialize and apply:
```
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

## DNS and Private Link notes

- The Private DNS zone `privatelink.azure-automation.net` is created and linked to your VNet. If you need additional VNets, add their IDs to `link_vnet_ids`.
- If your Automation Account is linked to Log Analytics, consider enabling Private Link for the workspace separately.

## Next steps

- Provide the specific permissions Maester needs and set `maester_rbac_role_definition_id` and `maester_rbac_scope` accordingly.
- If you’ll run Hybrid Workers, deploy them into the VNet and verify DNS resolution to the private endpoints.

For deploying maester to automatically run regularly checks against an Azure tenant or subscription
