# Elastic Container Registry Module

This module builds and configures private and public [ECR](https://aws.amazon.com/ecr/) registries and repositories

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
  - [Private Registry Features](#private-registry-features)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
  - [Objects](#objects)
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

_No required inputs._


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
    <td><code>object(<a href="#privateregistry">PrivateRegistry</a>)</code></td>
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



#### ContinuousScanning

Enables continuous scanning, which will continually scan images after it is pushed into a matching repository. This setting is only available if scan_type = "ENHANCED"

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">filters</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies which repositories will continuously have images scanned
for vulnerabilities. Filters with no wildcard will match all repository
names that contain the filter. Filters with wildcards (*) will match
on a repository name where the wildcard replaces zero or more
characters in the repository name.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EncryptWithKms

Encrypts the repository with KMS. If unspecified, ECR will be encrypted with AES-256 by default

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the customer managed KMS key ID to be used for encryption. If unspecified, the default AWS managed key will be used.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### LifecyclePolicyRules

Configures [lifecycle policy rules][ecr-private-registry-lifecycle-policy-rule] to automatically clean up images

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#matchcriteria">MatchCriteria</a>)</code></td>
    <td width="100%">match_criteria</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the count type to apply to the images. Must specify one of the below.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">priority</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify a rule priority, which must be unique. Values do not need to
be sequential across rules in a policy. Lower number has higher priority.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Describes the purpose of a rule within a lifecycle policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">tag_filters</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify a list of image tags to match images to apply lifecycle rule
towards. If not specified, untagged images will be matched. If `["*"]`,
all images, including untagged images, willl be matched. Wildcard match
will be used if wildcards are used in the filter, otherwise, prefix
match will be used.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### MatchCriteria

Specify the count type to apply to the images. Must specify one of the below.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">days_since_image_pushed</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies how many days should pass since pushed before an image expires

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">image_count_more_than</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Sets a limit on the number of images that exist in the repository

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### PrivateRegistry



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">permissions</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies the JSON policy document defining the registry policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#pullthroughcacherules">PullThroughCacheRules</a>))</code></td>
    <td width="100%">pull_through_cache_rules</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures pull through cache rules. Please see example for usage

    

    

    
**Examples:**
- [Private Registry Features](#private-registry-features)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(object(<a href="#replicationrules">ReplicationRules</a>))</code></td>
    <td width="100%">replication_rules</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures ECR replication rules

    

    

    
**Examples:**
- [Private Registry Features](#private-registry-features)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#repositories">Repositories</a>))</code></td>
    <td width="100%">repositories</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple private repositories

    

    

    
**Examples:**
- [Basic Example](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#scanningconfiguration">ScanningConfiguration</a>)</code></td>
    <td width="100%">scanning_configuration</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configure [image scanning][ecr-private-registry-image-scanning]

    

    

    
**Examples:**
- [Private Registry Features](#private-registry-features)

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



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



#### PullThroughCacheRules

Configures pull through cache rules. Please see example for usage

    

    

    
**Examples:**
- [Private Registry Features](#private-registry-features)

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">upstream_registry_url</td>
    <td></td>
</tr>
<tr><td colspan="3">

The registry URL of the upstream public registry to use as the source

| upstream registry         | URL
|---------------------------|------------------------
| ECR Public                | public.ecr.aws
| Docker Hub                | registry-1.docker.io
| Kubernetes                | registry.k8s.io
| Quay                      | quay.io
| Github Container Registry | ghcr.io
| Azure Container Registry  | {custom}.azurecr.io
| Gitlab Container Registry | registry.gitlab.com

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">credential_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

ARN of the Secret which will be used to authenticate against the registry.
Required when using the following upstream registry: Docker Hub, Github
Container Registry, Azure Container Registry, Gitlab Container Registry

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ReplicationRules

Configures ECR replication rules

    

    

    
**Examples:**
- [Private Registry Features](#private-registry-features)

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">destinations</td>
    <td></td>
</tr>
<tr><td colspan="3">

The destinations images are replicated into. in `"account_id/region"`
format. If `account_id` is omitted, the current account will be used.
For cross account replication, please make sure you grant proper
[registry permissions][ecr-private-registry-image-replication-permissions]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">filters</td>
    <td></td>
</tr>
<tr><td colspan="3">

Add filters for this rule to specify the repositories to replicate.
Supported filters are repository name prefixes. If no filter is added,
all images in the repository are replicated.

    

    

    

    

    
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

    
**Allowed Values:**
- `ARM`
- `ARM 64`
- `x86`
- `x86-64`

    

    

    

    
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

    
**Allowed Values:**
- `Linux`
- `Windows`

    

    

    

    
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



#### ScanOnPush

Enables scan on push, which scans images when it is pushed into a matching repository

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">filters</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies which repositories to scan for vulnerabilities on image
push. Filters with no wildcard will match all repository names that
contain the filter. Filters with wildcards (*) will match on a
repository name where the wildcard replaces zero or more characters
in the repository name.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ScanningConfiguration

Configure [image scanning][ecr-private-registry-image-scanning]

    

    

    
**Examples:**
- [Private Registry Features](#private-registry-features)

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">scan_type</td>
    <td><code>"BASIC"</code></td>
</tr>
<tr><td colspan="3">

Specifies the scanning type that will be used for this registry

    
**Allowed Values:**
- `BASIC`
- `ENHANCED`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#continuousscanning">ContinuousScanning</a>)</code></td>
    <td width="100%">continuous_scanning</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables continuous scanning, which will continually scan images after it is pushed into a matching repository. This setting is only available if scan_type = "ENHANCED"

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#scanonpush">ScanOnPush</a>)</code></td>
    <td width="100%">scan_on_push</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables scan on push, which scans images when it is pushed into a matching repository

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[ecr-private-registry-image-replication]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/replication.html

[ecr-private-registry-image-replication-permissions]: https://docs.amazonaws.cn/en_us/AmazonECR/latest/userguide/registry-permissions-create-replication.html

[ecr-private-registry-image-scanning]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html

[ecr-private-registry-lifecycle-policy-rule]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html

[ecr-private-registry-policy]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry-permissions.html

[ecr-private-registry-pull-through-cache-rules]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html

[ecr-private-registry-repository]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Repositories.html

[ecr-private-registry-repository-policy]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html


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
