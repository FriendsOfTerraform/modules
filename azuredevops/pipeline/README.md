# Azure DevOps Pipeline Module

Creates an Azure DevOps YAML build definition in an **existing project**, with
optional pipeline variables, variable groups, triggers, and permissions. The
YAML file and its Azure Repos Git repository must already exist.

Report issues and contribute at [FriendsOfTerraform/modules](https://github.com/FriendsOfTerraform/modules).

## Requirements

- Terraform `>= 1.3.0`, as declared in [_versions.tf](_versions.tf).
- The [`microsoft/azuredevops`](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs)
  provider. Pin a compatible version in the calling configuration; this module
  does not constrain the provider version. Mocked tests were run with `1.16.0`.
- An existing project, repository, branch, and YAML file, plus any referenced
  variable groups, upstream pipelines, users, groups, or build-service identities.
- An authenticated provider identity authorized to read those objects and
  manage the pipeline and any configured permissions.

Configure authentication in the calling configuration or environment. For PAT
authentication, the provider supports `AZDO_ORG_SERVICE_URL` and
`AZDO_PERSONAL_ACCESS_TOKEN`; do not commit credentials.

## Examples

### Basic pipeline

This example uses the module from a local checkout. Adjust the relative path
for your configuration.

```hcl
terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "= 1.16.0"
    }
  }
}

provider "azuredevops" {}

module "pipeline" {
  source = "./azuredevops/pipeline"

  name         = "Application CI"
  project_name = "Example Project"
  yaml_source = {
    azure_repo_git = {
      repository = "application"
      branch     = "main"
      path       = "pipelines/ci.yml"
    }
  }
}

output "pipeline_id" {
  value = module.pipeline.pipeline.id
}
```

By default the pipeline is enabled, and no variables, variable groups,
permissions, or explicit trigger blocks are configured.

### Variables, triggers, and permissions

```hcl
module "pipeline" {
  source = "./azuredevops/pipeline"

  name         = "Application CI"
  project_name = "Example Project"
  status       = "enabled"
  yaml_source = {
    azure_repo_git = {
      repository = "application"
      branch     = "main"
      path       = "pipelines/ci.yml"
    }
  }

  variables = {
    pipeline_variables = {
      environment = {
        value          = "production"
        allow_override = false
      }
    }
    variable_groups = ["Shared Settings"]
  }

  triggers = {
    continuous_integration = {
      branch_filters = {
        include = ["main", "release/*"]
        exclude = ["release/experimental/*"]
      }
      path_filters = {
        include = ["src/*"]
        exclude = ["docs/*"]
      }
      batch_changes_while_a_build_is_in_progress = true
    }
    scheduled = {
      weekday = {
        days_to_build = ["Mon", "Tue", "Wed", "Thu", "Fri"]
        start_time    = "1:00PM"
        branch_filters = {
          include = ["main"]
        }
      }
    }
    build_completion = {
      "Upstream Build" = {
        path = "\\Products"
        branch_filters = {
          include = ["main"]
        }
      }
    }
  }

  permissions = {
    readers = {
      groups = ["Readers"]
      permissions = {
        ViewBuilds          = "Allow"
        ViewBuildDefinition = "Allow"
      }
    }
  }
}
```

## Inputs

Full type definitions and validation are in [variables.tf](variables.tf).

| Input | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | Required | Name of the pipeline to create. |
| `project_name` | `string` | Required | Existing project name, resolved to a project ID. |
| `yaml_source` | `object` | Required | YAML repository, branch, and path. Currently only `azure_repo_git` is supported. |
| `status` | `string` | `"enabled"` | Queue status: `enabled`, `disabled`, or `paused`. |
| `variables` | `object` | `null` | Non-secret pipeline variables and existing variable group names. |
| `triggers` | `object` | `null` | CI override, schedules, and build-completion triggers. |
| `permissions` | `map(object)` | `{}` | Named pipeline permission assignments. |

### YAML source

`yaml_source.azure_repo_git` is required. Its `repository`, `branch`, and
`path` fields are required nonblank strings without surrounding whitespace.
The repository is resolved by name within `project_name`. The branch may be a
short name such as `main` or a full `refs/heads/main` ref. Other repository
types are not currently supported.

### Pipeline variables and variable groups

| Field | Default | Description |
|---|---|---|
| `pipeline_variables` | `{}` | Map keyed by variable name. Each entry requires a non-null `value`; an empty value is allowed. |
| `pipeline_variables.<name>.allow_override` | `true` | Whether the value can be overridden when a build is queued. |
| `variable_groups` | `[]` | Names of existing variable groups in the pipeline's project; duplicate names are linked once. |

Pipeline variable values are non-secret and stored in Terraform state. Do not
put sensitive values in `pipeline_variables`. Linking a variable group does not
authorize the pipeline to use a restricted group; authorize it separately in
Azure DevOps.

### Triggers

All three trigger types are optional and can be configured together. Filter
`include` and `exclude` fields default to empty lists. Filter entries must be
nonblank and cannot have surrounding whitespace.

#### Continuous integration

`continuous_integration` defaults to `null`, leaving the provider's CI block
unconfigured. When supplied, it configures a Terraform CI override instead of
`use_yaml`.

| Field | Default | Description |
|---|---|---|
| `branch_filters` | Required | Non-null object with `include` and `exclude` branch patterns. |
| `path_filters` | `{}` | Object with `include` and `exclude` path patterns. An empty path filter is omitted. |
| `batch_changes_while_a_build_is_in_progress` | `false` | Batch changes while a build is running. |
| `enable_continuous_integration` | `true` | When false, replaces branch filters with include and exclude `["*"]` and omits path filters. |

The disable override is intended to exclude all branches but has not been
verified against a live Azure DevOps organization. It does not disable other
trigger types.

#### Scheduled

`scheduled` is a map of schedule keys to objects. Null or an empty map creates
no schedule blocks. Keys determine block order, not Azure DevOps schedule
names; renaming or reordering keys can change list positions. Configured
pipeline schedules override YAML schedules.

| Field | Default | Description |
|---|---|---|
| `days_to_build` | Required | Nonempty list of distinct days: `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat`, `Sun`. |
| `start_time` | Required | Local time: `h:mmAM/PM`, `h:mm AM/PM`, `HH:mm`, or `HHmm`. AM/PM is case-insensitive. |
| `time_zone` | `"(UTC) Coordinated Universal Time"` | Provider-supported time-zone display name. |
| `only_schedule_builds_if_the_source_or_pipeline_has_changed` | `true` | Schedule only when the source or pipeline has changed. |
| `branch_filters` | Required | Non-null object with `include` and `exclude` branch patterns. |

For example, `1:00PM` becomes 13:00; `12:00 AM`, `00:00`, and `0000`
all represent midnight. For time zones, use an exact value accepted by the
[provider](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition).

#### Build completion

`build_completion` maps existing upstream pipeline **names** in `project_name`
to trigger settings. Each entry requires a non-null `branch_filters` object
with `include` and `exclude` lists. `path` defaults to `"\\"`; with that
default the provider searches by name without a path filter. Specify a folder
such as `"\\Products"` to disambiguate a pipeline. The lookup must return
exactly one pipeline. Because names are map keys, two upstream pipelines with
the same name cannot both be configured. Keys determine trigger block order.

### Permissions

`permissions` is a map of named assignments. Each assignment applies the
same permission map to every supplied principal and has these fields:

| Field | Default | Description |
|---|---|---|
| `user_principal_names` | `[]` | Azure DevOps user principal names; each must resolve to one user. |
| `groups` | `[]` | Group display names in the pipeline's project; each must resolve to one group. |
| `descriptors` | `[]` | Explicit graph subject descriptors, not GUIDs or security descriptors. |
| `build_service_names` | `[]` | Build-service display names; each must resolve to one `svc` identity. |
| `replace` | `true` | Replace permissions when true; use provider merge mode when false. |
| `permissions` | Required | Nonempty map of provider build permission names to `Allow`, `Deny`, or `NotSet`. |

Each assignment requires at least one principal. A resolved principal may
appear only once across all assignments. Assignment names and principal inputs
form resource keys; changing either changes the Terraform address. Explicit
descriptors must be known during planning. In merge mode, `NotSet` cannot
clear an existing `Allow` or `Deny`.

The provider documents build-definition permissions for **group principals
only**. Direct user and build-service assignments are undocumented and have
not been verified against a live organization; test them before production
use. See the [provider permission reference](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition_permissions)
for supported permission names and required PAT permissions.

## Outputs

`pipeline` is an object containing:

| Field | Description |
|---|---|
| `name` | Pipeline name. |
| `id` | Build definition ID. |
| `revision` | Build definition revision. |
| `status` | Pipeline queue status. |

## Testing

From this directory, initialize the provider and run:

```shell
terraform init -backend=false
terraform validate
terraform test
```

The tests use mocked providers and require Terraform `>= 1.7`; they do not
exercise a live Azure DevOps organization.
