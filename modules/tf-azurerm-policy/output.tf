output "policy_definitions" {
  value = data.azurerm_policy_definition.builtin_policy_definition
}

output "mg_builtin_policy_assignments" {
  value = local.mg_builtin_policy_assignments
}

output "variable-policy_assignments" {
  value = var.policy_assignments
}

output "sub_builtin_policy_assignments_role_assignments" { 
  value = local.sub_builtin_policy_assignments_role_assignments
}