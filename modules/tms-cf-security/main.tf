locals {
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.30.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.any_subscription_id
  tenant_id       = var.target_tenant_id
  features {}
}

module "policy" {
  source = "../../../../../modules/tf-azurerm-policy"

  for_each           = { for eachPolicy in var.policy : eachPolicy.name => eachPolicy }
  policy_assignments = each.value.policy_assignments
  scopes             = each.value.scopes
}
