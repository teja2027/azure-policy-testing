locals {
  # list of management groups appearing in policy assignments for data lookup
  management_group_names = flatten([
    for scope in var.scopes : scope.management_group_name if lookup(scope, "management_group_name", null) != null
  ])

  # list of subscription names appearing in policy assignments for data lookup
  subscription_names = flatten([
    for scope in var.scopes : scope.subscription_name if lookup(scope, "subscription_name", null) != null
  ])

  policy_assignments = flatten([ 
    for scope in var.scopes : [
      for policy_assignment in var.policy_assignments : {
        policy_definition_name         = policy_assignment.policy_definition_name
        managed_identity               = lookup(policy_assignment, "managed_identity", false)
        policy_assignment_name         = lookup(policy_assignment, "policy_assignment_name", null)
        policy_assignment_display_name = lookup(policy_assignment, "policy_assignment_display_name", policy_assignment.policy_definition_name)
        parameters                     = jsonencode(lookup(policy_assignment, "parameters", null))
        policy_type                    = lookup(policy_assignment, "policy_type", "builtin")
        description                    = lookup(policy_assignment, "description", null)
        enforce                        = lookup(policy_assignment, "enforce", true)
        location                       = lookup(policy_assignment, "location", "westeurope")
        management_group_name          = lookup(scope, "management_group_name", null)
        subscription_name              = lookup(scope, "subscription_name", null)
      }
    ]
  ])

  # list of builtin policy definitions appearing in policy assignments
  builtin_policy_definition_names = flatten([
    for policy_assignment in local.policy_assignments : policy_assignment.policy_definition_name if policy_assignment.policy_type == "builtin"
  ])

  mg_builtin_policy_assignments = [for a in local.policy_assignments : a if a.policy_type == "builtin" && lookup(a, "management_group_name", null) != null]
  mg_custom_policy_assignments = [for a in local.policy_assignments : a if a.policy_type == "custom" && lookup (a, "management_group_name", null) != null]
  sub_builtin_policy_assignments = [for a in local.policy_assignments : a if a.policy_type == "builtin" && lookup(a, "subscription_name", null) != null]
  sub_custom_policy_assignments = [for a in local.policy_assignments : a if a.policy_type == "custom" && lookup(a, "subscription_name", null) != null]
}


data "azurerm_management_group" "mg_assignment" {
  for_each     = toset(local.management_group_names)
  display_name = each.key
}

data "azurerm_subscriptions" "subscription_assignment" {
  for_each              = toset(local.subscription_names)
  display_name_contains = each.key
}

data "azurerm_policy_definition" "builtin_policy_definition" {
  for_each     = toset(local.builtin_policy_definition_names)
  display_name = each.key
}

# resource "azurerm_policy_definition" "policy_definiton" {
#   count = var.type == "custom" ? 1 : 0

#   name                = var.name
#   policy_type         = "Custom"
#   mode                = var.mode
#   display_name        = var.display_name
#   description         = var.description
#   management_group_id = data.azurerm_management_group.mg["${var.management_group_name}"].id
#   policy_rule         = var.policy_rule
#   metadata            = var.metadata == tostring(null) ? tostring(null) : jsonencode(var.metadata)
#   parameters          = var.parameters == tostring(null) ? tostring(null) : jsonencode(var.parameters)
# }



#
# Management group scope
#

resource "random_string" "mg_builtin_policy_assignment_names" {
  for_each = toset([for policy_assignment in local.mg_builtin_policy_assignments : "${policy_assignment.policy_assignment_display_name}.${policy_assignment.management_group_name}"])
  length   = 24
  special  = false
}

resource "azurerm_management_group_policy_assignment" "mg_builtin_policy_assignments" {
  for_each = tomap({for policy_assignment in local.mg_builtin_policy_assignments : "${policy_assignment.policy_assignment_display_name}.${policy_assignment.management_group_name}" => policy_assignment})

  management_group_id  = data.azurerm_management_group.mg_assignment["${each.value.management_group_name}"].id
  name                 = each.value.policy_assignment_name != null ? each.value.policy_assignment_name : random_string.mg_builtin_policy_assignment_names[each.key].result
  policy_definition_id = data.azurerm_policy_definition.builtin_policy_definition[each.value.policy_definition_name].id
  description          = each.value.description
  display_name         = each.value.policy_assignment_display_name
  enforce              = each.value.enforce
  parameters           = each.value.parameters == "null" ? null : each.value.parameters
  location             = each.value.location

  dynamic "identity" {
    for_each = length(data.azurerm_policy_definition.builtin_policy_definition[each.value.policy_definition_name].role_definition_ids) > 0 ? ["apply"] : []
    content {
      type = "SystemAssigned"
    }
  }
}

# Creates a list of role assignments that need to be created for this set of policy assignments
locals {
  mg_builtin_policy_assignments_role_assignments = flatten([
    for policy_assignment in local.mg_builtin_policy_assignments : [
      for role_definition_id in data.azurerm_policy_definition.builtin_policy_definition[policy_assignment.policy_definition_name].role_definition_ids : {
        policy_assignment_display_name = policy_assignment.policy_assignment_display_name
        role_definition_id             = role_definition_id
        scope                          = data.azurerm_management_group.mg_assignment[policy_assignment.management_group_name].id
        principal_id                   = azurerm_management_group_policy_assignment.mg_builtin_policy_assignments["${policy_assignment.policy_assignment_display_name}.${policy_assignment.management_group_name}"].identity[0].principal_id
      }
    ]
  ])
}

resource "azurerm_role_assignment" "mg_builtin_policy_assignments_role_assignments" {
  for_each           = tomap({
    for a in local.mg_builtin_policy_assignments_role_assignments: "${a.role_definition_id}.${a.policy_assignment_display_name}.${a.scope}" => a
  })
  scope              = each.value.scope
  principal_id       = each.value.principal_id
  role_definition_id = each.value.role_definition_id
}

#
# Subscription scope
#

resource "random_string" "sub_builtin_policy_assignment_names" {
  for_each = toset([for policy_assignment in local.sub_builtin_policy_assignments : "${policy_assignment.policy_assignment_display_name}.${policy_assignment.subscription_name}"])
  length   = 24
  special  = false
}


resource "azurerm_subscription_policy_assignment" "sub_builtin_policy_assignments" {
  for_each = tomap({for policy_assignment in local.sub_builtin_policy_assignments : "${policy_assignment.policy_assignment_display_name}.${policy_assignment.subscription_name}" => policy_assignment})

  subscription_id      = data.azurerm_subscriptions.subscription_assignment["${each.value.subscription_name}"].subscriptions[0].id
  name                 = each.value.policy_assignment_name != null ? each.value.policy_assignment_name : random_string.sub_builtin_policy_assignment_names[each.key].result
  policy_definition_id = data.azurerm_policy_definition.builtin_policy_definition[each.value.policy_definition_name].id
  description          = each.value.description
  display_name         = each.value.policy_assignment_display_name
  enforce              = each.value.enforce
  parameters           = each.value.parameters == "null" ? null : each.value.parameters
  location             = each.value.location

  dynamic "identity" {
    for_each = length(data.azurerm_policy_definition.builtin_policy_definition[each.value.policy_definition_name].role_definition_ids) > 0 ? ["apply"] : []
    content {
      type = "SystemAssigned"
    }
  }
}

# Creates a list of role assignments that need to be created for this set of policy assignments
locals {
  sub_builtin_policy_assignments_role_assignments = flatten([
    for policy_assignment in local.sub_builtin_policy_assignments : [
      for role_definition_id in data.azurerm_policy_definition.builtin_policy_definition[policy_assignment.policy_definition_name].role_definition_ids : {
        policy_assignment_display_name = policy_assignment.policy_assignment_display_name
        role_definition_id             = role_definition_id
        scope                          = data.azurerm_subscriptions.subscription_assignment[policy_assignment.subscription_name].subscriptions[0].id
        principal_id                   = azurerm_subscription_policy_assignment.sub_builtin_policy_assignments["${policy_assignment.policy_assignment_display_name}.${policy_assignment.subscription_name}"].identity[0].principal_id
      }
    ]
  ])
}

resource "azurerm_role_assignment" "sub_assignment_role_assignments" {
  for_each           = tomap({
    for a in local.sub_builtin_policy_assignments_role_assignments: "${a.role_definition_id}.${a.policy_assignment_display_name}.${a.scope}" => a
  })
  scope              = each.value.scope
  principal_id       = each.value.principal_id
  role_definition_id = "${each.value.scope}${each.value.role_definition_id}"
}