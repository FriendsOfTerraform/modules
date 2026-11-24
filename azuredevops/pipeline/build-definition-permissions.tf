locals {
  permission_principals = flatten([
    for name, assignment in var.permissions : [
      for principal_type, principals in {
        user          = assignment.user_principal_names
        group         = assignment.groups
        descriptor    = assignment.descriptors
        build_service = assignment.build_service_names
        } : [
        for principal in principals : {
          name           = name
          principal_type = principal_type
          principal      = principal
          assignment     = assignment
        } if principal != null
      ]
    ] if assignment != null
  ])

  permission_users = toset([
    for entry in local.permission_principals : entry.principal if entry.principal_type == "user"
  ])
  permission_groups = toset([
    for entry in local.permission_principals : entry.principal if entry.principal_type == "group"
  ])
  permission_build_services = toset([
    for entry in local.permission_principals : entry.principal if entry.principal_type == "build_service"
  ])

  permission_group_matches = {
    for name in local.permission_groups : name => [
      for group in data.azuredevops_groups.permissions[0].groups : group.descriptor
      if group.display_name == name
    ]
  }
  permission_build_service_matches = {
    for name in local.permission_build_services : name => [
      for user in data.azuredevops_users.permission_build_services[0].users : user.descriptor
      if user.display_name == name
    ]
  }
  permission_descriptors = {
    user = {
      for name, lookup in data.azuredevops_users.permissions :
      name => length(lookup.users) == 1 ? one(lookup.users).descriptor : null
    }
    group = {
      for name, matches in local.permission_group_matches :
      name => length(matches) == 1 ? one(matches) : null
    }
    build_service = {
      for name, matches in local.permission_build_service_matches :
      name => length(matches) == 1 ? one(matches) : null
    }
  }
  permission_resources = {
    for entry in local.permission_principals :
    jsonencode([entry.name, entry.principal_type, entry.principal]) => merge(entry, {
      descriptor = entry.principal_type == "descriptor" ? entry.principal : local.permission_descriptors[entry.principal_type][entry.principal]
    })
  }
  permission_targets = [for entry in values(local.permission_resources) : entry.descriptor]
}

data "azuredevops_users" "permissions" {
  for_each = local.permission_users

  principal_name = each.value

  lifecycle {
    postcondition {
      condition     = length(self.users) == 1
      error_message = "Permission principal ${each.value} must match exactly one Azure DevOps user."
    }
  }
}

data "azuredevops_groups" "permissions" {
  count = length(local.permission_groups) > 0 ? 1 : 0

  project_id = data.azuredevops_project.this.id

  lifecycle {
    postcondition {
      condition = alltrue([
        for name in local.permission_groups :
        length([for group in self.groups : group.descriptor if group.display_name == name]) == 1
      ])
      error_message = "Each permission group name must match exactly one group in the pipeline's project."
    }
  }
}

data "azuredevops_users" "permission_build_services" {
  count = length(local.permission_build_services) > 0 ? 1 : 0

  subject_types = ["svc"]

  lifecycle {
    postcondition {
      condition = alltrue([
        for name in local.permission_build_services :
        length([for user in self.users : user.descriptor if user.display_name == name]) == 1
      ])
      error_message = "Each permission build-service name must match exactly one Azure DevOps svc identity."
    }
  }
}

resource "azuredevops_build_definition_permissions" "this" {
  for_each = local.permission_resources

  project_id          = data.azuredevops_project.this.id
  build_definition_id = azuredevops_build_definition.this.id
  principal           = each.value.descriptor
  replace             = each.value.assignment.replace
  permissions         = each.value.assignment.permissions

  lifecycle {
    precondition {
      condition     = length(distinct(local.permission_targets)) == length(local.permission_targets)
      error_message = "A resolved principal can have only one permission assignment per pipeline, including across different principal selectors."
    }
  }
}
