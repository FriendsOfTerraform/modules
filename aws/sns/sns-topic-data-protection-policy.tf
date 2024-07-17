locals {
  data_protection_policy = var.data_protection_policy != null ? (
    jsonencode(
      merge(
        {
          Name        = "__default_data_protection_policy"
          Description = "Managed by Terraform"
          Version     = "2021-06-01"
        },

        {
          Statement = [
            for sid, statement in var.data_protection_policy.statements :
            {
              Sid            = sid
              DataDirection  = statement.data_direction
              Principal      = statement.principals
              DataIdentifier = statement.data_identifiers
              Operation = merge(
                statement.operation.audit != null ? {
                  Audit = {
                    SampleRate = statement.operation.audit.sample_rate
                    FindingsDestination = merge(
                      statement.operation.audit.destinations.cloudwatch_log_group != null ? {
                        CloudWatchLogs = {
                          LogGroup = statement.operation.audit.destinations.cloudwatch_log_group
                        }
                      } : {},

                      statement.operation.audit.destinations.s3_bucket_name != null ? {
                        S3 = {
                          Bucket = statement.operation.audit.destinations.s3_bucket_name
                        }
                      } : {},

                      statement.operation.audit.destinations.firehose_delivery_stream != null ? {
                        Firehose = {
                          DeliveryStream = statement.operation.audit.destinations.firehose_delivery_stream
                        }
                      } : {}
                    )
                  }
                } : {},

                statement.operation.deny != null ? {
                  Deny = {}
                } : {},

                statement.operation.deidentify != null ? {
                  Deidentify = merge(
                    statement.operation.deidentify.mask_with_character != null ? {
                      MaskConfig = {
                        MaskWithCharacter = statement.operation.deidentify.mask_with_character
                      }
                    } : {},

                    statement.operation.deidentify.redact != null ? {
                      RedactConfig = {}
                    } : {}
                  )
                } : {}
              )
            }
          ]
        },

        var.data_protection_policy.configuration != null ? (
          {
            Configuration = {
              CustomDataIdentifier = [
                for name, regex in var.data_protection_policy.configuration.custom_data_identifiers :
                {
                  Name  = name
                  Regex = regex
                }
              ]
            }
          }
        ) : {}
      )
    )
  ) : null
}

resource "aws_sns_topic_data_protection_policy" "data_protection_policy" {
  count = var.data_protection_policy != null ? 1 : 0

  arn    = aws_sns_topic.sns_topic.arn
  policy = local.data_protection_policy
}
