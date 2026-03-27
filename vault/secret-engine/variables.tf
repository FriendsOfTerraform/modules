//
// Global
//

variable "secret_engine" {
  type        = string
  description = <<EOT
    The Vault secret engine to configure, currently the following values are supported:

    - [aws](https://www.vaultproject.io/docs/secrets/aws)
    - [azure](https://developer.hashicorp.com/vault/docs/secrets/azure)
    - [database](https://www.vaultproject.io/docs/secrets/databases)
    - [pki](https://www.vaultproject.io/docs/secrets/pki)
    - [kv](https://www.vaultproject.io/docs/secrets/kv/kv-v2)
    - [terraform](https://www.vaultproject.io/docs/secrets/terraform)

    @enum aws|azure|database|pki|kv|terraform
    @since 0.0.1
  EOT
}

variable "mount_path" {
  type        = string
  description = <<EOT
    The mount path of the secret engine

    @since 0.0.1
  EOT
}

variable "description" {
  type        = string
  description = <<EOT
    Description of the secret engine

    @since 0.0.1
  EOT
  default     = "Managed by Terraform"
}

variable "default_ttl_seconds" {
  type        = number
  description = <<EOT
    Global default TTL (time-to-live) in seconds for all secrets within this secret mount

    @since 0.0.1
  EOT
  default     = null
}

variable "max_ttl_seconds" {
  type        = number
  description = <<EOT
    Global max TTL (time-to-live) in seconds for all secrets within this secret mount

    @since 0.0.1
  EOT
  default     = null
}

//
// AWS
//

variable "aws_config" {
  type = object({
    /// AWS access key ID
    ///
    /// @since 0.0.1
    access_key_id = string
    /// AWS secret access key
    ///
    /// @since 0.0.1
    secret_access_key = string
    /// AWS region
    ///
    /// @since 0.0.1
    region = string
    /// Default TTL (time-to-live) for new IAM credential created by this this secret engine
    ///
    /// @since 0.0.1
    default_ttl_seconds = optional(number)
    /// Max TTL (time-to-live) for new IAM credential created by this this secret engine
    ///
    /// @since 0.0.1
    max_ttl_seconds = optional(number)
  })

  description = <<EOT
    Configuration of an AWS secret engine. This is **OPTIONAL** even if `secret_engine = aws` since Vault can also read AWS credential from other methods such as enviornment variables and local AWS credential file.

    ```terraform
    aws_config = {
      access_key_id       = "AKIAXXXXXXXXXXXX"
      secret_access_key   = "5LoxXag/XXXXXXXXXXXXXXXX"
      region              = "us-east-1"
      max_ttl_seconds     = 1800
      default_ttl_seconds = 300
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "aws_secret_backend_roles" {
  type = map(object({
    /// Specifies the ARNs of the AWS roles this Vault role is allowed to assume. This option is mutually exclusive with `iam_group_names`
    ///
    /// @since 0.0.1
    role_arns = optional(list(string))
    /// A list of IAM group names. IAM users generated against this vault role will be added to these IAM Groups. This option is mutually exclusive with `aws_managed_policy_arns`
    ///
    /// @since 0.0.1
    iam_group_names = optional(list(string))
    /// Specifies a list of AWS managed policy ARNs that will be attached to the IAM user generated
    ///
    /// @since 0.0.1
    aws_managed_policy_arns = optional(list(string))
    /// An AWS IAM policy document that will be attached to the IAM user generated as an inline policy
    ///
    /// @since 0.0.1
    inline_policy_document = optional(string)
  }))

  description = <<EOT
    [Configure multiple roles][aws-role] that maps a name in Vault to an IAM entity (IAM User or IAM Role) to create new credentials. When users or machines create new credentials, they are created against this role. Input must be in `role_name = role_config` format.

    ```terraform
    aws_secret_backend_roles = {
      s3-operator = {
        aws_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
      }
    }
    ```

    @link {aws-role} https://www.vaultproject.io/docs/secrets/aws#setup
    @since 0.0.1
  EOT
  default     = {}
}

//
// Azure
//

variable "azure_config" {
  type = object({
    /// The ID of the Azure subscription to configure
    ///
    /// @since 0.0.2
    subscription_id = string
    /// The ID of the Azure tenant to configure
    ///
    /// @since 0.0.2
    tenant_id = string
    /// The client ID of the registered app used for authentication
    ///
    /// @since 0.0.2
    client_id = optional(string)
    /// The client secret of the registered app used for authentication
    ///
    /// @since 0.0.2
    client_secret = optional(string)
    /// Default TTL (time-to-live) for new Azure credential created by this this secret engine
    ///
    /// @since 0.0.2
    default_ttl_seconds = optional(number)
    /// Max TTL (time-to-live) for new Azure credential created by this this secret engine
    ///
    /// @since 0.0.2
    max_ttl_seconds = optional(number)
  })

  description = <<EOT
    Configuration of an Azure secret engine. This is **OPTIONAL** even if `secret_engine = azure` since Vault can also read Azure credential from other methods such as environment variables

    ```terraform
    azure_config = {
      subscription_id     = "5390980b-4d73-483f-bf52-xxxxxxx"
      tenant_id           = "accd881f-e517-4dbf-a61b-xxxxxxx"
      client_id           = "3446d619-f7aa-4aba-ba50-xxxxxxx"
      client_secret       = "oIG8Q~RAn3_XjtAAJ-xxxxxxx"
      default_ttl_seconds = 300
      max_ttl_seconds     = 300
    }
    ```

    @since 0.0.2
  EOT
  default     = null
}

variable "azure_secret_backend_roles" {
  type = map(object({
    /// Application Object ID for an existing service principal that will be used instead of creating dynamic service principals. If present, `azure_roles` will be ignored.
    ///
    /// @since 0.0.2
    application_object_id = optional(string)

    /// List of Azure roles to be assigned to the generated service principal. Please refer to [this documentation][azure-role] for examples. If dynamic service principals are used, Azure roles must be configured on the Vault role.
    ///
    /// @link {azure-role} https://developer.hashicorp.com/vault/docs/secrets/azure#roles
    /// @since 0.0.2
    azure_roles = optional(list(object({
      /// The ID of an Azure role to be attached to the credential generated by this Vault role. `role_name` is ignored if this is set.
      ///
      /// @since 0.0.2
      role_id = optional(string)
      /// The Name of an Azure role to be attached to the credential generated by this Vault role. If only this is set, Vault will perform a lookup for the actual `role_id`. If `role_id` is set, this option is ignored.
      ///
      /// @since 0.0.2
      role_name = optional(string)
      /// The scope this role is applied to
      ///
      /// @since 0.0.2
      scope = string
    })))

    azure_groups = optional(list(object({
      group_name = optional(string)
      object_id  = optional(string)
    })))

    ttl_seconds     = optional(number)
    max_ttl_seconds = optional(number)
  }))

  description = <<EOT
    [Configure multiple roles][azure-role] that maps a name in Vault to a registered app entity to create new credentials. When users or machines create new credentials, they are created against this role. Input must be in `role_name = role_config` format.

    ```terraform
    azure_secret_backend_roles = {
      "terraform-readonly" = {
        azure_roles = [
          {
            role_name = "Reader"
            scope     = "/subscriptions/5390980b-4d73-483f-bf52-xxxxxxx"
          }
        ]
      }
    }
    ```

    @link {azure-role} https://developer.hashicorp.com/vault/docs/secrets/azure#roles
    @since 0.0.2
  EOT
  default     = {}
}

//
// Database
//

variable "database_config" {
  type = object({
    /// Establish a connection to a Postgres database
    ///
    /// @since 0.0.10
    postgres = optional(map(object({
      allowed_roles = optional(list(string))
      /// The connection string for the database, in this formation `postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable`
      ///
      /// @since 0.0.10
      connection_url = string
      /// The maximum number of open connections to use
      ///
      /// @since 0.0.10
      max_open_connections = optional(number)
      /// The maximum number of idle connections to maintain
      ///
      /// @since 0.0.10
      max_idle_connections = optional(number)
      /// The maximum number of seconds to keep a connection alive for
      ///
      /// @since 0.0.10
      max_connection_lifetime_seconds = optional(number)
    })))
  })

  description = <<EOT
    Configuration of a Database secret engine. This is required if `secret_engine = database`.

    ```terraform
    database_config = {
      postgres = {
        test = {
          allowed_roles  = ["test-role"]
          connection_url = "postgresql://postgres:password@postgresql.friendsofterraform.com:5432/postgres?sslmode=disable"
        }
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "database_static_backend_roles" {
  type = map(object({
    /// The name of the database to manage
    ///
    /// @since 0.0.10
    database_name = string
    /// The rotation period for the password of the managed user
    ///
    /// @since 0.0.10
    rotation_period_seconds = optional(number)
  }))

  description = <<EOT
    Configures the mapping of a Vault role to a database user, in `username = {configuration}`

    ```terraform
    database_static_backend_roles = {
      "test-role" = {database_name = "test"}
    }
    ```

    @since 0.0.10
  EOT
  default     = {}
}

//
// PKI
//

variable "pki_config" {
  type = object({
    /// The type of certificate to configure,
    ///
    /// @enum root|intermediate
    /// @since 0.0.1
    cert_type = string
  })

  description = <<EOT
    Configuration of a PKI secret engine. This is required if `secret_engine = pki`. This secret engine only allows you to configure a root CA or an intermediate CA.

    ```terraform
    pki_config = {
      cert_type = "root"
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "pki_root_cert" {
  type = object({
    /// Specifies the common name for this Root CA certificate
    ///
    /// @since 0.0.1
    common_name = string
    /// Specifies a list of SAN (server alternative names) for this Root CA certificate
    ///
    /// @since 0.0.1
    alternative_names = optional(list(string))
    /// Specifies the TTL (time-to-live) for this Root CA certificate
    ///
    /// @since 0.0.1
    ttl_seconds = optional(number)
    /// Specifies the address of the Hashicorp Vault server. issuing certificate endpoints, CRL distribution points, and OCSP server endpoints that will be encoded into issued certificates. Please refer to [this doc][pki-config-urls] for more information. The generated endpoints will be in this format `<vault_address>/v1/<pki_mount_path>/ca`
    ///
    /// @link {pki-config-urls} https://www.vaultproject.io/api-docs/secret/pki#set-urls
    /// @since 0.0.1
    vault_address = string
  })

  description = <<EOT
    Options for configuring a Root CA, this is required if `pki_config.cert_type = root`

    ```terraform
    pki_root_cert = {
      common_name       = "root-ca"
      ttl_seconds       = 315360000 # 10 years
      vault_address     = "https://vault.friendsofterraform.sh"
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "pki_intermediate_ca" {
  type = object({
    /// Specifies the the secret engine mount path of a CA certificate that will be used to sign this intermediate CA certificate
    ///
    /// @since 0.0.1
    signing_ca_mount_path = string
    /// Specifies the common name for this intermediate CA certificate
    ///
    /// @since 0.0.1
    common_name = string
    /// Specifies a list of SAN (server alternative names) for this intermediate CA certificate
    ///
    /// @since 0.0.1
    alternative_names = optional(list(string))
    /// Specifies the TTL (time-to-live) for this intermediate CA certificate
    ///
    /// @since 0.0.1
    ttl_seconds = optional(number)
  })

  description = <<EOT
    Options for configuring an intermediate CA, this is required if `pki_config.cert_type = intermediate`

    ```terraform
    pki_intermediate_ca = {
      signing_ca_mount_path = module.root_ca.mount_path # signs the intermediate CA with this CA
      common_name           = "intermediate-ca"
      ttl_seconds           = 157680000 # 5 years
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "pki_secret_backend_roles" {
  type = map(object({
    /// Specifies the TTL (time-to-live) for certificates generated from this role
    ///
    /// @since 0.0.1
    ttl_seconds = optional(number)
    /// Specifies the max TTL (time-to-live) for certificates generated from this role
    ///
    /// @since 0.0.1
    max_ttl_seconds = optional(number)
    /// A list of domain names this role is allowed to sign the certificate for
    ///
    /// @since 0.0.1
    allowed_domains = optional(list(string))
    /// A list of URI SANs (Subject alternative names) this role is allowed to sign the certificate for
    ///
    /// @since 0.0.1
    allowed_uri_sans = optional(list(string))
  }))

  description = <<EOT
    [Configure multiple roles][pki-secret-setup] that maps a name in Vault to a procedure for generating a certificate. When users or machines generate credentials, they are generated against this role. Input must be in `role_name = role_config` format.

    ```terraform
    pki_secret_backend_roles = {
      friendsofterraform-sh = {
        ttl_seconds      = 259200 # 72 hours
        max_ttl_seconds  = 259200 # 72 hours
        allowed_domains  = ["friendsofterraform.sh"]
      }
    }
    ```

    @link {pki-secret-setup} https://www.vaultproject.io/docs/secrets/pki#setup
    @since 0.0.1
  EOT
  default     = {}
}

//
// Terraform Cloud
//

variable "terraform_config" {
  type = object({
    /// The Terraform Cloud management token this backend should use to issue new tokens
    ///
    /// @since 0.0.1
    token = string
  })

  description = <<EOT
    Configures the Terraform Cloud secret engine. This is required if `secret_engine = terraform`

    ```terraform
    terraform_config = {
      token = "Q3JtWYZK5Zx81w........"
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "terraform_secret_backend_roles" {
  type = map(object({
    /// Specifies the Terraform Cloud entity to be used to generate new tokens with. Must follow the following format:
    ///
    /// - Organization - Organization name. For example `FriendsOfTerraform`
    /// - Team - Team ID. For example `team-1234abcde`
    /// - User - User ID. For example `user-1234abcde`
    ///
    /// Note that you must use the Terraform Cloud API to get the [Team ID][terraform-api-team] and the [User ID][terraform-api-user].
    ///
    /// @link {terraform-api-team} https://www.terraform.io/docs/cloud/api/teams.html#list-teams
    /// @link {terraform-api-user} https://www.terraform.io/docs/cloud/api/account.html
    /// @since 0.0.1
    token_identity = string
    /// Specifies the TTL (time-to-live) for tokens generated from this role
    ///
    /// @since 0.0.1
    ttl_seconds = optional(number)
    /// Specifies the max TTL (time-to-live) for tokens generated from this role
    ///
    /// @since 0.0.1
    max_ttl_seconds = optional(number)
  }))

  description = <<EOT
    [Configure multiple roles][terraform-role] that maps a name in Vault to a Terraform Cloud token type (user, team, or organization) to create new tokens. When users or machines create new token, they are created against this role. Input must be in `role_name = role_config` format.

    ```terraform
    terraform_secret_backend_roles = {
      user-role = {
        token_identity  = "user-xxxxxxxxxxxx"
        ttl_seconds     = null
        max_ttl_seconds = null
      }
    }
    ```

    @link {terraform-role} https://www.vaultproject.io/docs/secrets/terraform#organization-team-and-user-roles
    @since 0.0.1
  EOT
  default     = {}
}
