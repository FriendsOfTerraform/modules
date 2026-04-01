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

## Argument Reference

### Mandatory

None - all variables have sensible defaults.

### Optional

- (bool) **`enabled = true`** _[since v1.0.0]_

  Whether GuardDuty is enabled. Setting to `false` is equivalent to suspending GuardDuty

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

  Additional tags for GuardDuty resources

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

  Additional tags for all resources deployed with this module

- (object) **`findings_export_options = {}`** _[since v1.0.0]_

  Configures findings export options
  - (string) **`frequency = "SIX_HOURS"`** _[since v1.0.0]_

    Export frequency. Valid values: `"FIFTEEN_MINUTES"`, `"ONE_HOUR"`, `"SIX_HOURS"`

  - (object) **`s3_destination = null`** _[since v1.0.0]_

    S3 destination for findings export
    - (string) **`bucket_arn`** _[since v1.0.0]_

      ARN of the S3 bucket where findings will be exported

    - (string) **`kms_key_arn`** _[since v1.0.0]_

      ARN of the KMS key used to encrypt findings in the S3 bucket

- (map(object)) **`member_accounts = {}`** _[since v1.0.0]_

  Map of member AWS accounts to onboard to GuardDuty
  - (string) **`email_address`** _[since v1.0.0]_

    Email address for the member account

  - (bool) **`invite = true`** _[since v1.0.0]_

    Whether to invite the member account to GuardDuty

  - (string) **`invitation_message = null`** _[since v1.0.0]_

    Optional invitation message for the member account

  - (object) **`protection_plans = {}`** _[since v1.0.0]_

    Protection plan overrides for the member account
    - (object) **`eks_protection = {}`** _[since v1.0.0]_

      EKS Protection settings
      - (bool) **`enabled = null`** _[since v1.0.0]_

        Whether EKS Protection is enabled for this member account

    - (object) **`lambda_protection = {}`** _[since v1.0.0]_

      Lambda Protection settings
      - (bool) **`enabled = null`** _[since v1.0.0]_

        Whether Lambda Protection is enabled for this member account

    - (object) **`malware_protection = {}`** _[since v1.0.0]_

      Malware protection configuration
      - (object) **`ec2 = {}`** _[since v1.0.0]_

        EC2 malware protection settings
        - (bool) **`enabled = null`** _[since v1.0.0]_

          Whether EC2 malware protection is enabled for this member account

    - (object) **`runtime_monitoring = {}`** _[since v1.0.0]_

      Runtime monitoring configuration
      - (bool) **`enabled = null`** _[since v1.0.0]_

        Whether runtime monitoring is enabled for this member account

    - (object) **`rds_protection = {}`** _[since v1.0.0]_

      RDS Protection settings
      - (bool) **`enabled = null`** _[since v1.0.0]_

        Whether RDS Protection is enabled for this member account

    - (object) **`s3_protection = {}`** _[since v1.0.0]_

      S3 Protection settings
      - (bool) **`enabled = null`** _[since v1.0.0]_

        Whether S3 Protection is enabled for this member account

- (object) **`protection_plans = {}`** _[since v1.0.0]_

  GuardDuty protection plan configuration
  - (object) **`eks_protection = {}`** _[since v1.0.0]_

    EKS Protection settings
    - (bool) **`enabled = true`** _[since v1.0.0]_

      Whether EKS Protection is enabled

  - (object) **`lambda_protection = {}`** _[since v1.0.0]_

    Lambda Protection settings
    - (bool) **`enabled = true`** _[since v1.0.0]_

      Whether Lambda Protection is enabled

  - (object) **`malware_protection = {}`** _[since v1.0.0]_

    Malware protection configuration
    - (object) **`ec2 = {}`** _[since v1.0.0]_

      EC2 malware protection settings
      - (bool) **`enabled = false`** _[since v1.0.0]_

        Whether EC2 malware protection is enabled

    - (map(object)) **`s3 = {}`** _[since v1.0.0]_

      S3 malware protection configuration. Map key is the bucket name.
      - (string) **`iam_role_arn = null`** _[since v1.0.0]_

        Existing IAM role ARN for malware protection. If not specified, a role will be auto-created

      - (string) **`kms_key_arn = null`** _[since v1.0.0]_

        ARN of the KMS key to use for decrypting encrypted objects

      - (list(string)) **`prefixes = null`** _[since v1.0.0]_

        List of S3 object key prefixes to scan. If null, the entire bucket is scanned

      - (bool) **`tag_scanned_objects = true`** _[since v1.0.0]_

        Whether to tag scanned objects with malware scan results

      - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the malware protection plan

  - (object) **`runtime_monitoring = {}`** _[since v1.0.0]_

    Runtime monitoring configuration
    - (bool) **`enabled = false`** _[since v1.0.0]_

      Whether runtime monitoring is enabled

    - (object) **`automated_agent_configuration = {}`** _[since v1.0.0]_

      Automated agent configuration for runtime monitoring
      - (object) **`amazon_eks = {}`** _[since v1.0.0]_

        EKS automated agent configuration
        - (bool) **`enabled = false`** _[since v1.0.0]_

          Whether to enable automated agent for EKS

      - (object) **`amazon_ec2 = {}`** _[since v1.0.0]_

        EC2 automated agent configuration
        - (bool) **`enabled = false`** _[since v1.0.0]_

          Whether to enable automated agent for EC2

      - (object) **`aws_fargate_ecs = {}`** _[since v1.0.0]_

        Fargate ECS automated agent configuration
        - (bool) **`enabled = false`** _[since v1.0.0]_

          Whether to enable automated agent for Fargate ECS

  - (object) **`rds_protection = {}`** _[since v1.0.0]_

    RDS Protection settings
    - (bool) **`enabled = true`** _[since v1.0.0]_

      Whether RDS Protection is enabled

  - (object) **`s3_protection = {}`** _[since v1.0.0]_

    S3 Protection settings
    - (bool) **`enabled = true`** _[since v1.0.0]_

      Whether S3 Protection is enabled

- (map(object)) **`suppression_rules = {}`** _[since v1.0.0]_

  GuardDuty suppression rules to archive findings
  - (list(string)) **`criteria`** _[since v1.0.0]_

    List of criteria in format "field operator value". Supported operators: `=`, `!=`, `>`, `<`, `>=`, `<=`, `matches`, `not_matches`. Example: `"resource.type = AwsEc2Instance"`

  - (string) **`description = null`** _[since v1.0.0]_

    Optional description of the suppression rule

  - (number) **`rank = null`** _[since v1.0.0]_

    Optional rank to determine rule priority

- (map(object)) **`threat_ip_lists = {}`** _[since v1.0.0]_

  Map of threat IP lists for GuardDuty
  - (string) **`location`** _[since v1.0.0]_

    HTTPS URL to the threat IP list (e.g., `"https://s3.amazonaws.com/bucket-name/file.txt"`)

  - (string) **`list_format = "TXT"`** _[since v1.0.0]_

    Format of the IP list. Valid values: `"TXT"`, `"STIX"`, `"OTX_CSV"`, `"ALIEN_VAULT"`, `"PROOF_POINT"`, `"FIRE_EYE"`

  - (string) **`expected_bucket_owner = null`** _[since v1.0.0]_

    Optional AWS account ID of the S3 bucket owner

- (map(object)) **`trusted_ip_lists = {}`** _[since v1.0.0]_

  Map of trusted IP lists for GuardDuty
  - (string) **`location`** _[since v1.0.0]_

    HTTPS URL to the trusted IP list (e.g., `"https://s3.amazonaws.com/bucket-name/file.txt"`)

  - (string) **`list_format = "TXT"`** _[since v1.0.0]_

    Format of the IP list. Valid values: `"TXT"`, `"STIX"`, `"OTX_CSV"`, `"ALIEN_VAULT"`, `"PROOF_POINT"`, `"FIRE_EYE"`

  - (string) **`expected_bucket_owner = null`** _[since v1.0.0]_

    Optional AWS account ID of the S3 bucket owner

## Outputs

- (string) **`detector_id`** _[since v1.0.0]_

  The ID of the GuardDuty detector

- (string) **`detector_arn`** _[since v1.0.0]_

  The ARN of the GuardDuty detector

- (string) **`detector_account_id`** _[since v1.0.0]_

  The AWS account ID of the GuardDuty detector

- (map(string)) **`malware_protection_s3_role_arns`** _[since v1.0.0]_

  Map of S3 bucket names to their GuardDuty malware protection IAM role ARNs

- (map(string)) **`malware_protection_s3_role_ids`** _[since v1.0.0]_

  Map of S3 bucket names to their GuardDuty malware protection IAM role IDs

- (map(string)) **`malware_protection_plan_ids`** _[since v1.0.0]_

  Map of S3 bucket names to their GuardDuty malware protection plan IDs

- (map(string)) **`threat_intellset_ids`** _[since v1.0.0]_

  Map of threat intelligence set names to their IDs

- (map(string)) **`ipset_ids`** _[since v1.0.0]_

  Map of trusted IP set names to their IDs

- (map(string)) **`filter_ids`** _[since v1.0.0]_

  Map of GuardDuty suppression rule filter IDs

- (map(string)) **`member_account_ids`** _[since v1.0.0]_

  Map of member account IDs to their relationship IDs

- (string) **`publishing_destination_id`** _[since v1.0.0]_

  The ID of the GuardDuty findings publishing destination (if configured)

<!-- TFDOCS_EXTRAS_END -->
