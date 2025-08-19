locals {
    environment                       = "dev"
    target_tenant_id                  = "fd87b129-c90d-4326-b50c-1046a5061d41" # mytmswdev.onmicrosoft.com
    subscription_id                   = "7a32a1cd-eda9-40cf-97d8-6694914d888c" # tms-cf-automation-dev-sub
    lead_tenant_id                    = "585bda71-88ce-428b-9832-95eaa3dce989" # havi.com
    lead_any_subscription_id          = "5153108b-4386-4414-84f1-1892d37bbee9" # HAVI Cloud Cost Management
    billing_account_name              = "f61e4950-4d58-4e1f-9538-df0ab264f2da:f04fb2fc-b21b-41e9-b717-63d9c363b88f_2019-05-31"
    billing_profile_name              = "HQI6-RYEW-BG7-PGB" # HAVI tms
    invoice_section_name              = "7C7J-4ZRF-PJA-PGB" # HAVI tms
    tf_secrets_vault_name             = "tmscftmtndvkv"
    tf_state_container_name           = "tfstate"
    tf_state_resource_group_name      = "tms-cf-automation-dev-tf-rg"
    tf_state_storage_account_name     = "tmscftmtndvsa"
    tf_state_subscription_id          = "7a32a1cd-eda9-40cf-97d8-6694914d888c"
    tf_state_tenant_id                = "fd87b129-c90d-4326-b50c-1046a5061d41"
    tf_secrets_arm_client_id_name     = "arm-client-id"
    tf_secrets_arm_client_secret_name = "arm-client-secret"
    new_subscription_owner_id         = "57eaa067-f442-4a8f-87a4-d71333e44642" # tms-cf-automation-dev-sp
}