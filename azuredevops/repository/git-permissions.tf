locals {
  git_permission_assignments = concat(
    [for name, assignment in var.permissions : {
      scope      = null
      name       = name
      assignment = assignment
    } if assignment != null],
    flatten([
      for branch_name, branch in var.branches : [
        for name, assignment in branch.permissions : {
          scope      = "refs/heads/${trimprefix(branch_name, "refs/heads/")}"
          name       = name
          assignment = assignment
        } if assignment != null
      ]
    ])
  )

  git_permission_principals = flatten([
    for entry in local.git_permission_assignments : [
      for principal_type, principals in {
        user          = entry.assignment.user_principal_names
        group         = entry.assignment.groups
        descriptor    = entry.assignment.descriptors
        build_service = entry.assignment.build_service_names
        } : [
        for principal in principals : {
          scope          = entry.scope
          name           = entry.name
          principal_type = principal_type
          principal      = principal
          assignment     = entry.assignment
        }
      ]
    ]
  ])

  git_permission_users = toset([
    for entry in local.git_permission_principals : entry.principal
    if entry.principal_type == "user"
  ])
  git_permission_groups = toset([
    for entry in local.git_permission_principals : entry.principal
    if entry.principal_type == "group"
  ])
  git_permission_build_services = toset([
    for entry in local.git_permission_principals : entry.principal
    if entry.principal_type == "build_service"
  ])

  git_permission_group_matches = {
    for name in local.git_permission_groups : name => [
      for group in data.azuredevops_groups.git_permissions[0].groups : group.descriptor
      if group.display_name == name
    ]
  }
  git_permission_build_service_matches = {
    for name in local.git_permission_build_services : name => [
      for user in data.azuredevops_users.git_permission_build_services[0].users : user.descriptor
      if user.display_name == name
    ]
  }

  git_permission_descriptors = {
    user = {
      for name, lookup in data.azuredevops_users.git_permissions :
      name => length(lookup.users) == 1 ? one(lookup.users).descriptor : null
    }
    group = {
      for name, matches in local.git_permission_group_matches :
      name => length(matches) == 1 ? one(matches) : null
    }
    build_service = {
      for name, matches in local.git_permission_build_service_matches :
      name => length(matches) == 1 ? one(matches) : null
    }
  }

  git_permission_resources = {
    for entry in local.git_permission_principals :
    jsonencode([entry.scope, entry.name, entry.principal_type, entry.principal]) => merge(entry, {
      descriptor = entry.principal_type == "descriptor" ? entry.principal : local.git_permission_descriptors[entry.principal_type][entry.principal]
    })
  }

  git_permission_targets = [
    for entry in values(local.git_permission_resources) :
    jsonencode([entry.scope, entry.descriptor])
  ]
}

data "azuredevops_users" "git_permissions" {
  for_each = local.git_permission_users

  principal_name = each.value

  lifecycle {
    postcondition {
      condition     = length(self.users) == 1
      error_message = "Permission principal ${each.value} must match exactly one Azure DevOps user."
    }
  }
}

data "azuredevops_groups" "git_permissions" {
  count = length(local.git_permission_groups) > 0 ? 1 : 0

  project_id = azuredevops_git_repository.this.project_id

  lifecycle {
    postcondition {
      condition = alltrue([
        for name in local.git_permission_groups :
        length([for group in self.groups : group.descriptor if group.display_name == name]) == 1
      ])
      error_message = "Each permission group name must match exactly one group in the repository's project."
    }
  }
}

data "azuredevops_users" "git_permission_build_services" {
  count = length(local.git_permission_build_services) > 0 ? 1 : 0

  subject_types = ["svc"]

  lifecycle {
    postcondition {
      condition = alltrue([
        for name in local.git_permission_build_services :
        length([for user in self.users : user.descriptor if user.display_name == name]) == 1
      ])
      error_message = "Each permission build-service name must match exactly one Azure DevOps svc identity."
    }
  }
}

resource "azuredevops_git_permissions" "this" {
  for_each = local.git_permission_resources

  project_id    = azuredevops_git_repository.this.project_id
  repository_id = azuredevops_git_repository.this.id
  branch_name   = each.value.scope
  principal     = each.value.descriptor
  replace       = each.value.assignment.replace
  permissions   = each.value.assignment.permissions

  depends_on = [azuredevops_git_repository_branch.this]

  lifecycle {
    precondition {
      condition     = length(distinct(local.git_permission_targets)) == length(local.git_permission_targets)
      error_message = "A resolved principal can have only one permission assignment per repository or branch scope, including across different principal selectors."
    }
  }
}
