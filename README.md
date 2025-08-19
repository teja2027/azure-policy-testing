
# Applying the Configuration

## Azure CLI

The Azure CLI must be available on the ```$PATH``` and be logged in prior
to running any ```terragrunt``` commands. This is because ```terragrunt``` will use
the logged-in user to retrieve service principal keys from a key vault.

    az login

## Choosing an environment

Two environments are defined, ```dev``` and ```prod```. All terragrunt commands must
be preprended with ```ENVIRONMENT=dev``` or ```ENVIRONMENT=prod``` to indicate which
environment is the intended target.

Additionally, state must be reconfigured when switching between environments. 

To switch to the ```dev``` environment, run this command from within the ```/stacks``` directory:

    $ az login # login to account in dev tenant with access to vault
    $ ENVIRONMENT=dev terragrunt run-all init -reconfigure

To switch to the ```prod``` environment, run this command from within the ```/stacks``` directory:

    $ az login # login to account in prod tenant with access to vault
    $ ENVIRONMENT=prod terragrunt run-all init -reconfigure

## Working with a stack

To deploy a stack, change into its sub-directory e.g. ```tms-cf-identity``` and run ```terragrunt``` commands:

    $ cd tms-cf-identity
    $ ENVIRONMENT=dev terragrunt run plan


## Bootstrapping Notes

Follow this process to associate a tenant to a lead tenant, and grant access
for an administrator of the associated tenant to create new subscriptions.

### Target Tenant Access

Perform initial bootstrap activities to enable applying the configurations
in this repository.

1.  Get Global Administrator access with your CAM account to the target
tenant, e.g. ```cam.daniel.restelli@mytmswdev.onmicrosoft.com```.
1.  In the target tenant, enable "Access Management for Azure Resources"
for your cam account. This option is located in "Entra Id" -> "Properties".

### Add Target Tenant as Associated Billing Tenant

In the lead tenant, add your target tenant as an Associated Billing
Tenant.

1.  Log in as Billing Owner to the lead tenant e.g. "cam.daniel.restelli@havi.com"
1.  Select "Cost Management + Billing" -> "Billing Scope" -> "The Havi Group, LP"
1.  Select "Access Control (IAM) -> "Associated billing tenants" -> "Add"
    1.  Target name e.g. "mytmsw.onmicrosoft.com"
    1.  Target tenant id e.g. "fd87b129-c90d-4326-b50c-1046a5061d41"
    1.  Select "Provisioning" and "Billing management" access settings.
    1.  Save.

A request is created for Global Admins of the target tenant to approve the
association. 

To approve the request:

1.  Log in as Billing Owner to the lead tenant e.g. "cam.daniel.restelli@havi.com"
1.  Select "Cost Management + Billing" -> "Billing Scope" -> "The Havi Group, LP"
1.  Select "Access Control (IAM)" -> "Manage requests"
1.  Select the request ID.
1.  Copy the invitation link and paste it into a new browser tab.
1.  Log in as a Global Administrator of the target tenant e.g. "cam.daniel.restelli@mytmswdev.onmicrosoft.com"
1.  Select "Approve"

The target tenant is now an Associated Billing Tenant of the lead tenant.

### Grant Target Tenant admin Permission to Create Subscriptions 

Continue to allow administrators of the target tenant to create new subscriptions in the
"HAVI tms" billing profile and invoice section:

1.  Log in as Billing Owner to the lead tenant e.g. "cam.daniel.restelli@havi.com"
1.  Select "Cost Management + Billing" -> "Billing Scope" -> "The Havi Group, LP"
1.  Select "Billing profiles" -> "HAVI tms" -> "Access control (IAM)" -> "Add"
1.  Select "Billing profile owner"
1.  Select the associated tenant e.g, "mytmswdev.onmicrosoft.com"
1.  Enter the CAM account id e.g. "cam.daniel.restelli@mytmswdev.onmicrosoft.com"
1.  Select "Add"

A request is created for the CAM account to approve the permission grant.

To approve the requst:

1.  Log in as Billing Owner to the lead tenant e.g. "cam.daniel.restelli@havi.com"
1.  Select "Cost Management + Billing" -> "Billing Scope" -> "The Havi Group, LP"
1.  Select "Billing profiles" -> "HAVI tms" -> "Access control (IAM)"
1.  Select "Manage Requests"
1.  Click on the invitation ID.
1.  Copy the link.
1.  Copy the invitation link and paste it into a new browser tab.
1.  Log in as the invited user in the target tenant e.g. "cam.daniel.restelli@mytmswdev.onmicrosoft.com"
1.  Select "Approve"

### Create Initial Auotmation Subscription

Terraform requries a subscription in order to operate. Manually create an
initial subscription in the target tenant.

1. Log into the target tenant.
1. Select "Subscriptions" -> "Add"
    * Subscription Name: e.g. tms-cf-automation-dev-sub
    * Billing Account: The Havi Group, LP
    * Billing Profile: HAVI tms
    * Invoice Section: HAVI tms
    * Plan: Microsoft Azure Plan
    * Ensure Subscription Directory is set to the target tenant.
    * Management Group: Root management group
    * Create

Note the ID of the subscription created and update ```.hcl``` file in 
```environments``` directory to specify ```subscription_id``` input.

## Banner Text

[Tool to generate banner text](https://manytools.org/hacker-tools/ascii-banner/). The font is "Big".


