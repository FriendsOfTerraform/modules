# Elastic Container Registry Module

This module builds and configures private and public [ECR](https://aws.amazon.com/ecr/) registries and repositories

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Private Registry Features](#private-registry-features)
- [Argument Reference](#argument-reference)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

This example demonstrates basic repository management

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-ecr.git?ref=v1.0.0"

  private_registry = {
    # Manages multiple ecr repositories
    # The keys of the map will be the repository's name
    repositories = {
      demo-repo = {}

      demo-repo-with-lifecycle-policy = {
        lifecycle_policy_rules = [
          {
            priority       = "1"
            match_criteria = { days_since_image_pushed = 15 }
            description    = "expires all untagged images that are pushed 15 days ago"
          },
          {
            priority       = "2"
            match_criteria = { image_count_more_than = 3 }
            tag_filters    = ["uat*", "dev*"]
            description    = "expires all images beside the latest 3 with tags matching wildcard uat* or dev*"
          },
          {
            priority       = "3"
            match_criteria = { image_count_more_than = 10 }
            tag_filters    = ["prod"]
            description    = "expires all images beside the latest 10 with tags prefixed with prod"
          },
          {
            priority       = "1000"
            match_criteria = { image_count_more_than = 10 }
            tag_filters    = ["*"]
            description    = "expires any images that are pushed 10 days ago"
          }
        ]
      }
    }
  }
}
```

### Private Registry Features

This example demonstrates how to manage multiple private registry features

```terraform
module "private_registry_features" {
  source = "github.com/FriendsOfTerraform/aws-ecr.git?ref=v1.0.0"

  private_registry = {
    # Manages multiple pull through cache rules
    # The keys of the map will be the rule's namespace
    pull_through_cache_rules = {
      gitlab = {
        upstream_registry_url = "registry.gitlab.com"
        credential_arn        = "arn:aws:secretsmanager:us-east-1:111122223333:secret:ecr-pullthroughcache/gitlab"
      }

      ecr-public = {
        upstream_registry_url = "public.ecr.aws"
      }
    }

    # Manages multiple replication rules
    # Each object counts as 1 separate rule, you can have a max of 10 rules
    replication_rules = [
      {
        # you can have a max of 25 destinations per rule
        # each destination is in "account_id/region" format
        # if account_id is omitted, the current account will be used
        destinations = [
          "us-west-2",
          "111122223333/us-west-2",
          "111122223333/us-east-2"
        ]

        filters = ["helloworld", "demo-application"]
      },
      {
        destinations = [
          "us-west-2",
          "ap-southeast-2"
        ]
      }
    ]

    scanning_configuration = {
      scan_type    = "ENHANCED"
      scan_on_push = {}

      continuous_scanning = {
        filters = ["helloworld", "foobar"]
      }
    }
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        </tbody></table>

### Optional



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object({
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
  })</code></td>
    <td width="100%">private_registry</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Manages the private registry

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#publicregistry">PublicRegistry</a>)</code></td>
    <td width="100%">public_registry</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Manages the public registry

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

### Objects



#### PublicRegistry



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#repositories">Repositories</a>))</code></td>
    <td width="100%">repositories</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple public repositories

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Repositories

Manages multiple public repositories

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">about_text</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Provide a detailed description of the repository. Identify what is
included in the repository, any licensing details, or other relevant
information.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags to be added to the public repository

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">architectures</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The system architecture that the images in the repository are compatible with

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The short description is displayed in search results and on the repository detail page

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">logo_image_blob</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The base64-encoded repository logo payload. (Only visible for verified accounts) Note that drift detection is disabled for this attribute.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">operating_systems</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The operating systems that the images in the repository are compatible with

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">usage_text</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Provide detailed information about how to use the images in the repository. This provides context, support information, and additional usage details for users of the repository.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>





<!-- TFDOCS_EXTRAS_END -->

## Outputs

- (map(object)) **`private_repositories`** _[since v1.0.0]_

    Map of all private repositories

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the repository

    - (string) **`registry_id`** _[since v1.0.0]_

        The account ID where the repository is created

    - (string) **`repository_url`** _[since v1.0.0]_

        The URL of the repository. In the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`

[ecr-private-registry-image-replication]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/replication.html
[ecr-private-registry-image-replication-permissions]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/registry-permissions-create-replication.html
[ecr-private-registry-image-scanning]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/image-scanning.html
[ecr-private-registry-lifecycle-police-rule]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/LifecyclePolicies.html
[ecr-private-registry-pull-through-cache-rules]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/pull-through-cache.html
[ecr-private-registry-policy]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/registry-permissions.html
[ecr-private-registry-repository]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/Repositories.html
[ecr-private-registry-repository-policy]:https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/repository-policies.html
