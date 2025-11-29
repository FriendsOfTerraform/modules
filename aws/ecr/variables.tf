variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "private_registry" {
  type = object({
    /// Specifies the JSON policy document defining the registry policy
    ///
    /// @link {ecr-private-registry-policy} https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry-permissions.html
    /// @since 1.0.0
    permissions = optional(string, null)

    /// Configures pull through cache rules. Please see example for usage
    ///
    /// @link {ecr-private-registry-pull-through-cache-rules} https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html
    /// @example "Private Registry Features" #private-registry-features
    /// @since 1.0.0
    pull_through_cache_rules = optional(map(object({
      /// The registry URL of the upstream public registry to use as the source
      ///
      /// | upstream registry         | URL
      /// |---------------------------|------------------------
      /// | ECR Public                | public.ecr.aws
      /// | Docker Hub                | registry-1.docker.io
      /// | Kubernetes                | registry.k8s.io
      /// | Quay                      | quay.io
      /// | Github Container Registry | ghcr.io
      /// | Azure Container Registry  | {custom}.azurecr.io
      /// | Gitlab Container Registry | registry.gitlab.com
      ///
      /// @since 1.0.0
      upstream_registry_url = string

      /// ARN of the Secret which will be used to authenticate against the registry.
      /// Required when using the following upstream registry: Docker Hub, Github
      /// Container Registry, Azure Container Registry, Gitlab Container Registry
      ///
      /// @since 1.0.0
      credential_arn = optional(string, null)
    })), {})

    /// Configures ECR replication rules
    ///
    /// @link {ecr-private-registry-image-replication} https://docs.aws.amazon.com/AmazonECR/latest/userguide/replication.html
    /// @example "Private Registry Features" #private-registry-features
    /// @since 1.0.0
    replication_rules = optional(list(object({
      /// The destinations images are replicated into. in `"account_id/region"`
      /// format. If `account_id` is omitted, the current account will be used.
      /// For cross account replication, please make sure you grant proper
      /// [registry permissions][ecr-private-registry-image-replication-permissions]
      ///
      /// @link {ecr-private-registry-image-replication-permissions} https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/registry-permissions-create-replication.html
      /// @since 1.0.0
      destinations = list(string)

      /// Add filters for this rule to specify the repositories to replicate.
      /// Supported filters are repository name prefixes. If no filter is added,
      /// all images in the repository are replicated.
      ///
      /// @since 1.0.0
      filters = optional(list(string), [])
    })), [])

    /// Manages multiple private repositories
    ///
    /// @link {ecr-private-registry-repository} https://docs.aws.amazon.com/AmazonECR/latest/userguide/Repositories.html
    /// @example "Basic Example" #basic-usage
    /// @since 1.0.0
    repositories = optional(map(object({
      /// Additional tags to be added to the repository
      ///
      /// @since 1.0.0
      additional_tags = optional(map(string), {})

      /// When tag immutability is enabled, tags are prevented from being overwritten
      ///
      /// @since 1.0.0
      enable_tag_immutability = optional(bool, false)

      /// Encrypts the repository with KMS. If unspecified, ECR will be encrypted with AES-256 by default
      ///
      /// @since 1.0.0
      encrypt_with_kms = optional(object({
        /// Specify the customer managed KMS key ID to be used for encryption. If unspecified, the default AWS managed key will be used.
        ///
        /// @since 1.0.0
        kms_key_id = optional(string, null)
      }), null)

      /// If true, repository can be deleted even if it contains images
      ///
      /// @since 1.0.0
      force_delete = optional(bool, false)

      /// Specifies the JSON policy document defining the repository policy
      ///
      /// @link {ecr-private-registry-repository-policy} https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html
      /// @since 1.0.0
      permissions = optional(string, null)

      /// Configures [lifecycle policy rules][ecr-private-registry-lifecycle-policy-rule] to automatically clean up images
      ///
      /// @link {ecr-private-registry-lifecycle-policy-rule} https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
      /// @since 1.0.0
      lifecycle_policy_rules = optional(list(object({
        /// Specify the count type to apply to the images. Must specify one of the below.
        ///
        /// @since 1.0.0
        match_criteria = object({
          /// Specifies how many days should pass since pushed before an image expires
          ///
          /// @since 1.0.0
          days_since_image_pushed = optional(number, null)

          /// Sets a limit on the number of images that exist in the repository
          ///
          /// @since 1.0.0
          image_count_more_than = optional(number, null)
        })

        /// Specify a rule priority, which must be unique. Values do not need to
        /// be sequential across rules in a policy. Lower number has higher priority.
        ///
        /// @since 1.0.0
        priority = number

        /// Describes the purpose of a rule within a lifecycle policy
        ///
        /// @since 1.0.0
        description = optional(string, null)

        /// Specify a list of image tags to match images to apply lifecycle rule
        /// towards. If not specified, untagged images will be matched. If `["*"]`,
        /// all images, including untagged images, willl be matched. Wildcard match
        /// will be used if wildcards are used in the filter, otherwise, prefix
        /// match will be used.
        ///
        /// @example "Basic Usage" #basic-usage
        /// @since 1.0.0
        tag_filters = optional(list(string), null)
      })), [])
    })), {})

    /// Configure [image scanning][ecr-private-registry-image-scanning]
    ///
    /// @link {ecr-private-registry-image-scanning} https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html
    /// @example "Private Registry Features" #private-registry-features
    /// @since 1.0.0
    scanning_configuration = optional(object({
      /// Specifies the scanning type that will be used for this registry
      ///
      /// @enum BASIC|ENHANCED
      /// @since 1.0.0
      scan_type = optional(string, "BASIC")

      /// Enables continuous scanning, which will continually scan images after it is pushed into a matching repository. This setting is only available if scan_type = "ENHANCED"
      ///
      /// @since 1.0.0
      continuous_scanning = optional(object({
        /// Specifies which repositories will continuously have images scanned
        /// for vulnerabilities. Filters with no wildcard will match all repository
        /// names that contain the filter. Filters with wildcards (*) will match
        /// on a repository name where the wildcard replaces zero or more
        /// characters in the repository name.
        ///
        /// @since 1.0.0
        filters = optional(list(string), ["*"])
      }), null)

      /// Enables scan on push, which scans images when it is pushed into a matching repository
      ///
      /// @since 1.0.0
      scan_on_push = optional(object({
        /// Specifies which repositories to scan for vulnerabilities on image
        /// push. Filters with no wildcard will match all repository names that
        /// contain the filter. Filters with wildcards (*) will match on a
        /// repository name where the wildcard replaces zero or more characters
        /// in the repository name.
        ///
        /// @since 1.0.0
        filters = optional(list(string), ["*"])
      }), null)
    }), null)
  })

  description = <<EOT
    Manages the private registry

    @since 1.0.0
  EOT
  default     = null
}

variable "public_registry" {
  type = object({
    /// Manages multiple public repositories
    ///
    /// @since 1.0.0
    repositories = optional(map(object({
      /// Provide a detailed description of the repository. Identify what is
      /// included in the repository, any licensing details, or other relevant
      /// information.
      ///
      /// @since 1.0.0
      about_text = optional(string, null)

      /// Additional tags to be added to the public repository
      ///
      /// @since 1.0.0
      additional_tags = optional(map(string), {})

      /// The system architecture that the images in the repository are compatible with
      ///
      /// @enum ARM|ARM 64|x86|x86-64
      /// @since 1.0.0
      architectures = optional(list(string), null)

      /// The short description is displayed in search results and on the repository detail page
      ///
      /// @since 1.0.0
      description = optional(string, null)

      /// The base64-encoded repository logo payload. (Only visible for verified accounts) Note that drift detection is disabled for this attribute.
      ///
      /// @since 1.0.0
      logo_image_blob = optional(string, null)

      /// The operating systems that the images in the repository are compatible with
      ///
      /// @enum Linux|Windows
      /// @since 1.0.0
      operating_systems = optional(list(string), null)

      /// Provide detailed information about how to use the images in the repository. This provides context, support information, and additional usage details for users of the repository.
      ///
      /// @since 1.0.0
      usage_text = optional(string, null)
    })), {})
  })

  description = <<EOT
    Manages the public registry

    @since 1.0.0
  EOT
  default     = null
}
