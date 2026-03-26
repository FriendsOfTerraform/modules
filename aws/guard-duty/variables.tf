variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for Guard Duty"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "enabled" {
  type        = bool
  description = "Whether GuardDuty is enabled. Setting to 'false' is equivalent to 'suspending' GuardDuty"
  default     = true
}

variable "findings_export_options" {
  type = object({
    frequency = optional(string, "SIX_HOURS") # Valid values: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS

    s3_destination = optional(object({
      bucket_arn  = string
      kms_key_arn = string
    }), null)
  })
  description = "configures findings export options"
  default     = {}
}

variable "member_accounts" {
  type = map(object({
    email_address      = string
    invite             = optional(bool, true)
    invitation_message = optional(string, null)

    protection_plans = optional(object({
      eks_protection = optional(object({
        enabled = optional(bool, null)
      }), {})

      lambda_protection = optional(object({
        enabled = optional(bool, null)
      }), {})

      malware_protection = optional(object({
        ec2 = optional(object({
          enabled = optional(bool, null)
        }), {})
      }), {})

      runtime_monitoring = optional(object({
        automated_agent_configuration = optional(object({
          amazon_eks = optional(object({
            enabled = optional(bool, null)
          }), {})

          amazon_ec2 = optional(object({
            enabled = optional(bool, null)
          }), {})

          aws_fargate_ecs = optional(object({
            enabled = optional(bool, null)
          }), {})
        }), {})
        enabled = optional(bool, null)
      }), {})

      rds_protection = optional(object({
        enabled = optional(bool, null)
      }), {})

      s3_protection = optional(object({
        enabled = optional(bool, null)
      }), {})
    }), {})
  }))
  description = "Map of member AWS accounts to onboard to GuardDuty with their email addresses and protection plan configurations"
  default     = {}
}

variable "protection_plans" {
  type = object({
    eks_protection = optional(object({
      enabled = optional(bool, true)
    }), {})

    lambda_protection = optional(object({
      enabled = optional(bool, true)
    }), {})

    malware_protection = optional(object({
      ec2 = optional(object({
        enabled = optional(bool, false)
      }), {})

      s3 = optional(map(object({
        additional_tags     = optional(map(string), {})
        iam_role_arn        = optional(string, null)
        kms_key_arn         = optional(string, null)
        prefixes            = optional(list(string), null)
        tag_scanned_objects = optional(bool, true)
      })), {})
    }), {})

    runtime_monitoring = optional(object({
      automated_agent_configuration = optional(object({
        amazon_eks = optional(object({
          enabled = optional(bool, false)
        }), {})

        amazon_ec2 = optional(object({
          enabled = optional(bool, false)
        }), {})

        aws_fargate_ecs = optional(object({
          enabled = optional(bool, false)
        }), {})
      }), {})
      enabled = optional(bool, false)
    }), {})

    rds_protection = optional(object({
      enabled = optional(bool, true)
    }), {})

    s3_protection = optional(object({
      enabled = optional(bool, true)
    }), {})
  })
  description = "Configuration for GuardDuty protection plans including EKS, Lambda, Malware, Runtime Monitoring, RDS, and S3 protections"
  default     = {}
}

variable "suppression_rules" {
  type = map(object({
    criteria    = list(string) # Each criterion should be in the format "field operator value", e.g., "resource.type = AwsEc2Instance"
    description = optional(string, null)
    rank        = optional(number, null)
  }))
  description = "GuardDuty suppression rules to archive specific findings. Each rule consists of criteria, optional description, and rank for rule priority"
  default     = {}
}

variable "threat_ip_lists" {
  type = map(object({
    location              = string
    additional_tags       = optional(map(string), {})
    list_format           = optional(string, "TXT")
    expected_bucket_owner = optional(string, null)
  }))
  description = "Map of threat IP lists for GuardDuty. Each list includes location (S3 path), format (TXT/JSON), and optional bucket owner"
  default     = {}
}

variable "trusted_ip_lists" {
  type = map(object({
    location              = string
    additional_tags       = optional(map(string), {})
    list_format           = optional(string, "TXT")
    expected_bucket_owner = optional(string, null)
  }))
  description = "Map of trusted IP lists for GuardDuty. Each list includes location (S3 path), format (TXT/JSON), and optional bucket owner"
  default     = {}
}