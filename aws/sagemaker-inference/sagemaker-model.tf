resource "aws_sagemaker_model" "models" {
  for_each = var.models

  name                     = each.key
  execution_role_arn       = each.value.iam_role_arn
  enable_network_isolation = each.value.enable_network_isolation

  dynamic "container" {
    for_each = each.value.container_definitions

    content {
      image              = container.value.image
      mode               = container.value.use_multiple_models != null ? "MultiModel" : "SingleModel"
      model_data_url     = lower(container.value.compression_type) == "compressedmodel" ? container.value.model_data_location : null
      container_hostname = container.key
      environment        = container.value.environment_variables

      dynamic "model_data_source" {
        for_each = lower(container.value.compression_type) == "uncompressedmodel" ? [1] : []

        content {
          s3_data_source {
            compression_type = endswith(container.value.model_data_location, ".tar.gz") ? "Gzip" : "None"
            s3_data_type     = endswith(container.value.model_data_location, "/") ? "S3Prefix" : "S3Object"
            s3_uri           = container.value.model_data_location
          }
        }
      }

      dynamic "multi_model_config" {
        for_each = container.value.use_multiple_models != null ? [1] : []

        content {
          model_cache_setting = container.value.use_multiple_models.enable_model_caching ? "Enabled" : "Disabled"
        }
      }
    }
  }

  dynamic "inference_execution_config" {
    for_each = length(each.value.container_definitions) > 1 ? [1] : []

    content {
      mode = each.value.inference_execution_config.mode
    }
  }

  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [1] : []

    content {
      security_group_ids = each.value.vpc_config.security_group_ids
      subnets            = each.value.vpc_config.subnet_ids
    }
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
