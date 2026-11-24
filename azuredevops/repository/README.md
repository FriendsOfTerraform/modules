# Azure DevOps Repository Module

Creates an Azure DevOps Git repository in an **existing project**, with optional
branches, repository policies, branch policies, and Git permissions.

Report issues and contribute at [FriendsOfTerraform/modules](https://github.com/FriendsOfTerraform/modules).

## Contents

- [Requirements](#requirements)
- [Examples](#examples)
- [Inputs](#inputs)
- [Repository initialization](#repository-initialization)
- [Repository policies](#repository-policies)
- [Branches and branch policies](#branches-and-branch-policies)
- [Git permissions](#git-permissions)
- [Outputs](#outputs)
- [Testing](#testing)

## Requirements

- Terraform `>= 1.3.0`, as declared in [_versions.tf](_versions.tf).
- The [`microsoft/azuredevops`](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs) provider.
  Choose and pin a compatible version in your root configuration; this module
  does not constrain the provider version. Tests were verified with `1.16.0`.
- An existing Azure DevOps project and a provider identity authorized to read
  that project and manage the requested repositories, policies, and permissions.
- Existing pipelines, users, groups, and service connections referenced by inputs.

Provider `1.16.0` uses a write-only import password, requiring Terraform `>= 1.11`.
Mocked tests require Terraform `>= 1.7`; the verified combination is Terraform
`1.13.4` and provider `1.16.0`.

Configure authentication in the calling configuration or environment. For PAT
authentication, the provider supports `AZDO_ORG_SERVICE_URL` and
`AZDO_PERSONAL_ACCESS_TOKEN`. Do not commit tokens or import credentials.

## Examples

### Basic repository

The examples use the GitHub module source pinned to `v1.0.0`.

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

module "repository" {
  source = "github.com/FriendsOfTerraform/azuredevops-repository.git?ref=v1.0.0"

  name           = "application"
  project_name   = "Example Project"
  default_branch = "main"
}
```

This initializes a clean repository with `refs/heads/main`. No additional branch
resources, policies, or permission assignments are created.

### Repository and branch controls

```hcl
module "repository" {
  source = "github.com/FriendsOfTerraform/azuredevops-repository.git?ref=v1.0.0"

  name           = "application"
  project_name   = "Example Project"
  default_branch = "main"

  policy = {
    commit_author_email_validation = ["*@example.com", "!blocked@example.com"]
    file_path_validation           = ["*.exe", "!/approved/*.exe"]
    case_enforcement               = true
    reserved_names                 = true
    maximum_path_length            = 260
    maximum_file_size              = 10
  }

  permissions = {
    readers = {
      groups      = ["Readers"]
      permissions = { GenericRead = "Allow" }
    }
  }

  branches = {
    main = {
      policy = {
        check_for_comment_resolution = "required"
        check_for_lined_work_items   = "required"
        allowed_merge_types = {
          basic_no_fast_forward   = false
          rebase_and_fast_forward = false
          rebase_and_merge_commit = false
          squash                  = true
        }
        require_a_minimum_number_of_reviewers = {
          minimum_number_of_reviewers = 2
          when_new_changes_are_pushed = "reset_all_votes"
        }
      }

      build_validations = {
        ci = {
          build_pipeline_name = "Application CI"
          build_expires_after = "immediately"
          path_filters        = ["/src/*"]
          trigger             = "automatic"
          policy_requirement  = "required"
        }
      }

      automatically_included_reviewers = {
        application_team = {
          users                 = ["reviewer@example.com"]
          groups                = ["Application Reviewers"]
          activity_feed_message = "Please review application changes."
        }
      }
    }

    develop = {
      based_on = "main"
      permissions = {
        developers = {
          groups = ["Contributors"]
          permissions = {
            GenericRead       = "Allow"
            GenericContribute = "Allow"
          }
        }
      }
    }

    "release/*" = {
      policy = {
        check_for_comment_resolution = "required"
        require_a_minimum_number_of_reviewers = {
          minimum_number_of_reviewers = 2
        }
      }
    }
  }
}
```

The `main` entry configures policies without creating another default branch.
`develop` is created from `main`. `release/*` configures prefix policies for
`refs/heads/release/`; it does not create a branch named `release/*`.

## Inputs

Full types, field documentation, and validation are in [variables.tf](variables.tf).

| Input | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | Required | Name of the Git repository to create. |
| `project_name` | `string` | Required | Name of its existing Azure DevOps project. |
| `default_branch` | `string` | Required | Nonblank short branch name or full `refs/heads/` ref. |
| `enabled` | `bool` | `true` | Enables the repository; false disables it, not its individual policies. |
| `import` | `object` | `null` | Import settings described below. |
| `fork` | `object` | `null` | Fork settings described below. |
| `policy` | `object` | `{}` | Repository-level policies. |
| `permissions` | `map(object)` | `{}` | Named repository-wide Git permission assignments. |
| `branches` | `map(object)` | `{}` | Branch creation, branch policies, and branch permissions. |

## Repository initialization

Initialization selects `Import` when `import` is supplied, otherwise `Fork` when
`fork` is supplied, otherwise `Clean`. This module does not use `Uninitialized`.
Avoid supplying both import and fork; import initialization takes precedence,
while the supplied fork parent is still passed to the repository resource.

### Import

| Field | Required | Description |
|---|---|---|
| `source_repo_url` | Yes | Source Git repository URL. |
| `service_connection_id` | No | Existing connection for import authentication; conflicts with username/password. |
| `username` | No | Source credential username; conflicts with a service connection. |
| `password` | No | Source password/token; conflicts with a service connection. Provider 1.16.0 treats it as write-only. |

```hcl
import = {
  source_repo_url       = "https://example.com/source.git"
  service_connection_id = "00000000-0000-0000-0000-000000000001"
}
```

### Fork

```hcl
fork = {
  parent_repository_id = "00000000-0000-0000-0000-000000000002"
}
```

`parent_repository_id` is required inside the fork object. For imports and forks,
`default_branch` must exist in the source repository. Clean initialization creates
the configured default branch. Short names are normalized to full refs.

## Repository policies

All fields default to `null`, which creates no policy resource. Each configured
policy is **blocking** and scoped only to the managed repository, not the project.
Configured pattern/numeric policies are enabled. Boolean policies use true to
enable, false to create a disabled policy, and null to leave them unmanaged.

| Field | Type | Behavior |
|---|---|---|
| `commit_author_email_validation` | `list(string)` | Allowed author-email patterns; nonempty list of nonblank strings. |
| `file_path_validation` | `list(string)` | Blocked file-path patterns; nonempty list of nonblank strings. Exact paths start with `/`. |
| `case_enforcement` | `bool` | Prevent case-sensitivity conflicts in names. |
| `reserved_names` | `bool` | Block platform-reserved names and incompatible characters. |
| `maximum_path_length` | `number` | Whole number from `1` to `10000` characters. |
| `maximum_file_size` | `number` | `1`, `2`, `5`, `10`, `50`, `100`, or `200` MB. |

Email and path patterns support wildcards and `!` exclusions. Order matters and
is preserved. Repository settings do not remove or override all inherited project
controls; effective behavior also depends on Azure DevOps policy precedence.

## Branches and branch policies

`branches` is keyed by a short branch name or a full `refs/heads/` ref. Do not list
the same branch in both forms.

- The default branch is not created through a separate branch resource.
- Keys ending in `*` are policy prefixes, not branches to create.
- Prefix policy refs remove the final `*`: `release/*` becomes `refs/heads/release/`.
- Other entries create branch resources and appear in the `branches` output.
- Permission assignments require exact branch keys without `*`.
- Every branch entry creates a merge-types policy allowing all strategies by
  default, even when its branch `policy` object is omitted.

### Branch source: `based_on`

| Input | Source |
|---|---|
| Omitted or null | Repository default branch. |
| Short name matching a branch entry or the default branch | That branch. |
| Full `refs/heads/` ref | That branch, including an existing branch outside the input map. |
| Full 40-character hexadecimal SHA-1 | Commit, passed unchanged. |
| Any other string | Tag, including strings that resemble short commit IDs. |

Named source branches must exist when Azure DevOps processes branch creation.
The module does not establish per-branch creation ordering for dependencies
between newly created branches; prefer an existing source such as the default
branch when provisioning multiple branches together.

### Branch `policy`

| Field | Default | Description |
|---|---|---|
| `check_for_comment_resolution` | `null` | `required` creates a blocking policy; `optional` a nonblocking policy. |
| `check_for_lined_work_items` | `null` | Same values for linked-work-item enforcement. The existing input spelling is preserved. |
| `allowed_merge_types` | `{}` | Strategy flags below, all defaulting to true. |
| `require_a_minimum_number_of_reviewers` | `null` | Minimum-reviewer settings below; null creates no policy. |

`allowed_merge_types` has four optional booleans:
`basic_no_fast_forward`, `rebase_and_fast_forward`, `rebase_and_merge_commit`,
and `squash`. Set a flag to false to disallow that strategy.

Minimum-reviewer fields:

| Field | Default | Description |
|---|---|---|
| `minimum_number_of_reviewers` | Required | Required approving reviewer count. |
| `allow_requestors_to_approve_their_own_changes` | `false` | Count the PR author's approval. |
| `prohibit_the_most_recent_pusher_from_approving_their_own_changes` | `false` | Exclude the latest pusher's approval. |
| `allow_completion_even_if_some_reviewers_vote_to_wait_or_reject` | `false` | Allow completion despite wait/reject votes. |
| `when_new_changes_are_pushed` | `null` | Vote mode below; null leaves reset/iteration flags unset. |

Supported vote modes:

- `require_vote_on_each_iteration`
- `require_vote_on_last_iteration`
- `reset_all_approval_votes`
- `reset_all_votes` (also resets approvals)

### Build validations

`build_validations` is a map of named policies. Pipelines are looked up by name
in the project's root folder.

| Field | Default | Description |
|---|---|---|
| `build_pipeline_name` | `null` | Existing pipeline name; null uses the validation map key. |
| `build_expires_after` | `null` | Expiration described below. |
| `enabled` | `true` | Whether this policy is enabled. |
| `path_filters` | `null` | Provider filename patterns selecting applicable changes. |
| `policy_requirement` | `"required"` | `required` blocks completion; `optional` does not. |
| `trigger` | `"automatic"` | `automatic` queues validation automatically; `manual` requires manual queuing. |

Expiration on **target-branch updates**:

- `"immediately"`: expire immediately.
- Null or `"0"`: never expire due to target updates.
- A non-negative whole number, optionally with a unit: expire after that duration.

A bare number is in minutes. Units accept singular/plural `second`, `minute`,
`hour`, `day`, `week`, `month`, and `year`. Seconds must be a multiple of 60;
months are 30 days and years are 365 days. Examples: `"120 seconds"`, `"30"`,
`"2 hours"`, and `"1 day"`.

Source updates invalidate previous builds. Manual positive durations must not
exceed `527040` minutes (366 days). Trigger mode and target-update expiration
are independent settings.

Build-policy resource keys currently combine branch and validation names with
`_`. Avoid combinations that produce the same combined key.

### Automatically included reviewers

`automatically_included_reviewers` is a map of named policies. At least one user
or group is required in each policy; identical reviewer lists under different
policy names are allowed.

| Field | Default | Description |
|---|---|---|
| `users` | `[]` | Azure DevOps principal names, which may differ from email addresses. Each lookup must return exactly one user. |
| `groups` | `[]` | Group names within this repository's project. |
| `enabled` | `true` | Whether the policy is enabled. |
| `policy_requirement` | `"required"` | `required` blocks completion; `optional` does not. |
| `path_filters` | `null` | Paths controlling when reviewers are included. |
| `allow_requestors_to_approve_their_own_changes` | `true` | Whether the requester can satisfy their own reviewer vote. |
| `activity_feed_message` | `null` | Message when reviewers are included. |

Graph descriptors are resolved and converted to storage-key GUIDs for reviewer
IDs. Reviewer policy addresses use JSON-encoded branch/policy-name tuples, not
list indexes. Renaming either key changes the Terraform address; reordering map
entries does not.

## Git permissions

The root `permissions` map applies repository-wide. A branch's `permissions` map
uses the same structure and takes its scope from the branch key; no separate
`branch_name` input is needed.

| Field | Default | Description |
|---|---|---|
| `user_principal_names` | `[]` | Set of user principal names; each must resolve uniquely. |
| `groups` | `[]` | Set of display names resolving uniquely within the repository's project. |
| `descriptors` | `[]` | Set of explicit graph subject descriptors, not GUIDs or security descriptors. |
| `build_service_names` | `[]` | Set of display names resolving uniquely among `svc` identities. |
| `replace` | `true` | Provider replacement mode; false uses merge mode. |
| `permissions` | Required | Nonempty map of Git permission names to `Allow`, `Deny`, or `NotSet`. |

Each assignment needs at least one principal across the four sets. Multiple
principal types can share an assignment. One permission resource is created per
principal. Name and principal inputs must be nonblank without surrounding
whitespace.

```hcl
permissions = {
  pipeline_access = {
    build_service_names = ["Project Collection Build Service (example-org)"]
    permissions = {
      GenericRead       = "Allow"
      GenericContribute = "Allow"
    }
  }
}
```

Important considerations:

- Direct user/build-service assignments are undocumented by the provider's
  group-only resource guidance and have not been verified against a live
  organization. Mocked tests verify module wiring, not API support. Test the
  full lifecycle before production use; a dedicated project group is the
  documented alternative.
- Build-service identities are not Microsoft Entra application service principals.
  Check pipeline authorization scope: collection-scoped pipelines use
  `Project Collection Build Service (org)`, while project-scoped pipelines use
  `<project> Build Service (org)`. The project identity may require a first
  pipeline run before it exists.
- Display names are not unique. Permission group and build-service lookups
  reject zero or multiple matches.
- Explicit descriptors must be known at plan time because they form resource keys.
- Sets avoid list-index churn. Addresses use JSON-encoded scope, assignment name,
  principal type, and principal input; changing those values changes addresses.
- The same resolved principal cannot have multiple assignments at the same scope,
  even through different selectors. Repository and branch scopes are distinct.
- In merge mode, `NotSet` cannot clear existing `Allow`/`Deny` permissions.
- Effective permissions also depend on inheritance and denies. Grant only the
  permissions needed by the user, group, or pipeline.

## Outputs

| Output | Description |
|---|---|
| `repository` | Object containing `name`, `default_branch`, `id`, `is_fork`, `remote_url`, `ssh_url`, `url`, and `web_url`. |
| `branches` | Map of created branch resources, preserving original input keys, with `id` and `last_commit_id`. |

```hcl
branches = {
  develop = {
    id             = "<repository-id>:develop"
    last_commit_id = "<commit-id>"
  }
}
```

The branch ID is a provider composite ID, not a standalone GUID. Default-branch
and wildcard entries are excluded. With no additional branches, the output is
`{}`. Commit IDs reflect the branch state read by Terraform, not a continuous
live query.

## Testing

From the repository root:

```powershell
terraform -chdir=azuredevops\repository init -backend=false
terraform -chdir=azuredevops\repository validate
terraform -chdir=azuredevops\repository test
```

Tests mock the provider: they require no Azure DevOps PAT, make no organization
API calls, and create no real resources. Initialization still downloads the
provider. See [tests/README.md](tests/README.md) for coverage and version details.
