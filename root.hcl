locals {
  project_name     = "tms-cloud-foundation"
  environment      = get_env("ENVIRONMENT")
  environment_vars = read_terragrunt_config(find_in_parent_folders(format("environments/%s.hcl", get_env("ENVIRONMENT"))))
}

remote_state {
  disable_dependency_optimization = true
  backend                         = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    use_azuread_auth     = true
    tenant_id            = local.environment_vars.locals.tf_state_tenant_id
    storage_account_name = local.environment_vars.locals.tf_state_storage_account_name
    container_name       = local.environment_vars.locals.tf_state_container_name
    key                  = format("%s.%s.%s.terraform.tfstate", local.project_name, replace(path_relative_to_include(), "/", "."), local.environment)
  }
}

terraform {
  extra_arguments "env_vars" {
    commands = ["apply", "plan", "destroy", "init", "workspace", "state", "refresh", "import", "output", "force-unlock", "console"]
    env_vars = jsondecode(
      run_cmd(
        "--terragrunt-quiet",
        "/bin/bash",
        "${get_repo_root()}/bin/get-azure-creds-from-vault.sh",
        local.environment_vars.locals.tf_secrets_vault_name,
        local.environment_vars.locals.tf_secrets_arm_client_id_name,
        local.environment_vars.locals.tf_secrets_arm_client_secret_name
      )
    )
  }
}