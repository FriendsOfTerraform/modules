# Repository module unit tests

These tests use Terraform's mocked Azure DevOps provider. They never contact an
Azure DevOps organization, require no PAT, and create no real resources.
Mocked `apply` runs let assertions inspect computed values; they are not live
integration tests and do not verify Azure DevOps API behavior.

## Running

Use Terraform 1.7 or newer for provider mocking. The suite was verified with
Terraform 1.13.4 and `microsoft/azuredevops` 1.16.0; provider 1.16.0's write-only
import password requires Terraform 1.11 or newer.

From the repository root:

```powershell
terraform -chdir=azuredevops\repository init -backend=false
terraform -chdir=azuredevops\repository validate
terraform -chdir=azuredevops\repository test
```

Initialization downloads the provider but does not authenticate to Azure DevOps.

## Coverage

- [repository-policy.tftest.hcl](repository-policy.tftest.hcl): all six
  repository policies, unmanaged defaults, disabled boolean policies,
  repository-only scope, ordered patterns, limits, and invalid inputs.
- [repository.tftest.hcl](repository.tftest.hcl): project lookup, clean/import/fork
  initialization, repository settings, branch-name normalization, source
  branch/commit/tag routing, default/wildcard exclusions, empty resource maps,
  and the created-branches output shape and values.
- [branch-policies.tftest.hcl](branch-policies.tftest.hcl): exact and prefix
  instances of all six branch-policy resource types, setting mappings, blocking
  requirements, reviewer identity/storage-key lookups, named-policy addresses,
  vote modes, build triggers, expiration conversions and limits, and validation.
- [git-permissions.tftest.hcl](git-permissions.tftest.hcl): repository and branch
  permissions for mixed user/group/descriptor/build-service inputs, stable
  addresses, lookup ambiguity/missing results, duplicate resolved principals,
  and input validation.

The provider's import password is write-only. Tests assert it is absent from
mocked state rather than trying to read it back.
