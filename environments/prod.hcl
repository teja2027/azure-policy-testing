locals {
    environment                       = "prod"
    target_tenant_id                  = "9edd149e-210e-4a5e-b6ae-2e265a4c5a41" # mytmsw.onmicrosoft.com
    subscription_id                   = "cc487dcd-5ce6-4504-a0fd-10d50e80f2b8" # tms-cf-automation-prod-sub
    lead_tenant_id                    = "585bda71-88ce-428b-9832-95eaa3dce989" # havi.com
    lead_any_subscription_id          = "5153108b-4386-4414-84f1-1892d37bbee9" # HAVI Cloud Cost Management
    billing_account_name              = "f61e4950-4d58-4e1f-9538-df0ab264f2da:f04fb2fc-b21b-41e9-b717-63d9c363b88f_2019-05-31"
    billing_profile_name              = "HQI6-RYEW-BG7-PGB" # HAVI tms
    invoice_section_name              = "7C7J-4ZRF-PJA-PGB" # HAVI tms
    tf_secrets_vault_name             = "tmscftmtnprdkv"
    tf_state_container_name           = "tfstate"
    tf_state_resource_group_name      = "tms-cf-automation-prod-tf-rg"
    tf_state_storage_account_name     = "tmscftmtnprdsa"
    tf_state_subscription_id          = "cc487dcd-5ce6-4504-a0fd-10d50e80f2b8"
    tf_state_tenant_id                = "9edd149e-210e-4a5e-b6ae-2e265a4c5a41"
    tf_secrets_arm_client_id_name     = "arm-client-id"
    tf_secrets_arm_client_secret_name = "arm-client-secret"
    new_subscription_owner_id         = "8474c1e0-9696-489c-87f8-e83234a26c35"
}