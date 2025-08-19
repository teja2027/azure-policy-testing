include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders(format("environments/%s.hcl", get_env("ENVIRONMENT"))))
}

dependency "tms-cf-management" {
  config_path = "../tms-cf-management"
}

inputs = {
  any_subscription_id = local.environment_vars.locals.subscription_id
  target_tenant_id    = local.environment_vars.locals.target_tenant_id
  policy              = yamldecode(file("policy.yaml"))
}

terraform {
  source = "../../modules/tms-cf-security"
}