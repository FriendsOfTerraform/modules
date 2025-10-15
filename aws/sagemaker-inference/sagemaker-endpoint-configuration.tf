resource "aws_sagemaker_endpoint_configuration" "provisioned_endpoint_configurations" {
  for_each = local.provisioned_endpoints

  kms_key_arn = each.value.encryption_key
  name        = each.key

  dynamic "production_variants" {
    for_each = each.value.provisioned.production_variants

    content {
      container_startup_health_check_timeout_in_seconds = production_variants.value.container_startup_timeout != null ? split(" ", production_variants.value.container_startup_timeout)[0] * local.time_table[trimsuffix(split(" ", production_variants.value.container_startup_timeout)[1], "s")] : null
      initial_instance_count                            = production_variants.value.initial_instance_count
      instance_type                                     = production_variants.value.instance_type
      initial_variant_weight                            = production_variants.value.initial_weight
      model_data_download_timeout_in_seconds            = production_variants.value.model_data_download_timeout != null ? split(" ", production_variants.value.model_data_download_timeout)[0] * local.time_table[trimsuffix(split(" ", production_variants.value.model_data_download_timeout)[1], "s")] : null
      model_name                                        = aws_sagemaker_model.models[production_variants.key].name
      variant_name                                      = aws_sagemaker_model.models[production_variants.key].name
      volume_size_in_gb                                 = production_variants.value.volume_size
    }
  }

  dynamic "async_inference_config" {
    for_each = each.value.provisioned.async_invocation_config != null ? [1] : []

    content {
      output_config {
        s3_output_path  = each.value.provisioned.async_invocation_config.s3_output_path
        s3_failure_path = each.value.provisioned.async_invocation_config.s3_failure_path
        kms_key_id      = each.value.provisioned.async_invocation_config.encryption_key

        dynamic "notification_config" {
          for_each = each.value.provisioned.async_invocation_config.error_notification_location != null ? [1] : (each.value.provisioned.async_invocation_config.success_notification_location != null ? [1] : [])

          content {
            include_inference_response_in = each.value.provisioned.async_invocation_config.error_notification_location != null ? (
              each.value.provisioned.async_invocation_config.success_notification_location != null ? ["ERROR_NOTIFICATION_TOPIC", "SUCCESS_NOTIFICATION_TOPIC"] : ["ERROR_NOTIFICATION_TOPIC"]
              ) : (
              each.value.provisioned.async_invocation_config.success_notification_location != null ? ["SUCCESS_NOTIFICATION_TOPIC"] : null
            )

            error_topic   = each.value.provisioned.async_invocation_config.error_notification_location
            success_topic = each.value.provisioned.async_invocation_config.success_notification_location
          }
        }
      }

      dynamic "client_config" {
        for_each = each.value.provisioned.async_invocation_config.max_concurrent_invocations_per_instance != null ? [1] : []

        content {
          max_concurrent_invocations_per_instance = each.value.provisioned.async_invocation_config.max_concurrent_invocations_per_instance
        }
      }
    }
  }

  dynamic "data_capture_config" {
    for_each = each.value.provisioned.enable_data_capture != null ? [1] : []

    content {
      initial_sampling_percentage = each.value.provisioned.enable_data_capture.sampling_percentage
      destination_s3_uri          = each.value.provisioned.enable_data_capture.s3_location_to_store_data_collected
      kms_key_id                  = each.value.provisioned.enable_data_capture.encryption_key
      enable_capture              = true

      dynamic "capture_content_type_header" {
        for_each = each.value.provisioned.enable_data_capture.capture_content_type != null ? [1] : []

        content {
          csv_content_types  = each.value.provisioned.enable_data_capture.capture_content_type.csv_text
          json_content_types = each.value.provisioned.enable_data_capture.capture_content_type.json
        }
      }

      capture_options {
        capture_mode = each.value.provisioned.enable_data_capture.data_capture_options.prediction_request ? (
          each.value.provisioned.enable_data_capture.data_capture_options.prediction_response ? "InputAndOutput" : "Input"
          ) : (
          each.value.provisioned.enable_data_capture.data_capture_options.prediction_response ? "Output" : null
        )
      }
    }
  }

  dynamic "shadow_production_variants" {
    for_each = each.value.provisioned.shadow_variants

    content {
      container_startup_health_check_timeout_in_seconds = shadow_production_variants.value.container_startup_timeout != null ? split(" ", shadow_production_variants.value.container_startup_timeout)[0] * local.time_table[trimsuffix(split(" ", shadow_production_variants.value.container_startup_timeout)[1], "s")] : null
      initial_instance_count                            = shadow_production_variants.value.initial_instance_count
      instance_type                                     = shadow_production_variants.value.instance_type
      initial_variant_weight                            = shadow_production_variants.value.initial_weight
      model_data_download_timeout_in_seconds            = shadow_production_variants.value.model_data_download_timeout != null ? split(" ", shadow_production_variants.value.model_data_download_timeout)[0] * local.time_table[trimsuffix(split(" ", shadow_production_variants.value.model_data_download_timeout)[1], "s")] : null
      model_name                                        = aws_sagemaker_model.models[shadow_production_variants.key].name
      variant_name                                      = aws_sagemaker_model.models[shadow_production_variants.key].name
      volume_size_in_gb                                 = shadow_production_variants.value.volume_size
    }
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}

resource "aws_sagemaker_endpoint_configuration" "serverless_endpoint_configurations" {
  for_each = local.serverless_endpoints

  kms_key_arn = each.value.encryption_key
  name        = each.key

  production_variants {
    model_name   = aws_sagemaker_model.models[each.value.serverless.variant.model_name].name
    variant_name = aws_sagemaker_model.models[each.value.serverless.variant.model_name].name

    serverless_config {
      max_concurrency         = each.value.serverless.variant.max_concurrency
      memory_size_in_mb       = each.value.serverless.variant.memory_size
      provisioned_concurrency = each.value.serverless.variant.provisioned_concurrency
    }
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
