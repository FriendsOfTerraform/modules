variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for Guard Duty

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "enabled" {
  type        = bool
  description = <<EOT
    Whether GuardDuty is enabled. Setting to 'false' is equivalent to 'suspending' GuardDuty

    @since 1.0.0
  EOT
  default     = true
}

variable "findings_export_options" {
  type = object({
    /// Export frequency.
    ///
    /// @enum FIFTEEN_MINUTES|ONE_HOUR|SIX_HOURS
    /// @since 1.0.0
    frequency = optional(string, "SIX_HOURS")

    /// S3 destination for findings export
    ///
    /// @since 1.0.0
    s3_destination = optional(object({
      /// ARN of the S3 bucket where findings will be exported
      ///
      /// @since 1.0.0
      bucket_arn = string

      /// ARN of the KMS key used to encrypt findings in the S3 bucket
      ///
      /// @since 1.0.0
      kms_key_arn = string
    }), null)
  })
  description = <<EOT
    Configures findings export options

    @example "With Findings Export" #with-findings-export
    @since 1.0.0
  EOT
  default     = {}
}

variable "member_accounts" {
  type = map(object({
    /// Email address for the member account
    ///
    /// @since 1.0.0
    email_address = string

    /// Whether to invite the member account to GuardDuty
    ///
    /// @since 1.0.0
    invite = optional(bool, true)

    /// Optional invitation message for the member account
    ///
    /// @since 1.0.0
    invitation_message = optional(string, null)

    /// Protection plan overrides for the member account
    ///
    /// @since 1.0.0
    protection_plans = optional(object({
      /// EKS Protection settings
      ///
      /// @since 1.0.0
      eks_protection = optional(object({
        /// Whether EKS Protection is enabled for this member account
        ///
        /// @since 1.0.0
        enabled = optional(bool, null)
      }), {})

      /// Lambda Protection settings
      ///
      /// @since 1.0.0
      lambda_protection = optional(object({
        /// Whether Lambda Protection is enabled for this member account
        ///
        /// @since 1.0.0
        enabled = optional(bool, null)
      }), {})

      /// Malware protection configuration
      ///
      /// @since 1.0.0
      malware_protection = optional(object({
        /// EC2 malware protection settings
        ///
        /// @since 1.0.0
        ec2 = optional(object({
          /// Whether EC2 malware protection is enabled for this member account
          ///
          /// @since 1.0.0
          enabled = optional(bool, null)
        }), {})
      }), {})

      /// Runtime monitoring configuration
      ///
      /// @since 1.0.0
      runtime_monitoring = optional(object({
        /// Automated agent configuration for runtime monitoring
        ///
        /// @since 1.0.0
        automated_agent_configuration = optional(object({
          /// EKS automated agent configuration
          ///
          /// @since 1.0.0
          amazon_eks = optional(object({
            /// Whether to enable automated agent for EKS
            ///
            /// @since 1.0.0
            enabled = optional(bool, null)
          }), {})

          /// EC2 automated agent configuration
          ///
          /// @since 1.0.0
          amazon_ec2 = optional(object({
            /// Whether to enable automated agent for EC2
            ///
            /// @since 1.0.0
            enabled = optional(bool, null)
          }), {})

          /// Fargate ECS automated agent configuration
          ///
          /// @since 1.0.0
          aws_fargate_ecs = optional(object({
            /// Whether to enable automated agent for Fargate ECS
            ///
            /// @since 1.0.0
            enabled = optional(bool, null)
          }), {})
        }), {})

        /// Whether runtime monitoring is enabled for this member account
        ///
        /// @since 1.0.0
        enabled = optional(bool, null)
      }), {})

      /// RDS Protection settings
      ///
      /// @since 1.0.0
      rds_protection = optional(object({
        /// Whether RDS Protection is enabled for this member account
        ///
        /// @since 1.0.0
        enabled = optional(bool, null)
      }), {})

      /// S3 Protection settings
      ///
      /// @since 1.0.0
      s3_protection = optional(object({
        /// Whether S3 Protection is enabled for this member account
        ///
        /// @since 1.0.0
        enabled = optional(bool, null)
      }), {})
    }), {})
  }))
  description = <<EOT
    Map of member AWS accounts to onboard to GuardDuty with their email addresses and protection plan configurations

    @example "With Multi-Account Setup" #with-multi-account-setup
    @since 1.0.0
  EOT
  default     = {}
}

variable "protection_plans" {
  type = object({
    /// EKS Protection settings
    ///
    /// @since 1.0.0
    eks_protection = optional(object({
      /// Whether EKS Protection is enabled
      ///
      /// @since 1.0.0
      enabled = optional(bool, true)
    }), {})

    /// Lambda Protection settings
    ///
    /// @since 1.0.0
    lambda_protection = optional(object({
      /// Whether Lambda Protection is enabled
      ///
      /// @since 1.0.0
      enabled = optional(bool, true)
    }), {})

    /// Malware protection configuration
    ///
    /// @since 1.0.0
    malware_protection = optional(object({
      /// EC2 malware protection settings
      ///
      /// @since 1.0.0
      ec2 = optional(object({
        /// Whether EC2 malware protection is enabled
        ///
        /// @since 1.0.0
        enabled = optional(bool, false)
      }), {})

      /// S3 malware protection configuration. Map key is the bucket name.
      ///
      /// @since 1.0.0
      s3 = optional(map(object({
        /// Existing IAM role ARN for malware protection. If not specified, a role will be auto-created
        ///
        /// @since 1.0.0
        iam_role_arn = optional(string, null)

        /// ARN of the KMS key to use for decrypting encrypted objects
        ///
        /// @since 1.0.0
        kms_key_arn = optional(string, null)

        /// List of S3 object key prefixes to scan. If null, the entire bucket is scanned
        ///
        /// @since 1.0.0
        prefixes = optional(list(string), null)

        /// Whether to tag scanned objects with malware scan results
        ///
        /// @since 1.0.0
        tag_scanned_objects = optional(bool, true)

        /// Additional tags for the malware protection plan
        ///
        /// @since 1.0.0
        additional_tags = optional(map(string), {})
      })), {})
    }), {})

    /// Runtime monitoring configuration
    ///
    /// @since 1.0.0
    runtime_monitoring = optional(object({
      /// Automated agent configuration for runtime monitoring
      ///
      /// @since 1.0.0
      automated_agent_configuration = optional(object({
        /// EKS automated agent configuration
        ///
        /// @since 1.0.0
        amazon_eks = optional(object({
          /// Whether to enable automated agent for EKS
          ///
          /// @since 1.0.0
          enabled = optional(bool, false)
        }), {})

        /// EC2 automated agent configuration
        ///
        /// @since 1.0.0
        amazon_ec2 = optional(object({
          /// Whether to enable automated agent for EC2
          ///
          /// @since 1.0.0
          enabled = optional(bool, false)
        }), {})

        /// Fargate ECS automated agent configuration
        ///
        /// @since 1.0.0
        aws_fargate_ecs = optional(object({
          /// Whether to enable automated agent for Fargate ECS
          ///
          /// @since 1.0.0
          enabled = optional(bool, false)
        }), {})
      }), {})

      /// Whether runtime monitoring is enabled
      ///
      /// @since 1.0.0
      enabled = optional(bool, false)
    }), {})

    /// RDS Protection settings
    ///
    /// @since 1.0.0
    rds_protection = optional(object({
      /// Whether RDS Protection is enabled
      ///
      /// @since 1.0.0
      enabled = optional(bool, true)
    }), {})

    /// S3 Protection settings
    ///
    /// @since 1.0.0
    s3_protection = optional(object({
      /// Whether S3 Protection is enabled
      ///
      /// @since 1.0.0
      enabled = optional(bool, true)
    }), {})
  })
  description = <<EOT
    Configuration for GuardDuty protection plans including EKS, Lambda, Malware, Runtime Monitoring, RDS, and S3 protections

    @example "Basic Usage" #basic-usage
    @example "With Multi-Account Setup" #with-multi-account-setup
    @example "With S3 Malware Protection" #with-s3-malware-protection
    @since 1.0.0
  EOT
  default     = {}
}

variable "suppression_rules" {
  type = map(object({
    /// List of criteria in format "field operator value". Supported operators: =, !=, >, <, >=, <=, matches, not_matches. Example: `"resource.type = AwsEc2Instance"`
    ///
    /// @regex /^[\w.]+ (?:=|!=|>|<|>=|<=|matches|not_matches) .+$/ "resource.type = AwsEc2Instance"
    /// @since 1.0.0
    criteria = list(string)

    /// Optional description of the suppression rule
    ///
    /// @since 1.0.0
    description = optional(string, null)

    /// Optional rank to determine rule priority
    ///
    /// @since 1.0.0
    rank = optional(number, null)
  }))
  description = <<EOT
    GuardDuty suppression rules to archive specific findings. Each rule consists of criteria, optional description, and rank for rule priority

    @example "With Suppression Rules" #with-suppression-rules
    @since 1.0.0
  EOT
  default     = {}
}

variable "threat_ip_lists" {
  type = map(object({
    /// HTTPS URL to the threat IP list (e.g., https://s3.amazonaws.com/bucket-name/file.txt)
    ///
    /// @since 1.0.0
    location = string

    /// Format of the IP list.
    ///
    /// @enum TXT|STIX|OTX_CSV|ALIEN_VAULT|PROOF_POINT|FIRE_EYE
    /// @since 1.0.0
    list_format = optional(string, "TXT")

    /// Optional AWS account ID of the S3 bucket owner
    ///
    /// @since 1.0.0
    expected_bucket_owner = optional(string, null)

    /// Additional tags for the threat IP list
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
  }))
  description = <<EOT
    Map of threat IP lists for GuardDuty. Each list includes location (S3 path), format (TXT/JSON), and optional bucket owner

    @example "With Threat and Trusted IP Lists" #with-threat-and-trusted-ip-lists
    @since 1.0.0
  EOT
  default     = {}
}

variable "trusted_ip_lists" {
  type = map(object({
    /// HTTPS URL to the trusted IP list (e.g., https://s3.amazonaws.com/bucket-name/file.txt)
    ///
    /// @since 1.0.0
    location = string

    /// Format of the IP list.
    ///
    /// @enum TXT|STIX|OTX_CSV|ALIEN_VAULT|PROOF_POINT|FIRE_EYE
    /// @since 1.0.0
    list_format = optional(string, "TXT")

    /// Optional AWS account ID of the S3 bucket owner
    ///
    /// @since 1.0.0
    expected_bucket_owner = optional(string, null)

    /// Additional tags for the trusted IP list
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
  }))
  description = <<EOT
    Map of trusted IP lists for GuardDuty. Each list includes location (S3 path), format (TXT/JSON), and optional bucket owner

    @example "With Threat and Trusted IP Lists" #with-threat-and-trusted-ip-lists
    @since 1.0.0
  EOT
  default     = {}
}
