variable "models" {
  type = map(object({
    iam_role_arn = string

    container_definitions = map(object({
      image                 = string
      compression_type      = optional(string, "CompressedModel")
      environment_variables = optional(map(string), {})
      model_data_location   = optional(string, null)

      use_multiple_models = optional(object({
        enable_model_caching = optional(bool, true)
      }), null)
    }))

    inference_execution_config = optional(object({
      mode = optional(string, "Serial")
    }), {})

    additional_tags          = optional(map(string), {})
    enable_network_isolation = optional(bool, false)

    vpc_config = optional(object({
      security_group_ids = list(string)
      subnet_ids         = list(string)
    }), null)
  }))
  description = "deploy multiple models"
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "endpoints" {
  type = map(object({
    additional_tags = optional(map(string), {})
    encryption_key  = optional(string, null)

    provisioned = optional(object({
      production_variants = map(object({
        instance_type               = string
        container_startup_timeout   = optional(string, null)
        initial_instance_count      = optional(number, 1)
        initial_weight              = optional(number, 1)
        model_data_download_timeout = optional(string, null)
        volume_size                 = optional(number, null)

        auto_scaling = optional(object({
          policies = map(object({
            expression                = string # <metric_name> <statistic> = <TargetValue>
            enable_scale_in           = optional(bool, true)
            scale_in_cooldown_period  = optional(string, "5 minutes")
            scale_out_cooldown_period = optional(string, "5 minutes")
          }))

          maximum_capacity = optional(number, 1)
          minimum_capacity = optional(number, 1)
        }), null)

        cloudwatch_alarms = optional(map(object({
          expression             = string # <metric_name> <statistic> <comparison_operator> <threshold>
          description            = optional(string, null)
          evaluation_periods     = optional(number, 1)
          notification_sns_topic = optional(string, null)
          period                 = optional(string, "1 minute")
        })), {})
      }))

      async_invocation_config = optional(object({
        s3_output_path                          = string
        encryption_key                          = optional(string, null)
        error_notification_location             = optional(string, null)
        max_concurrent_invocations_per_instance = optional(number, null)
        s3_failure_path                         = optional(string, null)
        success_notification_location           = optional(string, null)
      }), null)

      enable_data_capture = optional(object({
        s3_location_to_store_data_collected = string
        sampling_percentage                 = optional(number, 30)

        capture_content_type = optional(object({
          csv_text = optional(list(string), null)
          json     = optional(list(string), null)
        }), null)

        data_capture_options = optional(object({
          prediction_request  = optional(bool, true)
          prediction_response = optional(bool, true)
        }), {})
      }), null)

      shadow_variants = optional(map(object({
        instance_type               = string
        container_startup_timeout   = optional(number, null)
        initial_instance_count      = optional(number, 1)
        initial_weight              = optional(number, 1)
        model_data_download_timeout = optional(number, null)
        volume_size                 = optional(number, null)
      })), {})
    }), null)

    serverless = optional(object({
      variant = object({
        model_name              = string
        max_concurrency         = optional(number, 20)
        memory_size             = optional(number, 1024)
        provisioned_concurrency = optional(number, null)
      })
    }), null)
  }))
  description = "Configures multiple endpoints"
  default     = {}
}
