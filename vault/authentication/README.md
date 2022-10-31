# Vault Authentication Module

This module will create and configure a [Vault authentication method][auth-method].

## Table of Contents

- [Example Usage](#example-usage)
    - [AppRole](#approle)
    - [AWS](#aws)
    - [GitHub](#github)
    - [Kubernetes](#kubernetes)
    - [OIDC](#oidc)
- [Argument Reference](#argument-reference)
- [Outputs](#outputs)
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

## Argument Reference

- (string) **`authentication_method`** _[since v0.0.1]_

    The Vault authentication method to configure, currently the following values are supported:
    - [approle](https://www.vaultproject.io/docs/auth/approle)
    - [aws](https://www.vaultproject.io/docs/auth/aws)
    - [github](https://www.vaultproject.io/docs/auth/github)
    - [kubernetes](https://www.vaultproject.io/docs/auth/kubernetes)
    - [oidc](https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers)

- (string) **`mount_path`** _[since v0.0.1]_

    The mount path of the authentication method

- (string) **`description = "Managed by Terraform"`** _[since v0.0.1]_

    Description of the authentication method

- (map(object)) **`approle_auth_roles = {}`** _[since v0.0.1]_

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

    - (list(string)) **`token_policies`** _[since v0.0.1]_
    
        A list of Vault policies to be attached to tokens generated by this role
    
    - (list(string)) **`secret_id_bound_cidrs = null`** _[since v0.0.1]_

        Specifies blocks of IP addresses which can perform the login operation using this role

    - (number) **`secret_id_num_uses = null`** _[since v0.0.1]_

        The number of times any particular SecretID can be used to fetch a token from this AppRole, after which the SecretID will expire. A value of `0` or `null` will allow unlimited uses.
    
    - (number) **`token_max_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's max TTL (time-to-live) in seconds

    - (number) **`token_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's TTL (time-to-live) in seconds

- (object) **`aws_auth_roles = {}`** _[since v0.0.1]_

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
    
    - (string) **`sts_role_arn`** _[since v0.0.1]_

        The IAM role Vault assume to validate authentication requests to IAM roles in this role

    - (list(string)) **`bound_iam_principal_arns = null`** _[since v0.0.1]_

        List of IAM arns that is allowed to authenticate using this role

    - (list(string)) **`token_policies`** _[since v0.0.1]_
    
        A list of Vault policies to be attached to tokens generated by this role

    - (number) **`token_max_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's max TTL (time-to-live) in seconds

    - (number) **`token_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's TTL (time-to-live) in seconds


- (object) **`aws_backend_credential = null`** _[since v0.0.1]_

    Configuration of an AWS credential that Vault will use to validate authentication request across accounts. This is required if `authentication_method = aws`
    
    ```terraform
    aws_backend_credential = {
      access_key_id = "AKIA6XXXXXXXXXX"
      secret_access_key = "P+N4XXXXXXXXXXXXXXXXXXXXXX"
    }
    ```
    
    - (string) **`access_key_id`** _[since v0.0.1]_

        Access key ID of an IAM user

    - (string) **`secret_access_key`** _[since v0.0.1]_

        Secret access key of an IAM user

- (object) **`github_config = null`** _[since v0.0.1]_

    Configuration of a GitHub authentication method. This is required if `authentication_method = github`
    
    ```terraform
    github_config = {
      organization = "FriendsOfTerraform"
      users = {"petersin0422" = ["octopus-api-policy"]}
    }
    ```
    
    - (string) **`organization`** _[since v0.0.1]_

        The GitHub organization
    
    - (map(list(string))) **`teams = null`** _[since v0.0.1]_
    
        A map of GitHub teams (**team name must be slugified**) to be allowed to authenticate using this authentication endpoint and a list of policies associated to the team, in the `team_name = [policies]` format. ex: `{my-team = ["policy-1", "policy-2"]}`
    
    - (map(list(string))) **`users = null`** _[since v0.0.1]_
    
        A map of GitHub users to be allowed to authenticate using this authentication endpoint and a list of policies associated to the users, in the `username = [policies]` format. ex: `{petersin = ["policy-1", "policy-2"]}`

- (map(object)) **`kubernetes_auth_roles = {}`** _[since v0.0.1]_

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
    
    - (list(string)) **`token_policies`** _[since v0.0.1]_
    
        A list of Vault policies to be attached to tokens generated by this role

    - (list(string)) **`bound_service_account_names = null`** _[since v0.0.1]_

        A list of Kubernetes service account names that is permited to authenticate using this role

    - (list(string)) **`bound_service_account_namespaces = null`** _[since v0.0.1]_

        A list of Kubernetes namespaces that is permited to authenticate using this role
    
    - (number) **`token_max_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's max TTL (time-to-live) in seconds

    - (number) **`token_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's TTL (time-to-live) in seconds

- (object) **`kubernetes_config = null`** _[since v0.0.1]_

    Configuration of a Kubernetes authentication method. This is required if `authentication_method = kubernetes`
    
    ```terraform
    kubernetes_config = {
      host = "https://1D8D9CE84F575xxxxxxx.gr7.us-east-1.eks.amazonaws.com"
      ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tL...")
      token_reviewer_jwt = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkJOMmw3eFUtVVZYOXRyQmZ1bmVUdW..."
    }
    ```
    
    - (string) **`ca_certificate`** _[since v0.0.1]_

        The CA certificate Vault will use to connect to the Kubernetes API server. Most providers (like AWS) returns this value in base64 encoded string, make sure the decoded value is passed in. [See example](#kubernetes)
    
    - (string) **`host`** _[since v0.0.1]_
    
        The URL of the Kubernetes API server. Must be `https://`

    - (string) **`token_reviewer_jwt`** _[since v0.0.1]_
    
        A Kubernetes service account JWT token that allow Vault to validate incoming authentication request with Kubernetes. Please refer to [this doc][kube-reviewer-jwt] for more information.

    - (string) **`issuer = "kubernetes/serviceaccount"`** _[since v0.0.1]_
    
        The issuer of the `token_reviewer_jwt` token. Please refer to [this doc][kube-issuer] for more information.

- (object) **`method_options = null`** _[since v0.0.1]_

    Configures common authentication method options
    
    ```terraform
    method_options = {
      default_lease_ttl = "1h"
      max_lease_ttl = "12h"
      listing_visibility = "unauth"
    }
    ```
    
    - (string) **`default_lease_ttl = null`** _[since v0.0.1]_

        Specifies the default token time-to-live. If set, this overrides the global default. Must be a [valid duration string][duration-string]
    
    - (string) **`listing_visibility = null`** _[since v0.0.1]_
    
        Specifies whether to show this mount in the UI-specific listing endpoint. Valid values are: 
        - unauth - Show this auth method in the web UI 
        - hidden - Do not show this auth method in the web UI
    
    - (string) **`max_lease_ttl = null`** _[since v0.0.1]_
    
        Specifies the maximum token time-to-live. If set, this overrides the global default. Must be a [valid duration string][duration-string]

- (map(object)) **`oidc_auth_roles = {}`** _[since v0.0.1]_

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

    - (list(string)) **`token_policies`** _[since v0.0.1]_
    
        A list of Vault policies to be attached to tokens generated by this role

    - (list(string)) **`allowed_redirect_uris = null`** _[since v0.0.1]_

        A list of redirect URIs where authentication responses can be redirected back to the caller

    - (map(string)) **`bound_claims = null`** _[since v0.0.1]_

        A map of claims that restrict only the identity that has matching claims in its token. For example, `this identity must be in groups = <group_id>`

    - (string) **`groups_claim = null`** _[since v0.0.1]_

        The claim to use to uniquely identify the set of groups to which the user belongs

    - (list(string)) **`oidc_scopes = null`** _[since v0.0.1]_

        A list of OIDC scopes to be used with an OIDC role

    - (number) **`token_max_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's max TTL (time-to-live) in seconds

    - (number) **`token_ttl_seconds = null`** _[since v0.0.1]_
    
        Specify the token's TTL (time-to-live) in seconds

    - (string) **`user_claim = null`** _[since v0.0.1]_

        The claim to use to uniquely identify the user

- (object) **`oidc_config = null`** _[since v0.0.1]_

    Configuration of an OIDC authentication method. This is required if `authentication_method = oidc`
    
    ```terraform
    oidc_config = {
      default_role = "tech-infra-cloudops"
      discovery_url = "https://login.microsoftonline.com/abcdef-1111-2222-abcd-11112222aaaa/v2.0"
      client_id = "8ad6e653-f37e-4a33-80fe-xxxxxxxxxxxx"
      client_secret = "some-secret...."
    }
    ```
    
    - (string) **`client_id`** _[since v0.0.1]_

        Client ID used for OIDC backends
    
    - (string) **`client_secret`** _[since v0.0.1]_
    
        Client Secret used for OIDC backends

    - (string) **`discovery_url`** _[since v0.0.1]_
    
        The OIDC Discovery URL, without any .well-known component (base path). [See example](#oidc)

    - (string) **`default_role = null`** _[since v0.0.1]_
    
        The default role to use if none is provided during login

## Outputs

- (string) **`mount_path`** _[since v0.0.1]_

    The mount path of the authentication method

## Known Limitations

### Experimental Options

This module enabled the following Terraform experimental features, a warning is expected and can be safely ignored.

- [Optional Object Type Attributes](https://www.terraform.io/docs/language/expressions/type-constraints.html#experimental-optional-object-type-attributes)

[duration-string]:https://pkg.go.dev/time#ParseDuration
[kube-reviewer-jwt]:https://www.vaultproject.io/docs/auth/kubernetes#configuring-kubernetes
[kube-issuer]:https://www.vaultproject.io/docs/auth/kubernetes#discovering-the-service-account-issuer
[auth-method]:https://www.vaultproject.io/docs/auth
[kubernetes-auth-role]:https://www.vaultproject.io/docs/auth/kubernetes#configuration