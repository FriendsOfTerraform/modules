variable "models" {
  type = map(object({
    /// A role that SageMaker AI can assume to access model artifacts and docker images for deployment
    /// 
    /// @since 1.0.0
    iam_role_arn = string

    /// Container images containing inference code that are used when the model is deployed for predictions.
    /// 
    /// @since 1.0.0
    container_definitions = map(object({
      /// The registry path where the inference code image is stored in Amazon ECR
      /// 
      /// @since 1.0.0
      image                 = string
      /// Specify the model compression type. Valid values: `"CompressedModel"`, `"UncompressedModel"`
      /// 
      /// @since 1.0.0
      compression_type      = optional(string, "CompressedModel")
      /// Environment variables for the container
      /// 
      /// @since 1.0.0
      environment_variables = optional(map(string), {})
      /// The URL where model artifacts are stored in S3
      /// 
      /// @since 1.0.0
      model_data_location   = optional(string, null)

      /// Configure this container to host multiple models
      /// 
      /// @since 1.0.0
      use_multiple_models = optional(object({
        /// Whether to cache models for a multi-model endpoint. By default, multi-model endpoints cache models so that a model does not have to be loaded into memory each time it is invoked. Some use cases do not benefit from model caching. For example, if an endpoint hosts a large number of models that are each invoked infrequently, the endpoint might perform better if you disable model caching.
        /// 
        /// @since 1.0.0
        enable_model_caching = optional(bool, true)
      }), null)
    }))

    /// Specifies details of how containers in a multi-container endpoint are called.
    /// 
    /// @since 1.0.0
    inference_execution_config = optional(object({
      /// How containers in a multi-container are run. Valid values: `"Serial"` - Containers run as a serial pipeline. `"Direct"` - Only the individual container that you specify is run.
      /// 
      /// @since 1.0.0
      mode = optional(string, "Serial")
    }), {})

    /// Additional tags for the model
    /// 
    /// @since 1.0.0
    additional_tags          = optional(map(string), {})
    /// If enabled, containers cannot make any outbound network calls.
    /// 
    /// @since 1.0.0
    enable_network_isolation = optional(bool, false)

    /// Specifies the VPC that you want your model to connect to. This is used in hosting services and in batch transform.
    /// 
    /// @since 1.0.0
    vpc_config = optional(object({
      /// List of security group IDs the models use to access private resources
      /// 
      /// @since 1.0.0
      security_group_ids = list(string)
      /// List of subnet IDs to be used for this VPC connection
      /// 
      /// @since 1.0.0
      subnet_ids         = list(string)
    }), null)
  }))
  description = <<EOT
    Deploy multiple models. Please [see example](#basic-usage)
    
    @since 1.0.0
  EOT
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "endpoints" {
  type = map(object({
    /// Additional tags for the endpoint
    /// 
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
    /// Specify an existing KMS key's ARN to encrypt your response output in S3.
    /// 
    /// @since 1.0.0
    encryption_key  = optional(string, null)

    /// Creates a provisioned endpoint, mutually exclusive to `serverless`. Must specify one of `provisioned` or `serverless`
    /// 
    /// @since 1.0.0
    provisioned = optional(object({
      /// Configure multiple production variants, one for each model that you want to host at this endpoint.
      /// 
      /// @since 1.0.0
      production_variants = map(object({
        /// The EC2 instance type
        /// 
        /// @since 1.0.0
        instance_type               = string
        /// The timeout value for the inference container to pass health check by SageMaker AI Hosting. Valid values: `"1 minute"` - `"1 hour"`.
        /// 
        /// @since 1.0.0
        container_startup_timeout   = optional(string, null)
        /// Specify the initial number of instances used for auto-scaling.
        /// 
        /// @since 1.0.0
        initial_instance_count      = optional(number, 1)
        /// Determines initial traffic distribution among all of the models that you specify in the endpoint configuration.
        /// 
        /// @since 1.0.0
        initial_weight              = optional(number, 1)
        /// The timeout value to download and extract the model that you want to host from Amazon S3 to the individual inference instance associated with this production variant. Valid values: `"1 minute"` - `"1 hour"`.
        /// 
        /// @since 1.0.0
        model_data_download_timeout = optional(string, null)
        /// The size, in GB, of the ML storage volume attached to individual inference instance associated with the production variant. Valid values: `1` - `512`.
        /// 
        /// @since 1.0.0
        volume_size                 = optional(number, null)

        /// Enables auto scaling
        /// 
        /// @since 1.0.0
        auto_scaling = optional(object({
          /// Manages multiple auto scaling policies
          /// 
          /// @since 1.0.0
          policies = map(object({
            /// The expression in `<metric_name> <statistic> = <TargetValue>` format. For example: `"Invocations average = 100"`. If using a predefined metric such as `SageMakerVariantInvocationsPerInstance`, you can omit `<statistic>` from the expression. For example: `"SageMakerVariantInvocationsPerInstance = 100"`
            /// 
            /// @since 1.0.0
            expression                = string # <metric_name> <statistic> = <TargetValue>
            /// Allow this Auto Scaling policy to scale-in (removing EC2 instances).
            /// 
            /// @since 1.0.0
            enable_scale_in           = optional(bool, true)
            /// Specify the number of seconds to wait between scale-in actions.
            /// 
            /// @since 1.0.0
            scale_in_cooldown_period  = optional(string, "5 minutes")
            /// Specify the number of seconds to wait between scale-out actions.
            /// 
            /// @since 1.0.0
            scale_out_cooldown_period = optional(string, "5 minutes")
          }))

          /// Specify the maximum number of EC2 instances to maintain.
          /// 
          /// @since 1.0.0
          maximum_capacity = optional(number, 1)
          /// Specify the minimum number of EC2 instances to maintain.
          /// 
          /// @since 1.0.0
          minimum_capacity = optional(number, 1)
        }), null)

        /// Configures multiple Cloudwatch alarms. Please see [example](#basic-usage)
        /// 
        /// @since 1.0.0
        cloudwatch_alarms = optional(map(object({
          /// The expression in `<metric_name> <statistic> <comparison_operator> <threshold>` format. For example: `"Invocations average >= 100"`
          /// 
          /// @since 1.0.0
          expression             = string # <metric_name> <statistic> <comparison_operator> <threshold>
          /// The description of the alarm
          /// 
          /// @since 1.0.0
          description            = optional(string, null)
          /// The number of periods over which data is compared to the specified threshold.
          /// 
          /// @since 1.0.0
          evaluation_periods     = optional(number, 1)
          /// The SNS topic where notification will be sent
          /// 
          /// @since 1.0.0
          notification_sns_topic = optional(string, null)
          /// The period over which the specified statistic is applied. Valid values: `"1 minute"` - `"6 hours"`
          /// 
          /// @since 1.0.0
          period                 = optional(string, "1 minute")
        })), {})
      }))

      /// Specifies configuration for how an endpoint performs asynchronous inference
      /// 
      /// @since 1.0.0
      async_invocation_config = optional(object({
        /// Location to upload response output on success. Must be an S3 url(s3 path)
        /// 
        /// @since 1.0.0
        s3_output_path                          = string
        /// Specify an existing KMS key's ARN to encrypt your response output in S3.
        /// 
        /// @since 1.0.0
        encryption_key                          = optional(string, null)
        /// SNS topic to post a notification when inference fails. If no topic is provided, no notification is sent
        /// 
        /// @since 1.0.0
        error_notification_location             = optional(string, null)
        /// The maximum number concurrent requests sent to model container. If no value is provided, SageMaker chooses an optimal value.
        /// 
        /// @since 1.0.0
        max_concurrent_invocations_per_instance = optional(number, null)
        /// Location to upload response output on failure. Must be an S3 url (s3 path).
        /// 
        /// @since 1.0.0
        s3_failure_path                         = optional(string, null)
        /// SNS topic to post a notification when inference completes successfully. If no topic is provided, no notification is sent
        /// 
        /// @since 1.0.0
        success_notification_location           = optional(string, null)
      }), null)

      /// Enables data capture, where SageMaker can save prediction request and prediction response information from your endpoint to a specified location
      /// 
      /// @since 1.0.0
      enable_data_capture = optional(object({
        /// Amazon SageMaker will save the prediction requests and responses along with metadata for your endpoint at this location.
        /// 
        /// @since 1.0.0
        s3_location_to_store_data_collected = string
        /// Amazon SageMaker will randomly sample and save the specified percentage of traffic to your endpoint.
        /// 
        /// @since 1.0.0
        sampling_percentage                 = optional(number, 30)

        /// The content type headers to capture. Must specify one of `csv_text` or `json`
        /// 
        /// @since 1.0.0
        capture_content_type = optional(object({
          /// The CSV content type headers to capture.
          /// 
          /// @since 1.0.0
          csv_text = optional(list(string), null)
          /// The JSON content type headers to capture.
          /// 
          /// @since 1.0.0
          json     = optional(list(string), null)
        }), null)

        /// Specifies what data to capture.
        /// 
        /// @since 1.0.0
        data_capture_options = optional(object({
          /// Capture prediction requests (Input)
          /// 
          /// @since 1.0.0
          prediction_request  = optional(bool, true)
          /// Capture prediction responses (Output)
          /// 
          /// @since 1.0.0
          prediction_response = optional(bool, true)
        }), {})
      }), null)

      /// Specify shadow variants to receive production traffic replicated from the model specified on `production_variants`. If you use this field, you can only specify one variant for `production_variants` and one variant for `shadow_variants`.
      /// 
      /// @since 1.0.0
      shadow_variants = optional(map(object({
        /// The EC2 instance type
        /// 
        /// @since 1.0.0
        instance_type               = string
        /// The timeout value for the inference container to pass health check by SageMaker AI Hosting. Valid values: `"1 minute"` - `"1 hour"`.
        /// 
        /// @since 1.0.0
        container_startup_timeout   = optional(number, null)
        /// Specify the initial number of instances used for auto-scaling.
        /// 
        /// @since 1.0.0
        initial_instance_count      = optional(number, 1)
        /// Determines initial traffic distribution among all of the models that you specify in the endpoint configuration.
        /// 
        /// @since 1.0.0
        initial_weight              = optional(number, 1)
        /// The timeout value to download and extract the model that you want to host from Amazon S3 to the individual inference instance associated with this production variant. Valid values: `"1 minute"` - `"1 hour"`.
        /// 
        /// @since 1.0.0
        model_data_download_timeout = optional(number, null)
        /// The size, in GB, of the ML storage volume attached to individual inference instance associated with the production variant. Valid values: `1` - `512`.
        /// 
        /// @since 1.0.0
        volume_size                 = optional(number, null)
      })), {})
    }), null)

    /// Creates a serverless endpoint, mutually exclusive to `provisioned`. Must specify one of `provisioned` or `serverless`
    /// 
    /// @since 1.0.0
    serverless = optional(object({
      /// Configures variant for this endpoint
      /// 
      /// @since 1.0.0
      variant = object({
        /// The name of the model to be used for this endpoint. The model specified must be managed by the same module
        /// 
        /// @since 1.0.0
        model_name              = string
        /// The maximum number of concurrent invocations your serverless endpoint can process. Valid values: `1` - `200`
        /// 
        /// @since 1.0.0
        max_concurrency         = optional(number, 20)
        /// The memory size of your serverless endpoint. Valid values: `1024`, `2048`, `3072`, `4096`, `5120`, `6144`.
        /// 
        /// @since 1.0.0
        memory_size             = optional(number, 1024)
        /// Provisioned concurrency enables you to deploy models on serverless endpoints with predictable performance and high scalability. For the set number of concurrent invocations, SageMaker will keep underlying compute warm and ready to respond instantaneously without cold starts. Must be `<= max_concurrency`
        /// 
        /// @since 1.0.0
        provisioned_concurrency = optional(number, null)
      })
    }), null)
  }))
  description = <<EOT
    Configures multiple endpoints
    
    @since 1.0.0
  EOT
  default     = {}
}
