mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000001"
    }
  }
  mock_resource "azuredevops_git_repository" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000002"
    }
  }

  mock_data "azuredevops_users" {
    defaults = {
      users = [
        {
          descriptor     = "svc.build"
          display_name   = "Project Collection Build Service (nethealth)"
          principal_name = "build-service"
        },
        {
          descriptor     = "svc.project"
          display_name   = "permission-tests Build Service (nethealth)"
          principal_name = "project-build-service"
        },
      ]
    }
  }

  mock_data "azuredevops_groups" {
    defaults = {
      groups = [
        { descriptor = "vssgp.readers", display_name = "Readers" },
        { descriptor = "vssgp.contributors", display_name = "Contributors" },
      ]
    }
  }
}

variables {
  name           = "permission-tests"
  project_name   = "permission-tests"
  default_branch = "main"
}

run "empty_assignments" {
  command = plan

  assert {
    condition     = length(azuredevops_git_permissions.this) == 0 && length(data.azuredevops_groups.git_permissions) == 0 && length(data.azuredevops_users.git_permission_build_services) == 0
    error_message = "Empty permissions must create no permission resources or directory enumeration."
  }
}

run "mixed_principals_and_scopes" {
  command = apply

  override_data {
    target = data.azuredevops_users.git_permissions["alice@example.com"]
    values = {
      users = [{ descriptor = "aad.alice", principal_name = "alice@example.com" }]
    }
  }

  override_data {
    target = data.azuredevops_users.git_permissions["bob@example.com"]
    values = {
      users = [{ descriptor = "aad.bob", principal_name = "bob@example.com" }]
    }
  }

  variables {
    permissions = {
      readers = {
        user_principal_names = ["bob@example.com", "alice@example.com", "alice@example.com"]
        groups               = ["Readers", "Contributors"]
        descriptors          = ["svc.explicit", "svc.other"]
        build_service_names  = ["Project Collection Build Service (nethealth)", "permission-tests Build Service (nethealth)"]
        replace              = false
        permissions          = { GenericRead = "Allow", ForcePush = "Deny", CreateTag = "NotSet" }
      }
    }
    branches = {
      "refs/heads/main" = {
        permissions = {
          pipeline = {
            build_service_names = ["Project Collection Build Service (nethealth)"]
            permissions         = { GenericContribute = "Allow" }
          }
        }
      }
      feature = {
        permissions = {
          pipeline = {
            descriptors = ["svc.explicit"]
            permissions = { GenericRead = "Allow" }
          }
        }
      }
      "release/*" = {}
    }
  }

  assert {
    condition     = length(azuredevops_git_permissions.this) == 10
    error_message = "Each unique input principal must create one resource per assignment."
  }

  assert {
    condition = alltrue([
      for entry in local.git_permission_principals :
      contains(keys(azuredevops_git_permissions.this), jsonencode([entry.scope, entry.name, entry.principal_type, entry.principal]))
    ])
    error_message = "Resource addresses must use scope, assignment name, principal type, and principal input, not list indexes."
  }

  assert {
    condition = alltrue([
      for resource in values(azuredevops_git_permissions.this) :
      resource.project_id == data.azuredevops_project.this.id && resource.repository_id == azuredevops_git_repository.this.id &&
      (resource.branch_name == null ? !resource.replace && resource.permissions["ForcePush"] == "Deny" && resource.permissions["CreateTag"] == "NotSet" : resource.replace)
    ])
    error_message = "Repository, branch scope, replace, and all permission values must be forwarded."
  }

  assert {
    condition = (
      azuredevops_git_permissions.this[jsonencode(["refs/heads/main", "pipeline", "build_service", "Project Collection Build Service (nethealth)"])].principal == "svc.build" &&
      azuredevops_git_permissions.this[jsonencode(["refs/heads/feature", "pipeline", "descriptor", "svc.explicit"])].branch_name == "refs/heads/feature" &&
      data.azuredevops_groups.git_permissions[0].project_id == data.azuredevops_project.this.id
    )
    error_message = "Build-service names must resolve to descriptors, branch refs must normalize, and groups must use the repository's project."
  }
}

run "reject_empty_principals" {
  command = plan
  variables {
    permissions = { invalid = { permissions = { GenericRead = "Allow" } } }
  }
  expect_failures = [var.permissions]
}

run "reject_null_assignment" {
  command = plan
  variables {
    permissions = { invalid = null }
  }
  expect_failures = [var.permissions]
}

run "reject_null_permissions" {
  command = plan
  variables {
    permissions = { invalid = { descriptors = ["svc.explicit"], permissions = null } }
  }
  expect_failures = [var.permissions]
}

run "reject_empty_permissions" {
  command = plan
  variables {
    permissions = { invalid = { descriptors = ["svc.explicit"], permissions = {} } }
  }
  expect_failures = [var.permissions]
}

run "reject_invalid_permission" {
  command = plan
  variables {
    permissions = { invalid = { descriptors = ["svc.explicit"], permissions = { GenericRead = "allow" } } }
  }
  expect_failures = [var.permissions]
}

run "reject_blank_principal" {
  command = plan
  variables {
    permissions = { invalid = { descriptors = [" "], permissions = { GenericRead = "Allow" } } }
  }
  expect_failures = [var.permissions]
}

run "reject_wildcard_branch_permissions" {
  command = plan
  variables {
    branches = {
      "release/*" = {
        permissions = { invalid = { descriptors = ["svc.explicit"], permissions = { GenericRead = "Allow" } } }
      }
    }
  }
  expect_failures = [var.branches]
}

run "reject_invalid_branch_assignment" {
  command = plan
  variables {
    branches = {
      main = {
        permissions = { invalid = { descriptors = ["svc.explicit"], permissions = { GenericRead = null } } }
      }
    }
  }
  expect_failures = [var.branches]
}

run "reject_duplicate_resolved_principal" {
  command = plan

  override_data {
    target = data.azuredevops_users.git_permissions["alice@example.com"]
    values = {
      users = [{ descriptor = "aad.alice", principal_name = "alice@example.com" }]
    }
  }

  variables {
    permissions = {
      named = {
        user_principal_names = ["alice@example.com"]
        permissions          = { GenericRead = "Allow" }
      }
      explicit = {
        descriptors = ["aad.alice"]
        permissions = { GenericRead = "Deny" }
      }
    }
  }
  expect_failures = [azuredevops_git_permissions.this]
}

run "reject_missing_build_service" {
  command = plan
  variables {
    permissions = {
      invalid = {
        build_service_names = ["Missing Build Service"]
        permissions         = { GenericRead = "Allow" }
      }
    }
  }
  expect_failures = [data.azuredevops_users.git_permission_build_services]
}

run "reject_ambiguous_build_service" {
  command = plan
  override_data {
    target = data.azuredevops_users.git_permission_build_services[0]
    values = {
      users = [
        { descriptor = "svc.first", display_name = "Duplicate Build Service" },
        { descriptor = "svc.second", display_name = "Duplicate Build Service" },
      ]
    }
  }
  variables {
    permissions = {
      invalid = {
        build_service_names = ["Duplicate Build Service"]
        permissions         = { GenericRead = "Allow" }
      }
    }
  }
  expect_failures = [data.azuredevops_users.git_permission_build_services]
}

run "reject_ambiguous_project_group" {
  command = plan
  override_data {
    target = data.azuredevops_groups.git_permissions[0]
    values = {
      groups = [
        { descriptor = "vssgp.first", display_name = "Readers" },
        { descriptor = "vssgp.second", display_name = "Readers" },
      ]
    }
  }
  variables {
    permissions = {
      invalid = {
        groups      = ["Readers"]
        permissions = { GenericRead = "Allow" }
      }
    }
  }
  expect_failures = [data.azuredevops_groups.git_permissions]
}

run "reject_missing_project_group" {
  command = plan
  variables {
    permissions = {
      invalid = {
        groups      = ["Missing Group"]
        permissions = { GenericRead = "Allow" }
      }
    }
  }
  expect_failures = [data.azuredevops_groups.git_permissions]
}

run "reject_ambiguous_user" {
  command = plan
  override_data {
    target = data.azuredevops_users.git_permissions["alice@example.com"]
    values = {
      users = [
        { descriptor = "aad.first", principal_name = "alice@example.com" },
        { descriptor = "aad.second", principal_name = "alice@example.com" },
      ]
    }
  }
  variables {
    permissions = {
      invalid = {
        user_principal_names = ["alice@example.com"]
        permissions          = { GenericRead = "Allow" }
      }
    }
  }
  expect_failures = [data.azuredevops_users.git_permissions]
}

run "reject_missing_user" {
  command = plan
  override_data {
    target = data.azuredevops_users.git_permissions["alice@example.com"]
    values = { users = [] }
  }
  variables {
    permissions = {
      invalid = {
        user_principal_names = ["alice@example.com"]
        permissions          = { GenericRead = "Allow" }
      }
    }
  }
  expect_failures = [data.azuredevops_users.git_permissions]
}
