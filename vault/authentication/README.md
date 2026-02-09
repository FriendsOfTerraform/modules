# Vault Authentication Module

This module will create and configure a [Vault authentication method][auth-method].

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [AppRole](#approle)
  - [AWS](#aws)
  - [GitHub](#github)
  - [Kubernetes](#kubernetes)
  - [OIDC](#oidc)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)
- [Known Limitations](#known-limitations)
  - [Experimental Options](#experimental-options)

## Example Usage

### AppRole

This example creates an AppRole authentication method and mounts it in the `approle` path. It then creates a role named `awx` that is associated to the `awx` policy. The `role_id` and the `secret_id` will be randomly generated. Currently you can only retrieve the `role_id` and the `secret_id` from the state file.

```terraform
module "approle_auth_method" {
  source = "github.com/FriendsOfTerraform/vault-authentication.git?ref=v0.0.1"

  authentication_method = "approle"
  mount_path            = "approle"

  method_options = {
    default_lease_ttl  = "1h"
    max_lease_ttl      = "12h"
  }

  approle_auth_roles = {
    "awx" = {token_policies = ["awx"]}
  }
}
```

### AWS

The example creates an AWS authentication method and mounts it in the `aws` path, defines the backend credential where Vault will use to validate authentication requests across accounts. Then creates a role named `admin` that is bind to the IAM role `arn:aws:iam::111122223333:role/demo-role`

```terraform
module "aws_auth" {
  source = "github.com/FriendsOfTerraform/vault-authentication.git?ref=v0.0.1"

  authentication_method = "aws"
  mount_path            = "aws"

  method_options = {
    default_lease_ttl = "1h"
    max_lease_ttl     = "12h"
  }

  aws_backend_credential = {
    access_key_id = "AKIA6XXXXXXXXXX"
    secret_access_key = "P+N4XXXXXXXXXXXXXXXXXXXXXX"
  }

  aws_auth_roles = {
    "admin" = {
      sts_role_arn             = "arn:aws:iam::111122223333:role/vault-authentication-role"
      bound_iam_principal_arns = ["arn:aws:iam::111122223333:role/demo-role"]
      token_policies           = ["admin"]
    }
  }
}
```

### GitHub

This example creates a GitHub authentication method and mounts it in the `github` path. It then allow user `petersin0422` to authenticate and associated with the policy `octopus-api-policy`.

```terraform
module "github_auth_method" {
  source = "github.com/FriendsOfTerraform/vault-authentication.git?ref=v0.0.1"

  authentication_method = "github"
  mount_path            = "github"

  method_options = {
    default_lease_ttl  = "1h"
    listing_visibility = "unauth"
    max_lease_ttl      = "12h"
  }

  github_config = {
    organization = "FriendsOfTerraform"
    users = {"petersin0422" = ["octopus-api-policy"]}
  }
}
```

### Kubernetes

This example creates a Kubernetes authentication method and mounts it in the `kubernetes/useast1-sandbox-eks-cluster` path. It then create a role `frontend` that is associated with the policy `webapp-frontend` to grant read access to the database credential.

```terraform
module "kubernetes_auth_method" {
  source = "github.com/FriendsOfTerraform/vault-authentication.git?ref=v0.0.1"

  authentication_method = "kubernetes"
  mount_path = "kubernetes/useast1-sandbox-eks-cluster"

  kubernetes_config = {
    host = "https://1D8D9CE84F575xxxxxxx.gr7.us-east-1.eks.amazonaws.com"
    ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tL...")
    token_reviewer_jwt = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkJOMmw3eFUtVVZYOXRyQmZ1bmVUdW..."
  }

  kubernetes_auth_roles = {
    frontend = {
      bound_service_account_names      = ["frontend"]
      bound_service_account_namespaces = ["webapp"]
      token_policies                   = ["webapp-frontend"]
    }
  }
}

resource "vault_policy" "webapp-frontend" {
  name = "webapp-frontend"

  policy = <<-EOF
    path "kv/secret/data/webapp/database/*" {capabilities = ["read", "list"]}
  EOF
}
```

### OIDC

This example creates an OIDC authentication method and mounts it in the `oidc/azure-ad` path. It then create a role `tech-infra-cloudops` that is associated with the policy `cloudops-users`.

```terraform
module "oidc_auth_method" {
  source = "github.com/FriendsOfTerraform/vault-authentication.git?ref=v0.0.1"

  authentication_method = "oidc"
  mount_path = "oidc/azure-ad"
  description = "Azure AD"

  method_options = {
    listing_visibility = "unauth"
  }

  oidc_config = {
    default_role = "tech-infra-cloudops"
    discovery_url = "https://login.microsoftonline.com/abcdef-1111-2222-abcd-11112222aaaa/v2.0"
    client_id = "8ad6e653-f37e-4a33-80fe-xxxxxxxxxxxx"
    client_secret = "some-secret...."
  }

  oidc_auth_roles = {
    tech-infra-cloudops = {
      user_claim = "email"

      bound_claims = {
        groups = "f427664f-4c51-xxxx-xxxx-xxxx" # Tech-Infra-CloudOps
      }

      oidc_scopes       = ["https://graph.microsoft.com/.default"]
      groups_claim      = "groups"

      allowed_redirect_uris = [
        "https://vault.friendsofterraform.com/ui/vault/auth/${vault_jwt_auth_backend.azure_ad.path}/oidc/callback",
        "http://localhost:8250/oidc/callback"
      ]

      token_policies = ["cloudops-users"]
    }
  }
}
```

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">authentication_method</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Vault authentication method to configure, currently the following values are supported:

- [approle](https://www.vaultproject.io/docs/auth/approle)
- [aws](https://www.vaultproject.io/docs/auth/aws)
- [github](https://www.vaultproject.io/docs/auth/github)
- [kubernetes](https://www.vaultproject.io/docs/auth/kubernetes)
- [oidc](https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers)

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">mount_path</td>
    <td></td>
</tr>
<tr><td colspan="3">

The mount path of the authentication method

**Since:** 0.0.1

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#approleauthroles">ApproleAuthRoles</a>))</code></td>
    <td width="100%">approle_auth_roles</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple AppRole auth roles for this authentication method. Input should be a map of `role_name = role_configuration` format.

```terraform
approle_auth_roles = {
"awx" = {
secret_id_num_uses    = 3
token_max_ttl_seconds = 3600
token_policies        = ["awx"]
token_ttl_seconds     = 600
}
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#awsauthroles">AwsAuthRoles</a>))</code></td>
    <td width="100%">aws_auth_roles</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures an AWS authentication role in `RoleName = {RoleConfig}` format

```terraform
aws_auth_roles = {
"admin" = {
sts_role_arn             = "arn:aws:iam::111122223333:role/vault-authentication-role"
bound_iam_principal_arns = ["arn:aws:iam::111122223333:role/demo-role"]
token_policies           = ["admin"]
}
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#awsbackendcredential">AwsBackendCredential</a>)</code></td>
    <td width="100%">aws_backend_credential</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration of an AWS credential that Vault will use to validate authentication request across accounts. This is required if `authentication_method = aws`

```terraform
aws_backend_credential = {
access_key_id = "AKIA6XXXXXXXXXX"
secret_access_key = "P+N4XXXXXXXXXXXXXXXXXXXXXX"
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>"Managed by Terraform"</code></td>
</tr>
<tr><td colspan="3">

Description of the authentication method

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#githubconfig">GithubConfig</a>)</code></td>
    <td width="100%">github_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration of a GitHub authentication method. This is required if `authentication_method = github`

```terraform
github_config = {
organization = "FriendsOfTerraform"
users = {"petersin0422" = ["octopus-api-policy"]}
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#kubernetesauthroles">KubernetesAuthRoles</a>))</code></td>
    <td width="100%">kubernetes_auth_roles</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple [Kubernetes auth roles][kubernetes-auth-role] for this authentication method. Input should be a map of `role_name = role_configuration` format.

```terraform
kubernetes_auth_roles = {
frontend = {
bound_service_account_names      = ["frontend"]
bound_service_account_namespaces = ["webapp"]
token_policies                   = ["webapp-frontend"]
}
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#kubernetesconfig">KubernetesConfig</a>)</code></td>
    <td width="100%">kubernetes_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration of a Kubernetes authentication method. This is required if `authentication_method = kubernetes`

```terraform
kubernetes_config = {
host = "https://1D8D9CE84F575xxxxxxx.gr7.us-east-1.eks.amazonaws.com"
ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tL...")
token_reviewer_jwt = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkJOMmw3eFUtVVZYOXRyQmZ1bmVUdW..."
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#methodoptions">MethodOptions</a>)</code></td>
    <td width="100%">method_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures common authentication method options

```terraform
method_options = {
default_lease_ttl = "1h"
max_lease_ttl = "12h"
listing_visibility = "unauth"
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#oidcauthroles">OidcAuthRoles</a>))</code></td>
    <td width="100%">oidc_auth_roles</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple OIDC auth roles for this authentication method. Input should be a map of `role_name = role_configuration` format.

```terraform
oidc_auth_roles = {
tech-infra-cloudops = {
user_claim = "email"

bound_claims = {
groups = "f427664f-4c51-xxxx-xxxx-xxxx" # Tech-Infra-CloudOps
}

oidc_scopes       = ["https://graph.microsoft.com/.default"]
groups_claim      = "groups"

allowed_redirect_uris = [
"https://vault.friendsofterraform.com/ui/vault/auth/${vault_jwt_auth_backend.azure_ad.path}/oidc/callback",
"http://localhost:8250/oidc/callback"
]

token_policies = ["cloudops-users"]
}
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#oidcconfig">OidcConfig</a>)</code></td>
    <td width="100%">oidc_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration of an OIDC authentication method. This is required if `authentication_method = oidc`

```terraform
oidc_config = {
default_role = "tech-infra-cloudops"
discovery_url = "https://login.microsoftonline.com/abcdef-1111-2222-abcd-11112222aaaa/v2.0"
client_id = "8ad6e653-f37e-4a33-80fe-xxxxxxxxxxxx"
client_secret = "some-secret...."
}
```

**Since:** 0.0.1

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">mount_path</td>
    <td></td>
</tr>
<tr><td colspan="3">

The mount path of the authentication method

**Since:** 0.0.1

</td></tr>
</tbody></table>

## Objects

#### ApproleAuthRoles

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">secret_id_bound_cidrs</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies blocks of IP addresses which can perform the login operation using this role

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">secret_id_num_uses</td>
    <td></td>
</tr>
<tr><td colspan="3">

The number of times any particular SecretID can be used to fetch a token from this AppRole, after which the SecretID will expire. A value of `0` or `null` will allow unlimited uses.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_max_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's max TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">token_policies</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of Vault policies to be attached to tokens generated by this role

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### AwsAuthRoles

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">sts_role_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The IAM role Vault assume to validate authentication requests to IAM roles in this role

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">bound_iam_principal_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of IAM arns that is allowed to authenticate using this role

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_max_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's max TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">token_policies</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of Vault policies to be attached to tokens generated by this role

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### AwsBackendCredential

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Access key ID of an IAM user

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">secret_access_key</td>
    <td></td>
</tr>
<tr><td colspan="3">

Secret access key of an IAM user

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### GithubConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">organization</td>
    <td></td>
</tr>
<tr><td colspan="3">

The GitHub organization

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(list(string))</code></td>
    <td width="100%">teams</td>
    <td></td>
</tr>
<tr><td colspan="3">

A map of GitHub teams (**team name must be slugified**) to be allowed to authenticate using this authentication endpoint and a list of policies associated to the team, in the `team_name = [policies]` format. ex: `{my-team = ["policy-1", "policy-2"]}`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(list(string))</code></td>
    <td width="100%">users</td>
    <td></td>
</tr>
<tr><td colspan="3">

A map of GitHub users to be allowed to authenticate using this authentication endpoint and a list of policies associated to the users, in the `username = [policies]` format. ex: `{petersin = ["policy-1", "policy-2"]}`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### KubernetesAuthRoles

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">bound_service_account_names</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of Kubernetes service account names that is permitted to authenticate using this role

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">bound_service_account_namespaces</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of Kubernetes namespaces that is permitted to authenticate using this role

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_max_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's max TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">token_policies</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of Vault policies to be attached to tokens generated by this role

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### KubernetesConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">host</td>
    <td></td>
</tr>
<tr><td colspan="3">

The URL of the Kubernetes API server. Must be `https://`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ca_certificate</td>
    <td></td>
</tr>
<tr><td colspan="3">

The CA certificate Vault will use to connect to the Kubernetes API server. Most providers (like AWS) returns this value in base64 encoded string, make sure the decoded value is passed in.

**Examples:**

- [Kubernetes](#kubernetes)

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">token_reviewer_jwt</td>
    <td></td>
</tr>
<tr><td colspan="3">

A Kubernetes service account JWT token that allow Vault to validate incoming authentication request with Kubernetes. Please refer to [this doc][kube-reviewer-jwt] for more information.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">issuer</td>
    <td></td>
</tr>
<tr><td colspan="3">

The issuer of the `token_reviewer_jwt` token. Please refer to [this doc][kube-issuer] for more information.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### MethodOptions

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">default_lease_ttl</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the default token time-to-live. If set, this overrides the global default. Must be a [valid duration string][duration-string]

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">max_lease_ttl</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the maximum token time-to-live. If set, this overrides the global default. Must be a [valid duration string][duration-string]

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">listing_visibility</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies whether to show this mount in the UI-specific listing endpoint.

- unauth - Show this auth method in the web UI
- hidden - Do not show this auth method in the web UI

**Allowed Values:**

- `unauth`
- `hidden`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### OidcAuthRoles

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">user_claim</td>
    <td></td>
</tr>
<tr><td colspan="3">

The claim to use to uniquely identify the user

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">bound_claims</td>
    <td></td>
</tr>
<tr><td colspan="3">

A map of claims that restrict only the identity that has matching claims in its token. For example, `this identity must be in groups = <group_id>`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">groups_claim</td>
    <td></td>
</tr>
<tr><td colspan="3">

The claim to use to uniquely identify the set of groups to which the user belongs

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">oidc_scopes</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of OIDC scopes to be used with an OIDC role

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">allowed_redirect_uris</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of redirect URIs where authentication responses can be redirected back to the caller

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">token_max_ttl_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the token's max TTL (time-to-live) in seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">token_policies</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of Vault policies to be attached to tokens generated by this role

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### OidcConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">default_role</td>
    <td></td>
</tr>
<tr><td colspan="3">

The default role to use if none is provided during login

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">discovery_url</td>
    <td></td>
</tr>
<tr><td colspan="3">

The OIDC Discovery URL, without any .well-known component (base path).

**Examples:**

- [OIDC](#oidc)

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">client_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Client ID used for OIDC backends

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">client_secret</td>
    <td></td>
</tr>
<tr><td colspan="3">

Client Secret used for OIDC backends

**Since:** 0.0.1

</td></tr>
</tbody></table>

[duration-string]: https://pkg.go.dev/time#ParseDuration
[kube-issuer]: https://www.vaultproject.io/docs/auth/kubernetes#discovering-the-service-account-issuer
[kube-reviewer-jwt]: https://www.vaultproject.io/docs/auth/kubernetes#configuring-kubernetes
[kubernetes-auth-role]: https://www.vaultproject.io/docs/auth/kubernetes#configuration

<!-- TFDOCS_EXTRAS_END -->

## Known Limitations

### Experimental Options

This module enabled the following Terraform experimental features, a warning is expected and can be safely ignored.

- [Optional Object Type Attributes](https://www.terraform.io/docs/language/expressions/type-constraints.html#experimental-optional-object-type-attributes)

[auth-method]: https://www.vaultproject.io/docs/auth
