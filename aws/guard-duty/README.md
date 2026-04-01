# AWS GuardDuty Module

This Terraform module provides comprehensive management of [AWS GuardDuty](https://aws.amazon.com/guardduty/), including threat detection, findings management, malware protection, and multi-account deployments.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
  - [With Findings Export](#with-findings-export)
  - [With Multi-Account Setup](#with-multi-account-setup)
  - [With Suppression Rules](#with-suppression-rules)
  - [With Threat and Trusted IP Lists](#with-threat-and-trusted-ip-lists)
  - [With S3 Malware Protection](#with-s3-malware-protection)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

## Example Usage

### Basic Usage

```terraform
module "guardduty" {
  source = "github.com/FriendsOfTerraform/aws-guard-duty.git?ref=v1.0.0"

  protection_plans = {
    eks_protection = {
      enabled = true
    }

    lambda_protection = {
      enabled = true
    }

    s3_protection = {
      enabled = true
    }
  }
}
```

### With Findings Export

```terraform
module "guardduty_with_export" {
  source = "github.com/FriendsOfTerraform/aws-guard-duty.git?ref=v1.0.0"

  findings_export_options = {
    frequency = "ONE_HOUR"

    s3_destination = {
      bucket_arn  = "arn:aws:s3:::demo-bucket"
      kms_key_arn = "arn:aws:kms:us-east-1:111122223333:key/12345678-abcd-dcba-b3fa-39e575b30cdf
    }
  }
}
```

### With Multi-Account Setup

```terraform
module "guardduty_multi_account" {
  source = "github.com/FriendsOfTerraform/aws-guard-duty.git?ref=v1.0.0"

  member_accounts = {
    "123456789012" = {
      email_address = "security@example.com"
      invite        = true

      # Overwrite protection plan settings for this member account only
      protection_plans = {
        malware_protection = {
          ec2 = {
            enabled = true
          }
        }
      }
    }

    "210987654321" = {
      email_address = "security2@example.com"
      invite        = true
    }
  }

  # Default protection settings applied to all member accounts
  protection_plans = {
    eks_protection = {
      enabled = true
    }

    lambda_protection = {
      enabled = true
    }
  }
}
```

### With Suppression Rules

```terraform
module "guardduty_with_filters" {
  source = "github.com/FriendsOfTerraform/aws-guard-duty.git?ref=v1.0.0"

  suppression_rules = {
    # Archive findings with low severity
    "archive-low-findings" = {
      description = "Archive findings with low severity"
      rank        = 1

      criteria = [
        "severity = 4",
        "severity = 5",
        "severity = 6",
        "severity = 7"
      ]
    }

    # Exclude test EC2 instances
    "exclude-test-instances" = {
      description = "Exclude test EC2 instances"
      rank        = 2

      criteria = [
        "resource.type = AwsEc2Instance",
        "resource.instanceDetails.tags.Environment = test"
      ]
    }
  }
}
```

### With Threat and Trusted IP Lists

```terraform
module "guardduty_with_ip_lists" {
  source = "github.com/FriendsOfTerraform/aws-guard-duty.git?ref=v1.0.0"

  threat_ip_lists = {
    "threat-ips" = {
      location    = "https://s3.amazonaws.com/security-lists-bucket/threat-ips.txt"
      list_format = "TXT"
    }
  }

  trusted_ip_lists = {
    "corporate-vpn" = {
      location    = "https://s3.amazonaws.com/security-lists-bucket/corporate-vpn-ips.txt"
      list_format = "TXT"
    }

    "office-networks" = {
      location    = "https://s3.amazonaws.com/security-lists-bucket/office-networks.txt"
      list_format = "TXT"
    }
  }
}
```

### With S3 Malware Protection

```terraform
module "guardduty_with_malware_protection" {
  source = "github.com/FriendsOfTerraform/aws-guard-duty.git?ref=v1.0.0"

  protection_plans = {
    malware_protection = {
      s3 = {
        "application-data-bucket" = {
          kms_key_arn         = "arn:aws:kms:us-east-1:111122223333:key/12345678-5639-8765-abcd-abcdef"
          prefixes            = ["uploads/"]
          tag_scanned_objects = true
        }

        "backup-bucket" = {
          tag_scanned_objects = false
        }
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
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for Guard Duty

**Since:** 1.0.0

</td></tr>
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
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether GuardDuty is enabled. Setting to 'false' is equivalent to 'suspending' GuardDuty

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#findings_export_options">findings_export_options</a>)</code></td>
    <td width="100%">findings_export_options</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures findings export options

**Examples:**

- [With Findings Export](#with-findings-export)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#member_accounts">member_accounts</a>))</code></td>
    <td width="100%">member_accounts</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Map of member AWS accounts to onboard to GuardDuty with their email addresses and protection plan configurations

**Examples:**

- [With Multi-Account Setup](#with-multi-account-setup)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#protection_plans">protection_plans</a>)</code></td>
    <td width="100%">protection_plans</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configuration for GuardDuty protection plans including EKS, Lambda, Malware, Runtime Monitoring, RDS, and S3 protections

**Examples:**

- [Basic Usage](#basic-usage)
- [With Multi-Account Setup](#with-multi-account-setup)
- [With S3 Malware Protection](#with-s3-malware-protection)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#suppression_rules">suppression_rules</a>))</code></td>
    <td width="100%">suppression_rules</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

GuardDuty suppression rules to archive specific findings. Each rule consists of criteria, optional description, and rank for rule priority

**Examples:**

- [With Suppression Rules](#with-suppression-rules)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#threat_ip_lists">threat_ip_lists</a>))</code></td>
    <td width="100%">threat_ip_lists</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Map of threat IP lists for GuardDuty. Each list includes location (S3 path), format (TXT/JSON), and optional bucket owner

**Examples:**

- [With Threat and Trusted IP Lists](#with-threat-and-trusted-ip-lists)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#trusted_ip_lists">trusted_ip_lists</a>))</code></td>
    <td width="100%">trusted_ip_lists</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Map of trusted IP lists for GuardDuty. Each list includes location (S3 path), format (TXT/JSON), and optional bucket owner

**Examples:**

- [With Threat and Trusted IP Lists](#with-threat-and-trusted-ip-lists)

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">detector_account_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The AWS account ID of the GuardDuty detector

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">detector_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the GuardDuty detector

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">detector_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the GuardDuty detector

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">filter_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of GuardDuty filter IDs for suppression rules

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">ipset_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of trusted IP set IDs

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">malware_protection_plan_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of S3 bucket names to their GuardDuty malware protection plan IDs

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">malware_protection_s3_role_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of S3 bucket names to their GuardDuty malware protection IAM role ARNs

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">malware_protection_s3_role_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of S3 bucket names to their GuardDuty malware protection IAM role IDs

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">member_account_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of member account IDs to their relationship IDs

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">publishing_destination_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the GuardDuty publishing destination (if configured)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">threat_intellset_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of threat intelligence set IDs

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Objects

#### amazon_ec2

EC2 automated agent configuration

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether to enable automated agent for EC2

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### amazon_eks

EKS automated agent configuration

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether to enable automated agent for EKS

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### automated_agent_configuration

Automated agent configuration for runtime monitoring

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#amazon_eks">amazon_eks</a>)</code></td>
    <td width="100%">amazon_eks</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

EKS automated agent configuration

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#amazon_ec2">amazon_ec2</a>)</code></td>
    <td width="100%">amazon_ec2</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

EC2 automated agent configuration

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#aws_fargate_ecs">aws_fargate_ecs</a>)</code></td>
    <td width="100%">aws_fargate_ecs</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Fargate ECS automated agent configuration

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### aws_fargate_ecs

Fargate ECS automated agent configuration

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether to enable automated agent for Fargate ECS

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ec2

EC2 malware protection settings

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether EC2 malware protection is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### eks_protection

EKS Protection settings

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether EKS Protection is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### findings_export_options

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">frequency</td>
    <td><code>"SIX_HOURS"</code></td>
</tr>
<tr><td colspan="3">

Export frequency.

**Allowed Values:**

- `FIFTEEN_MINUTES`
- `ONE_HOUR`
- `SIX_HOURS`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#s3_destination">s3_destination</a>)</code></td>
    <td width="100%">s3_destination</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

S3 destination for findings export

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### lambda_protection

Lambda Protection settings

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether Lambda Protection is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### malware_protection

Malware protection configuration

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#ec2">ec2</a>)</code></td>
    <td width="100%">ec2</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

EC2 malware protection settings

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#s3">s3</a>))</code></td>
    <td width="100%">s3</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

S3 malware protection configuration. Map key is the bucket name.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### member_accounts

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">email_address</td>
    <td></td>
</tr>
<tr><td colspan="3">

Email address for the member account

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">invite</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether to invite the member account to GuardDuty

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">invitation_message</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Optional invitation message for the member account

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#protection_plans">protection_plans</a>)</code></td>
    <td width="100%">protection_plans</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Protection plan overrides for the member account

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### protection_plans

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#eks_protection">eks_protection</a>)</code></td>
    <td width="100%">eks_protection</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

EKS Protection settings

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#lambda_protection">lambda_protection</a>)</code></td>
    <td width="100%">lambda_protection</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Lambda Protection settings

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#malware_protection">malware_protection</a>)</code></td>
    <td width="100%">malware_protection</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Malware protection configuration

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#runtime_monitoring">runtime_monitoring</a>)</code></td>
    <td width="100%">runtime_monitoring</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Runtime monitoring configuration

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#rds_protection">rds_protection</a>)</code></td>
    <td width="100%">rds_protection</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

RDS Protection settings

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#s3_protection">s3_protection</a>)</code></td>
    <td width="100%">s3_protection</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

S3 Protection settings

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### rds_protection

RDS Protection settings

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether RDS Protection is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### runtime_monitoring

Runtime monitoring configuration

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#automated_agent_configuration">automated_agent_configuration</a>)</code></td>
    <td width="100%">automated_agent_configuration</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Automated agent configuration for runtime monitoring

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether runtime monitoring is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### s3

S3 malware protection configuration. Map key is the bucket name.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Existing IAM role ARN for malware protection. If not specified, a role will be auto-created

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

ARN of the KMS key to use for decrypting encrypted objects

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">prefixes</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

List of S3 object key prefixes to scan. If null, the entire bucket is scanned

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">tag_scanned_objects</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether to tag scanned objects with malware scan results

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the malware protection plan

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### s3_destination

S3 destination for findings export

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">bucket_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the S3 bucket where findings will be exported

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the KMS key used to encrypt findings in the S3 bucket

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### s3_protection

S3 Protection settings

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether S3 Protection is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### suppression_rules

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">criteria</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of criteria in format "field operator value". Supported operators: =, !=, >, <, >=, <=, matches, not_matches. Example: `"resource.type = AwsEc2Instance"`

**Regex Pattern:**

```
^[\w.]+ (?:=|!=|>|<|>=|<=|matches|not_matches) .+$
```

Example Matches:

- `"resource.type = AwsEc2Instance"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Optional description of the suppression rule

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">rank</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Optional rank to determine rule priority

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### threat_ip_lists

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td></td>
</tr>
<tr><td colspan="3">

HTTPS URL to the threat IP list (e.g., https://s3.amazonaws.com/bucket-name/file.txt)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">list_format</td>
    <td><code>"TXT"</code></td>
</tr>
<tr><td colspan="3">

Format of the IP list.

**Allowed Values:**

- `TXT`
- `STIX`
- `OTX_CSV`
- `ALIEN_VAULT`
- `PROOF_POINT`
- `FIRE_EYE`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">expected_bucket_owner</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Optional AWS account ID of the S3 bucket owner

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the threat IP list

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### trusted_ip_lists

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td></td>
</tr>
<tr><td colspan="3">

HTTPS URL to the trusted IP list (e.g., https://s3.amazonaws.com/bucket-name/file.txt)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">list_format</td>
    <td><code>"TXT"</code></td>
</tr>
<tr><td colspan="3">

Format of the IP list.

**Allowed Values:**

- `TXT`
- `STIX`
- `OTX_CSV`
- `ALIEN_VAULT`
- `PROOF_POINT`
- `FIRE_EYE`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">expected_bucket_owner</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Optional AWS account ID of the S3 bucket owner

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the trusted IP list

**Since:** 1.0.0

</td></tr>
</tbody></table>

<!-- TFDOCS_EXTRAS_END -->
