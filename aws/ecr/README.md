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

## Argument Reference

### Optional

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (object) **`private_registry = null`** _[since v1.0.0]_

    Manages the private registry

    - (string) **`permissions = null`** _[since v1.0.0]_

        Specifies the JSON policy document defining the [registry policy][ecr-private-registry-policy]

    - (map(object)) **`pull_through_cache_rules = {}`** _[since v1.0.0]_

        Configures [pull through cache rules][ecr-private-registry-pull-through-cache-rules]. Please see [example](#private-registry-features)

        - (string) **`upstream_registry_url`** _[since v1.0.0]_

            The registry URL of the upstream public registry to use as the source

            | upstream registry         | URL
            |---------------------------|-------------------------------------
            | ECR Public                | public.ecr.aws
            | Docker Hub                | registry-1.docker.io
            | Kubernetes                | registry.k8s.io
            | Quay                      | quay.io
            | Github Container Registry | ghcr.io
            | Azure Container Registry  | {custom}.azurecr.io
            | Gitlab Container Registry | registry.gitlab.com

        - (string) **`credential_arn = null`** _[since v1.0.0]_

            ARN of the Secret which will be used to authenticate against the registry. Required when using the following upstream registry: Docker Hub, Github Container Registry, Azure Container Registry, Gitlab Container Registry

    - (list(object)) **`replication_rules = []`** _[since v1.0.0]_

        Configures ECR [replication rules][ecr-private-registry-image-replication]. Please see [example](#private-registry-features)

        - (list(string)) **`destinations`** _[since v1.0.0]_

            The destinations images are replicated into. in `"account_id/region"` format. if `account_id` is omitted, the current account will be used. For cross account replication, please make sure you grant proper [registry permissions][ecr-private-registry-image-replication-permissions]

        - (list(string)) **`filters = []`** _[since v1.0.0]_

            Add filters for this rule to specify the repositories to replicate. Supported filters are repository name prefixes. If no filter is added, all images in the repository are replicated.

    - (map(object)) **`repositories = {}`** _[since v1.0.0]_

        Manages multiple [private repositories][ecr-private-registry-repository]. Please see [example](#basic-usage)

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags to be added to the repository

        - (bool) **`enable_tag_immutability = false`** _[since v1.0.0]_

            When tag immutability is enabled, tags are prevented from being overwritten.

        - (object) **`encrypt_with_kms = null`** _[since v1.0.0]_

            Encrypts the repository with KMS. If unspecified, ECR will be encrypted with `AES-256` by default

            - (string) **`kms_key_id = null`** _[since v1.0.0]_

                Specify the customer managed KMS key ID to be used for encryption. if unspecified, the default AWS managed key will be used.

        - (bool) **`force_delete = false`** _[since v1.0.0]_

            If true, repository can be deleted even if it containes images

        - (string) **`permissions = null`** _[since v1.0.0]_

            Specifies the JSON policy document defining the [repository policy][ecr-private-registry-repository-policy]

        - (list(object)) **`lifecycle_policy_rules = []`** _[since v1.0.0]_

            Configures [lifecycle police rules][ecr-private-registry-lifecycle-police-rule] to automatically clean up images

            - (object) **`match_criteria`** _[since v1.0.0]_

                Specify the count type to apply to the images. Must specify one of the below.

                - (number) **`days_since_image_pushed = null`** _[since v1.0.0]_

                    Specifies how many days should pass since pushed before an image expires

                - (number) **`image_count_more_than = null`** _[since v1.0.0]_

                    Sets a limit on the number of images that exist in the repository

            - (number) **`priority`** _[since v1.0.0]_

                Specify a rule priority, which must be unique. Values do not need to be sequential across rules in a policy. Lower number has higher priority.

            - (string) **`description = null`** _[since v1.0.0]_

                Describes the purpose of a rule within a lifecycle policy

            - (list(string)) **`tag_filters = null`** _[since v1.0.0]_

                Specify a list of image tags to match images to apply lifecycle rule towards. If not specified, untagged images will be matched. If `["*"]`, all images, including untagged images, willl be matched. Wildcard match will be used if wildcards are used in the filter, otherwise, prefix match will be used. Please see [example](#basic-usage)

    - (object) **`scanning_configuration = null`** _[since v1.0.0]_

        Configure [image scanning][ecr-private-registry-image-scanning]. Please see [example](#private-registry-features)

        - (string) **`scan_type = "BASIC"`** _[since v1.0.0]_

            Specifies the scanning type that will be used for this registry. Valid values are: `"BASIC"`, `"ENHANCED"`

        - (object) **`continuous_scanning = null`** _[since v1.0.0]_

            Enables continuous scanning, which will continually scans images after it is pushed into a matching repository. This setting is only available if `scan_type = "ENHANCED"`

            - (list(string)) **`filters = ["*"]`** _[since v1.0.0]_

                Specifies which repositories will continuously have images scanned for vulnerabilities. Filters with no wildcard will match all repository names that contain the filter. Filters with wildcards (*) will match on a repository name where the wildcard replaces zero or more characters in the repository name.

        - (object) **`scan_on_push = null`** _[since v1.0.0]_

            Enables scan on push, which scans images when it is pushed into a matching repository.

            - (string) **`filters = ["*"]`** _[since v1.0.0]_

                Specifies which repositories to scan for vulnerabilities on image push. Filters with no wildcard will match all repository names that contain the filter. Filters with wildcards (*) will match on a repository name where the wildcard replaces zero or more characters in the repository name.

- (object) **`public_registry = null`** _[since v1.0.0]_

    Manages the public registry

    - (map(object)) **`repositories = {}`** _[since v1.0.0]_

        Manages multiple public repositories

        - (string) **`about_text = null`** _[since v1.0.0]_

            Provide a detailed description of the repository. Identify what is included in the repository, any licensing details, or other relevant information.

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags to be added to the public repository

        - (list(string)) **`architectures = null`** _[since v1.0.0]_

            The system architecture that the images in the repository are compatible with. Valid values: `"ARM"`, `"ARM 64"`, `"x86"`, `"x86-64"`

        - (string) **`description = null`** _[since v1.0.0]_

            The short description is displayed in search results and on the repository detail page.

        - (string) **`logo_image_blob = null`** _[since v1.0.0]_

            The base64-encoded repository logo payload. (Only visible for verified accounts) Note that drift detection is disabled for this attribute.

        - (list(string)) **`operating_systems = null`** _[since v1.0.0]_

            The operating systems that the images in the repository are compatible with. Valid values: `"Linux"`, `"Windows"`

        - (string) **`usage_text = null`** _[since v1.0.0]_

            Provide detailed information about how to use the images in the repository. This provides context, support information, and additional usage details for users of the repository.

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
