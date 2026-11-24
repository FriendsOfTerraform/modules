mock_provider "azuredevops" {
  mock_data "azuredevops_project" {
    defaults = { id = "00000000-0000-0000-0000-000000000001" }
  }
  mock_data "azuredevops_git_repository" {
    defaults = { id = "00000000-0000-0000-0000-000000000002" }
  }
  mock_resource "azuredevops_build_definition" {
    defaults = { id = "42" }
  }
  mock_data "azuredevops_groups" {
    defaults = {
      groups = [
        { descriptor = "vssgp.readers", display_name = "Readers" },
        { descriptor = "vssgp.contributors", display_name = "Contributors" },
      ]
    }
  }
  mock_data "azuredevops_users" {
    defaults = {
      users = [{ descriptor = "svc.build", display_name = "Example Build Service", principal_name = "build-service" }]
    }
  }
}

variables {
  name         = "Example Pipeline"
  project_name = "Example Project"
  yaml_source = {
    azure_repo_git = {
      repository = "Example Repository"
      branch     = "main"
      path       = "pipelines/ci.yml"
    }
  }
}

run "permission_defaults" {
  command = plan
  assert {
    condition = (
      length(var.permissions) == 0 &&
      length(azuredevops_build_definition_permissions.this) == 0 &&
      length(data.azuredevops_groups.permissions) == 0 &&
      length(data.azuredevops_users.permissions) == 0 &&
      length(data.azuredevops_users.permission_build_services) == 0
    )
    error_message = "Empty permissions must not create resources or look up principals."
  }
}

run "mixed_principals" {
  command = apply
  override_data {
    target = data.azuredevops_users.permissions["user@example.com"]
    values = { users = [{ descriptor = "aad.user", principal_name = "user@example.com" }] }
  }
  variables {
    permissions = {
      readers = {
        user_principal_names = ["user@example.com"]
        groups               = ["Readers", "Readers"]
        descriptors          = ["vssgp.example"]
        build_service_names  = ["Example Build Service"]
        replace              = false
        permissions          = { ViewBuilds = "Allow", QueueBuilds = "Deny", StopBuilds = "NotSet" }
      }
      defaults = {
        groups      = ["Contributors"]
        permissions = { ViewBuildDefinition = "Allow" }
      }
    }
  }
  assert {
    condition = (
      length(var.permissions.readers.groups) == 1 &&
      var.permissions.readers.replace == false &&
      var.permissions.readers.permissions.StopBuilds == "NotSet" &&
      var.permissions.defaults.replace == true &&
      length(var.permissions.defaults.user_principal_names) == 0 &&
      length(var.permissions.defaults.descriptors) == 0 &&
      length(var.permissions.defaults.build_service_names) == 0
    )
    error_message = "Permission inputs must preserve the repository module's selectors and defaults."
  }
  assert {
    condition = (
      length(azuredevops_build_definition_permissions.this) == 5 &&
      azuredevops_build_definition_permissions.this[jsonencode(["readers", "user", "user@example.com"])].principal == "aad.user" &&
      azuredevops_build_definition_permissions.this[jsonencode(["readers", "group", "Readers"])].principal == "vssgp.readers" &&
      azuredevops_build_definition_permissions.this[jsonencode(["readers", "descriptor", "vssgp.example"])].principal == "vssgp.example" &&
      azuredevops_build_definition_permissions.this[jsonencode(["readers", "build_service", "Example Build Service"])].principal == "svc.build" &&
      azuredevops_build_definition_permissions.this[jsonencode(["defaults", "group", "Contributors"])].replace &&
      data.azuredevops_groups.permissions[0].project_id == data.azuredevops_project.this.id &&
      data.azuredevops_users.permission_build_services[0].subject_types == toset(["svc"]) &&
      alltrue([
        for key, resource in azuredevops_build_definition_permissions.this :
        resource.project_id == data.azuredevops_project.this.id &&
        resource.build_definition_id == azuredevops_build_definition.this.id &&
        (jsondecode(key)[0] == "readers" ? !resource.replace && resource.permissions["QueueBuilds"] == "Deny" && resource.permissions["StopBuilds"] == "NotSet" : true)
      ])
    )
    error_message = "Each distinct principal must resolve and receive the correct pipeline, permissions, and replace setting."
  }
}

run "remove_assignments" {
  command = apply
  variables { permissions = {} }
  assert {
    condition     = length(azuredevops_build_definition_permissions.this) == 0 && length(data.azuredevops_groups.permissions) == 0 && length(data.azuredevops_users.permissions) == 0 && length(data.azuredevops_users.permission_build_services) == 0
    error_message = "Removing assignments must remove permission resources and lookups."
  }
}

run "reject_duplicate_principal" {
  command = plan
  override_data {
    target = data.azuredevops_users.permissions["user@example.com"]
    values = { users = [{ descriptor = "aad.user", principal_name = "user@example.com" }] }
  }
  variables {
    permissions = {
      named    = { user_principal_names = ["user@example.com"], permissions = { ViewBuilds = "Allow" } }
      explicit = { descriptors = ["aad.user"], permissions = { ViewBuilds = "Deny" } }
    }
  }
  expect_failures = [azuredevops_build_definition_permissions.this]
}

run "reject_missing_user" {
  command = plan
  override_data {
    target = data.azuredevops_users.permissions["missing@example.com"]
    values = { users = [] }
  }
  variables { permissions = { missing = { user_principal_names = ["missing@example.com"], permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [data.azuredevops_users.permissions]
}

run "reject_ambiguous_user" {
  command = plan
  override_data {
    target = data.azuredevops_users.permissions["user@example.com"]
    values = { users = [{ descriptor = "aad.one" }, { descriptor = "aad.two" }] }
  }
  variables { permissions = { bad = { user_principal_names = ["user@example.com"], permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [data.azuredevops_users.permissions]
}

run "reject_missing_group" {
  command = plan
  variables { permissions = { bad = { groups = ["Missing"], permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [data.azuredevops_groups.permissions]
}

run "reject_ambiguous_group" {
  command = plan
  override_data {
    target = data.azuredevops_groups.permissions[0]
    values = { groups = [{ descriptor = "vssgp.one", display_name = "Readers" }, { descriptor = "vssgp.two", display_name = "Readers" }] }
  }
  variables { permissions = { bad = { groups = ["Readers"], permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [data.azuredevops_groups.permissions]
}

run "reject_missing_build_service" {
  command = plan
  variables { permissions = { bad = { build_service_names = ["Missing"], permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [data.azuredevops_users.permission_build_services]
}

run "reject_ambiguous_build_service" {
  command = plan
  override_data {
    target = data.azuredevops_users.permission_build_services[0]
    values = { users = [{ descriptor = "svc.one", display_name = "Example Build Service" }, { descriptor = "svc.two", display_name = "Example Build Service" }] }
  }
  variables { permissions = { bad = { build_service_names = ["Example Build Service"], permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [data.azuredevops_users.permission_build_services]
}

run "reject_null_assignment" {
  command = plan
  variables { permissions = { invalid = null } }
  expect_failures = [var.permissions]
}

run "reject_missing_principal" {
  command = plan
  variables { permissions = { invalid = { permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [var.permissions]
}

run "reject_bad_principal" {
  command = plan
  variables { permissions = { invalid = { groups = [" Readers"], permissions = { ViewBuilds = "Allow" } } } }
  expect_failures = [var.permissions]
}

run "reject_null_permissions" {
  command = plan
  variables { permissions = { invalid = { groups = ["Readers"], permissions = null } } }
  expect_failures = [var.permissions]
}

run "reject_empty_permissions" {
  command = plan
  variables { permissions = { invalid = { groups = ["Readers"], permissions = {} } } }
  expect_failures = [var.permissions]
}

run "reject_invalid_permission" {
  command = plan
  variables { permissions = { invalid = { groups = ["Readers"], permissions = { ViewBuilds = "allow" } } } }
  expect_failures = [var.permissions]
}
