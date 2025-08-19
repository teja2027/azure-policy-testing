variable "target_tenant_id" {
    description = "The target tenant ID"
    type        = string
    default     = ""
}

variable "any_subscription_id" {
    description = "Any subscription ID."
    type        = string
    default     = ""
}

variable "policy" {
    description = "An object describing policies and where they will be applied"
    # Type constraint doesn't work because policy file includes multiple policies which can
    # include or have missing optional parameters. Terraform requires all passed in objects 
    # in a list or map to have the identical structure, regardless of "optional"
    # type = list(object({
    #   name               = string
    #   policy_assignments = list(object({
    #     parameters                     = map(object({ value = any }))
    #     policy_assignment_display_name = string
    #     policy_definition_name         = string
    #     description                    = optional(string)
    #     policy_type                    = optional(string)
    #   }))
    #   scopes = list(object({
    #     management_group_name = optional(string) 
    #     subscription_name     = optional(string)
    #     resource_group_name   = optional(string)
    #   }))
    # }))
    # So type any!
    type = any
    default     = []
}